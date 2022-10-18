import SwiftUI
import FoodLabelScanner

extension FoodFormViewModel {
    public func didCapture(_ image: UIImage) {
        dismissWizard()
//        withAnimation {
//            showingWizard = false
//        }

        imageViewModels.append(ImageViewModel(image))
    }
    
    func didScan(_ image: UIImage, scanResult: ScanResult) {
        imageViewModels.append(
            ImageViewModel(image: image, scanResult: scanResult)
        )
        processScanResults()
        imageSetStatus = .scanned
        dismissWizard()
//        withAnimation {
//            showingWizard = false
//        }
    }
    
    public func didPickLibraryImages(numberOfImagesBeingLoaded: Int) {
    }
    
    public func didLoadLibraryImage(_ image: UIImage, at index: Int) {
    }
}
