import SwiftUI

extension FoodForm.Fields {
    
    func updateShouldShowFoodLabel() {
        shouldShowFoodLabel = (
            !energy.value.isEmpty
            && !carb.value.isEmpty
            && !fat.value.isEmpty
            && !protein.value.isEmpty
        )
    }
    
    func updateShouldShowDensitiesSection() {
        withAnimation {
            shouldShowDensitiesSection =
            (amount.value.doubleValue.unit.isMeasurementBased && (amount.value.doubleValue.double ?? 0) > 0)
            ||
            (serving.value.doubleValue.unit.isMeasurementBased && (serving.value.doubleValue.double ?? 0) > 0)
        }
    }

}
