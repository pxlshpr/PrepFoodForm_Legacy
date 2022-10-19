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
        let imageViewModel = ImageViewModel(image)
//        var didAddABarcode = false
        for barcode in barcodes {
            let fieldViewModel = FieldViewModel(fieldValue:
                    .barcode(FieldValue.BarcodeValue(
                        payloadString: barcode.string,
                        symbology: barcode.symbology,
                        fill: .barcodeScanned(
                            ScannedFillInfo(
                                recognizedBarcode: barcode,
                                imageId: imageViewModel.id)
                        )
                    ))
            )
//            didAddABarcode = add(barcodeViewModel: fieldViewModel)
            let _ = add(barcodeViewModel: fieldViewModel)
        }
//        if didAddABarcode {
//            imageSetStatus = .scanning
//            imageViewModels.append(imageViewModel)
//        }
    }
    
    public func didPickLibraryImages(numberOfImagesBeingLoaded: Int) {
    }
    
    public func didLoadLibraryImage(_ image: UIImage, at index: Int) {
    }
}
