import SwiftUI
import PrepDataTypes
import FoodLabelScanner
import PhotosUI

extension FoodFormViewModel {
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item)
            imageViewModels.append(imageViewModel)
        }
        selectedPhotos = []
        
        if showingWizard {
            dismissWizard()
        }
    }

    func croppedImage(for fill: Fill) async -> UIImage? {
        guard let resultId = fill.imageId,
              let boundingBoxToCrop = fill.boundingBoxToCrop,
              let image = image(for: resultId)
        else {
            return nil
        }
        
        return await image.cropped(boundingBox: boundingBoxToCrop)
    }
    
    func image(for id: UUID) -> UIImage? {
        for imageViewModel in imageViewModels {
            if imageViewModel.id == id {
//            if imageViewModel.scanResult?.id == scanResultId {
                return imageViewModel.image
            }
        }
        return nil
    }
}
