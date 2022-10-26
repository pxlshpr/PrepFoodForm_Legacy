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
    
    var shouldShowSavePublicButton: Bool {
        haveSourceImages || haveSourceLink
    }
    
    var haveSourceImages: Bool {
        imageViewModels.contains(where: { $0.scanResult != nil })
    }
    
    var haveSourceLink: Bool {
        linkInfo != nil
    }
}
