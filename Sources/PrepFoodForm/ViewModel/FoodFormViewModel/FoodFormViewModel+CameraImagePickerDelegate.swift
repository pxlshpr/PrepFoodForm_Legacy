import SwiftUI
import CameraImagePicker

extension FoodFormViewModel: CameraImagePickerDelegate {
    public func didCapture(_ image: UIImage) {
        print("didCapture an image")
    }
    
    public func didPickLibraryImages(numberOfImagesBeingLoaded: Int) {
        sourceType = .images
        withAnimation {
            sourceImageViewModels = Array(repeating: SourceImageViewModel(), count: numberOfImagesBeingLoaded)
        }
    }
    
    public func didLoadLibraryImage(_ image: UIImage, at index: Int) {
        guard index < sourceImageViewModels.count else {
            return
        }
        print("didLoadLibraryImage at : \(index)")
        withAnimation {
            sourceImageViewModels[index].image = image
        }
    }
}
