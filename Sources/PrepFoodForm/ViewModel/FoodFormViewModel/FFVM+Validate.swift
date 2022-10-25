import Foundation
import PrepDataTypes

extension FoodFormViewModel {
    
    var shouldShowSaveButtons: Bool {
        false
    }
    
    var shouldShowSavePublicButton: Bool {
        //TODO: only show if user includes a valid source
        true
    }
}
