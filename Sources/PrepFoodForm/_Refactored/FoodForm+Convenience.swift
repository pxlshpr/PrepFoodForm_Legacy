import Foundation

extension FoodForm {
    var shouldShowFoodLabel: Bool {
        !energy.isEmpty
    }
    
    var energy: FieldValue {
        fieldValues[0]
    }
}
