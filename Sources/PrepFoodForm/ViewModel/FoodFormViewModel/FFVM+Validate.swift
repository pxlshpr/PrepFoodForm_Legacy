import Foundation
import PrepDataTypes

extension FoodFormViewModel {
    
    var shouldShowSaveButtons: Bool {
        var isValid: Bool?
        do {
            isValid = try userFoodCreateForm?.validate()
        } catch {
            print("🧼 Form validation error: \(error)")
        }
        return isValid ?? false
    }
    
    var shouldShowSavePublicButton: Bool {
        imageViewModels.contains(where: { $0.scanResult != nil })
        ||
        linkInfo != nil
    }
}
