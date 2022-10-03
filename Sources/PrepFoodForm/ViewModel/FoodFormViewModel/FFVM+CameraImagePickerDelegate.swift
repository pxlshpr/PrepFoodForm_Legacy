import SwiftUI

extension FoodFormViewModel {
    public func didCapture(_ image: UIImage) {
        sourceType = .images
        
//        showingCameraImagePicker = false
        withAnimation {
            showingWizard = false
        }

        imageViewModels.append(ImageViewModel(image))
    }
    
    public func didPickLibraryImages(numberOfImagesBeingLoaded: Int) {
    }
    
    public func didLoadLibraryImage(_ image: UIImage, at index: Int) {
    }
}
