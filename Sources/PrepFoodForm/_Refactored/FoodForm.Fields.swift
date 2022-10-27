import SwiftUI
import FoodLabel
import PrepDataTypes

extension FoodForm {
    class Fields: ObservableObject {
        @Published var energy: Field
        @Published var carb: Field
        @Published var fat: Field
        @Published var protein: Field
        @Published var shouldShowFoodLabel: Bool = false
        init() {
            self.energy = .init(fieldValue: .energy())
            self.carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
            self.fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
            self.protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
        }
    }
}

extension FoodForm.Fields {
    func handleExtractedFieldsValues(_ fieldValues: [FieldValue]) {
        for fieldValue in fieldValues {
            if fieldValue.isEnergy {
                energy.value = fieldValue
            }
            if fieldValue.isMacro {
                let macro = fieldValue.macroValue.macro
                switch macro {
                case .carb:
                    carb.value = fieldValue
                case .fat:
                    protein.value = fieldValue
                case .protein:
                    fat.value = fieldValue
                }
            }
        }
        
        updateShouldShowFoodLabel()
        
        print("Got \(fieldValues.count) fieldValues to fill in")
        print("We here")
    }
}

extension FoodForm.Fields {
    
    func updateShouldShowFoodLabel() {
        shouldShowFoodLabel = (
            !energy.value.isEmpty
            && !carb.value.isEmpty
            && !fat.value.isEmpty
            && !protein.value.isEmpty
        )
    }
}
