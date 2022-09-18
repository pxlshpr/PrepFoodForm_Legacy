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
            if let fact = FoodFormViewModel.shared.nutritionFact(for: fact.type) {
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
    
    var shouldShowDeleteButton: Bool {
        if case .micro = type {
            return !amountString.isEmpty
        } else {
            return false
        }
    }

    func showAddButtonIfApplicable() {
        withAnimation {
            self.shouldShowAddButton = isNewMicronutrient && !amountString.isEmpty
        }
    }
    
    func modifyExistingFact() {
        guard !isNewMicronutrient else { return }
        FoodFormViewModel.shared.setNutritionFactType(
            type,
            withAmount: amount,
            unit: unit)
    }
    
    func removeExistingFact() {
        guard !isNewMicronutrient else { return }
        FoodFormViewModel.shared.removeFact(of: type)
    }
    
    func dataDidChange() {
        showAddButtonIfApplicable()
        if amountString.isEmpty {
            removeExistingFact()
        } else {
            modifyExistingFact()
        }
    }
    
    var fact: NutritionFact {
        NutritionFact(type: type, amount: amount, unit: unit, inputType: .manuallyEntered)
    }
    
    func add() {
        FoodFormViewModel.shared.micronutrients.append(fact)
    }
}
