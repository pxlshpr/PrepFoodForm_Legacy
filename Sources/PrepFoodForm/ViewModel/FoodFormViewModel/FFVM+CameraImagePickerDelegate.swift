import SwiftUI

extension FoodFormViewModel {
    public func didCapture(_ image: UIImage) {
//        sourceType = .images
        
//        showingCamera = false
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
