import SwiftUI
import FoodLabelScanner
import VisionSugar

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
    
    func didScan(_ barcodes: [RecognizedBarcode], on image: UIImage) {
        //TODO: Create a new .barcodeScanned Fill with a recognizedBarcode and an imageId
        for barcode in barcodes {
            let fieldViewModel = FieldViewModel(fieldValue:
                    .barcode(FieldValue.BarcodeValue(
                        payloadString: barcode.string,
                        symbology: barcode.symbology,
                        fill: .userInput
                    ))
            )
            addBarcodeViewModel(fieldViewModel)
        }
        imageSetStatus = .scanning
        imageViewModels.append(ImageViewModel(image))
    }
    
    public func didPickLibraryImages(numberOfImagesBeingLoaded: Int) {
    }
    
    public func didLoadLibraryImage(_ image: UIImage, at index: Int) {
    }
}
