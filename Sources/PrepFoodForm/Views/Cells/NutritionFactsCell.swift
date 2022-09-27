import SwiftUI
import PrepUnits
import FoodLabel

extension FoodForm {
    struct NutritionFactsCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
        
        @State var energyInCalories: Bool = true
    }
}

extension FoodForm.NutritionFactsCell {
    
    var body: some View {
        Group {
            if !viewModel.hasNutritionFacts {
                emptyContent
            } else {
                foodLabel
//                legacyContent
            }
        }
    }
    
    var emptyContent: some View {
        Text("Required")
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var foodLabel: some View {
        FoodLabel(dataSource: viewModel)
    }
}

extension FoodFormViewModel: FoodLabelDataSource {
    public var nutrients: [NutrientType : Double] {
        var nutrients: [NutrientType : Double] = [:]
        for (_, array) in micronutrients {
            for fieldValue in array {
                guard let nutrientType = fieldValue.identifier.nutrientType else {
                    continue
                }
                nutrients[nutrientType] = fieldValue.identifier.double
            }
        }
        return nutrients
    }
    
    public var showFooterText: Bool {
        false
    }
    
    public var showRDAValues: Bool {
        false
    }
    
    public var amountPerString: String {
        return "1 serving"
    }
    
    public var carbAmount: Double {
        carb.identifier.double ?? 0
    }
    
    public var proteinAmount: Double {
        protein.identifier.double ?? 0
    }
    
    public var fatAmount: Double {
        fat.identifier.double ?? 0
    }
    
    public var energyAmount: Double {
        energy.identifier.double ?? 0
    }
}

//MARK: - Preview

public struct NutritionFactsCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                    } label: {
                        FoodForm.NutritionFactsCell()
                            .environmentObject(viewModel)
                    }
                }
            }
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.previewPrefill()
    }
}
struct NutritionFactsCell_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsCellPreview()
    }
}

extension FoodForm.NutritionFactsCell {
    struct Row: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
        var fact: NutritionFact
    }
}

extension FoodForm.NutritionFactsCell.Row {
    
    var body: some View {
        HStack {
            Text(fact.type.description)
                .bold(fact.type == .energy)
//                .foregroundColor(fact.type.textColor(for: colorScheme))
//                .bold()
                .foregroundColor(.primary)
            Spacer()
            if let amountDescription = fact.amountDescription {
                Text(amountDescription)
//                    .foregroundColor(fact.type.textColor(for: colorScheme))
                    .foregroundColor(Color(.secondaryLabel))
                    .bold(fact.type == .energy)
            }
        }
    }
}
