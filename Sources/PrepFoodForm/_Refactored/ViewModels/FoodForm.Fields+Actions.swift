import Foundation

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
