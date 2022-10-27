import SwiftUI
import FoodLabel
import PrepDataTypes

extension FoodForm {
    class FieldsViewModel: ObservableObject {
        @Published var energyViewModel: FieldViewModel
        
        init() {
            self.energyViewModel = .init(fieldValue: .energy())
        }
    }
}

extension FoodForm.FieldsViewModel {
    var hasNutritionFacts: Bool {
        !energyViewModel.fieldValue.isEmpty
    }
}

extension FoodForm.FieldsViewModel: FoodLabelDataSource {
    var energyValue: FoodLabelValue {
        energyViewModel.fieldValue.value ?? .init(amount: 0, unit: .kcal)
    }
    
    var carbAmount: Double {
        0
    }
    
    var fatAmount: Double {
        0
    }
    
    var proteinAmount: Double {
        0
    }
    
    var nutrients: [PrepDataTypes.NutrientType : Double] {
        [:]
    }
    
    var amountPerString: String {
        "serving"
    }
    
    var showFooterText: Bool {
        false
    }
    
    var showRDAValues: Bool {
        false
    }

    var allowTapToChangeEnergyUnit: Bool {
        false
    }
}
