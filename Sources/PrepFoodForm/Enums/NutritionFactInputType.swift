import Foundation

enum NutritionFactInputType: Hashable {
    /// When user manually inputs the value by means of the keyboard, copy-pasting, etc.
    case manuallyEntered
    
    /// When the user opts for using the value filled in via the classifier
    case filledIn
    
    /// When the user selects a different recognized text of the image from what was chosen to be filled in with
    case selected
    
    var image: String {
        switch self {
        case .manuallyEntered: return "keyboard"
        case .filledIn: return "text.viewfinder"
        case .selected: return "rectangle.and.hand.point.up.left.filled"
        }
    }
}
