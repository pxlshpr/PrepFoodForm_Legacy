import SwiftUI

extension FoodForm.NutritionFacts.FactForm {
    class ViewModel: ObservableObject {
        
        let type: NutritionFactType
        let isNewMicronutrient: Bool
        
        @Published var amountString: String
        @Published var unit: NutritionFactUnit

        @Published var shouldShowAddButton: Bool

        init(fact: NutritionFact, isNewMicronutrient: Bool = false) {
            
            self.type = fact.type
            self.isNewMicronutrient = isNewMicronutrient
            
            let amountString: String
            if let fact = FoodForm.ViewModel.shared.nutritionFact(for: fact.type) {
                amountString = fact.amount?.cleanAmount ?? ""
                self.unit = fact.unit ?? fact.type.defaultUnit
            } else {
                amountString = fact.amount?.cleanAmount ?? ""
                self.unit = fact.unit ?? fact.type.defaultUnit
            }
            self.amountString = amountString
            self.shouldShowAddButton = isNewMicronutrient && !amountString.isEmpty
        }
    }
}

extension FoodForm.NutritionFacts.FactForm.ViewModel {
    var amount: Double {
        Double(amountString) ?? 0
    }
    
    func dataDidChange() {
        withAnimation {
            self.shouldShowAddButton = isNewMicronutrient && !amountString.isEmpty
        }
        guard !isNewMicronutrient else { return }
        FoodForm.ViewModel.shared.setNutritionFactType(
            type,
            withAmount: amount,
            unit: unit)
    }
    
    var fact: NutritionFact {
        NutritionFact(type: type, amount: amount, unit: unit, inputType: .manuallyEntered)
    }
    
    func add() {
        FoodForm.ViewModel.shared.micronutrients.append(fact)
    }
}
