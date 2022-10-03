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
        for (_, fieldValueViewModels) in micronutrients {
            for fieldValueViewModel in fieldValueViewModels {
                guard case .micro = fieldValueViewModel.fieldValue else {
                    continue
                }
                nutrients[fieldValueViewModel.fieldValue.microValue.nutrientType] = fieldValueViewModel.fieldValue.double
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
        amountDescription
    }
    
    public var carbAmount: Double {
        carbViewModel.fieldValue.double ?? 0
    }
    
    public var proteinAmount: Double {
        proteinViewModel.fieldValue.double ?? 0
    }
    
    public var fatAmount: Double {
        fatViewModel.fieldValue.double ?? 0
    }
    
    public var energyAmount: Double {
        energyViewModel.fieldValue.double ?? 0
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
