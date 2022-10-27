import Foundation

extension FoodForm {
    var shouldShowFoodLabel: Bool {
        !energy.isEmpty
    }
}
