import SwiftUI
import PrepDataTypes

extension FoodFormViewModel {
    
    var rawData: FoodFormRawData? {
        FoodFormRawData(self)
    }
    
    var images: [UUID: UIImage] {
        [:]
    }
    
    var isValid: Bool {
        guard !nameViewModel.string.isEmpty else {
            return false
        }
        
        return true
    }
    
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
