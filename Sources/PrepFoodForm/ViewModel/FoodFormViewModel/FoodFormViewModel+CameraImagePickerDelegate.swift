import SwiftUI
import CameraImagePicker

extension FoodFormViewModel: CameraImagePickerDelegate {
    public func didCapture(_ image: UIImage) {
        print("didCapture an image")
    }
    
    public func didPickLibraryImages(numberOfImagesBeingLoaded: Int) {
        sourceType = .images
        withAnimation {
//            imageViewModels = Array(repeating: ImageViewModel(), count: numberOfImagesBeingLoaded)
        }
    }
    
    public func didLoadLibraryImage(_ image: UIImage, at index: Int) {
        guard index < imageViewModels.count else {
            return
        }
        print("didLoadLibraryImage at : \(index)")
        withAnimation {
            imageViewModels[index].image = image
        }
    }
}
