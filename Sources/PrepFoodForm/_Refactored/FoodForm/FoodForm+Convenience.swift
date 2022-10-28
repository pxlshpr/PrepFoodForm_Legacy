import Foundation

extension FoodForm {
    var detailsAreEmpty: Bool {
        name.isEmpty && emoji.isEmpty && detail.isEmpty && brand.isEmpty
    }
}
