import SwiftUI
import PrepUnits

extension FoodForm.NutritionFacts {
    struct Cell: View {
        @StateObject var cellViewModel: ViewModel
        
        init(nutritionFactType: NutritionFactType, nutritionFact: NutritionFact?) {
            let viewModel = ViewModel(nutritionFactType: nutritionFactType, nutritionFact: nutritionFact)
            _cellViewModel = StateObject(wrappedValue: viewModel)
        }
    }
}

extension FoodForm.NutritionFacts.Cell {
    class ViewModel: ObservableObject {
        
        @Published var nutritionFactType: NutritionFactType
        @Published var nutritionFact: NutritionFact?
        @Environment(\.colorScheme) var colorScheme
        
        init(nutritionFactType: NutritionFactType, nutritionFact: NutritionFact? = nil) {
            self.nutritionFactType = nutritionFactType
            self.nutritionFact = nutritionFact
        }
        
        var iconImageName: String {
            switch nutritionFactType {
            case .energy: return "flame.fill"
////            case .macro: return "circle.grid.cross"
////            case .micro: return "circle.hexagongrid"
//            case .energy: return "flame.circle.fill"
            case .macro: return "circle.circle.fill"
            case .micro: return "circle.circle"
            }
        }
        
        var typeName: String {
            nutritionFactType.description
        }
        
        var isEmpty: Bool {
            nutritionFact == nil
        }
        var labelColor: Color {
            isEmpty ? Color(.secondaryLabel) :  nutritionFactType.textColor(for: colorScheme)
        }
        
        var amountColor: Color {
            isEmpty ? Color(.quaternaryLabel) : Color(.label)
        }

        var inputTypeImageName: String? {
            guard let nutritionFact = nutritionFact, nutritionFact.inputType != .manuallyEntered else {
                return nil
            }
            return nutritionFact.inputType.image
        }
        
        var amountString: String {
            guard let nutritionFact = nutritionFact else {
                if case .micro(_) = nutritionFactType {
                    return ""
                } else {
                    return "Required"
                }
            }
            return nutritionFact.amount.cleanAmount
        }
        
        var unitString: String {
            nutritionFact?.unit.description ?? ""
        }
    }
}
extension FoodForm.NutritionFacts.Cell {
    var body: some View {
        content
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
//            disclosureArrow
        }
    }
    
    //MARK: - Components
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: cellViewModel.iconImageName)
                    .font(.system(size: 14))
    //                .imageScale(.small)
                Text(cellViewModel.typeName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            Spacer()
            inputIcon
            disclosureArrow
        }
        .foregroundColor(cellViewModel.labelColor)
    }
    
    var bottomRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(cellViewModel.amountString)
                .foregroundColor(cellViewModel.amountColor)
                .font(.system(size: 28, weight: .medium, design: .rounded))
            Text(cellViewModel.unitString)
//                .font(.headline)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .bold()
                .foregroundColor(Color(.secondaryLabel))
            Spacer()
        }
    }
    
    @ViewBuilder
    var inputIcon: some View {
        if let imageName = cellViewModel.inputTypeImageName {
            Image(systemName: imageName)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
}

public struct NutritionFactsCellPreview: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        NavigationView {
//            form
            scrollView
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.inline)
//            ScrollView {
//                VStack(spacing: 0) {
//                    FoodForm.NutritionFacts.Cell()
//                }
//                .padding(.horizontal, 20)
//            }
//            .background(Color(.systemGroupedBackground))
        }
    }
    
    var form: some View {
        Form {
            Section {
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockEnergyFact)
            }
            Section("Macronutrients") {
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockCarbFact)
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockFatFact)
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockProteinFact)
            }
            Section("Micronutrients") {
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockSaturatedFat)
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockSodium)
                FoodForm.NutritionFacts.Cell(nutritionFactType: .energy, nutritionFact: mockFolate)
            }
            Section {
            }
        }
    }

    var emptyStack: some View {
        LazyVStack(spacing: 0) {
            cell(fact: nil, type: .energy)
            titleCell("Macronutrients")
            cell(fact: nil, type: .macro(.carb))
            cell(fact: nil, type: .macro(.fat))
            cell(fact: nil, type: .macro(.protein))
        }
    }
    
    var filledStack: some View {
        LazyVStack(spacing: 0) {
            cell(fact: mockEnergyFact, type: .energy)
            titleCell("Macronutrients")
            cell(fact: mockCarbFact, type: .macro(.carb))
            cell(fact: mockFatFact, type: .macro(.fat))
            cell(fact: mockProteinFact, type: .macro(.protein))
            titleCell("Micronutrients")
            cell(fact: mockSaturatedFat, type: .micro(.saturatedFat))
            cell(fact: mockSodium, type: .micro(.folate))
            cell(fact: mockFolate, type: .micro(.folate))
        }
    }
    
    var scrollView: some View {
        ScrollView {
            emptyStack
            .padding(.horizontal, 20)
        }
        .background(formBackgroundColor)
    }
    
    func cell(fact nutritionFact: NutritionFact?, type nutritionFactType: NutritionFactType) -> some View {
        FoodForm.NutritionFacts.Cell(nutritionFactType: nutritionFactType, nutritionFact: nutritionFact)
            .padding(.horizontal, 16)
            .padding(.bottom, 13)
            .padding(.top, 13)
            .background(cellBackgroundColor)
            .cornerRadius(10)
            .padding(.bottom, 10)
    }
    
    func titleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 15)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }

    var formBackgroundColor: Color {
        colorScheme == .dark ? .black: Color(.systemGroupedBackground)
//        Color(.systemGroupedBackground)
    }
    
    var cellBackgroundColor: Color {
//        Color(.secondarySystemGroupedBackground)
        colorScheme == .dark ? Color(.systemGroupedBackground) : Color(.secondarySystemGroupedBackground)
    }
    
    public init() { }
}

struct NutritionFactsCell_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsCellPreview()
    }
}

let mockEnergyFact = NutritionFact(
    type: .energy,
    amount: 250,
    unit: .kj,
    inputType: .manuallyEntered
)

let mockCarbFact = NutritionFact(
    type: .macro(.carb),
    amount: 45,
    unit: .g,
    inputType: .manuallyEntered
)

let mockFatFact = NutritionFact(
    type: .macro(.fat),
    amount: 12,
    unit: .g,
    inputType: .manuallyEntered
)

let mockProteinFact = NutritionFact(
    type: .macro(.protein),
    amount: 23,
    unit: .g,
    inputType: .manuallyEntered
)

let mockSaturatedFat = NutritionFact(
    type: .micro(.saturatedFat),
    amount: 6,
    unit: .g,
    inputType: .manuallyEntered
)

let mockSodium = NutritionFact(
    type: .micro(.sodium),
    amount: 1060,
    unit: .mg,
    inputType: .manuallyEntered
)

let mockFolate = NutritionFact(
    type: .micro(.folate),
    amount: 45,
    unit: .g,
    inputType: .manuallyEntered
)

