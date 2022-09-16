import SwiftUI
import PrepUnits

extension FoodForm.NutritionFacts {
    struct Cell: View {
        @Environment(\.colorScheme) var colorScheme
        @StateObject var cellViewModel: ViewModel
        
        init(nutritionFactType: NutritionFactType, nutritionFact: NutritionFact?) {
            let viewModel = ViewModel(nutritionFactType: nutritionFactType, nutritionFact: nutritionFact)
            _cellViewModel = StateObject(wrappedValue: viewModel)
        }
    }
}

extension FoodForm.NutritionFacts.Cell {
    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.bottom, 13)
            .padding(.top, 13)
            .background(cellBackgroundColor)
            .cornerRadius(10)
            .padding(.bottom, 10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    //MARK: - Components
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: cellViewModel.iconImageName)
                    .font(.system(size: 14))
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
                .font(.system(size: cellViewModel.isEmpty ? 20 : 28, weight: .medium, design: .rounded))
            Text(cellViewModel.unitString)
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
    
    var cellBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGroupedBackground) : Color(.secondarySystemGroupedBackground)
    }
}

public struct NutritionFactsCellPreview: View {
    
    @StateObject var viewModel = FoodForm.ViewModel(prefilledWithMockData: true)
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        NavigationView {
            FoodForm.NutritionFacts()
                .environmentObject(viewModel)
        }
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

