import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import PhotosUI

extension FoodForm {

    func appeared() {
        sources.didScanAllPickedImages = didScanAllPickedImages
        
        if shouldShowWizard {
            withAnimation(WizardAnimation) {
                formDisabled = true
                showingWizard = true
                shouldShowWizard = false
            }
        } else {
            showingWizard = false
            showingWizardOverlay = false
            formDisabled = false
        }
    }
    
    //MARK: - Scanning
    
    func didReceiveScanFromFoodLabelCamera(_ scanResult: ScanResult, image: UIImage) {
        sources.add(image, with: scanResult)
        extractAndFillFieldValuesFromScanResults()
    }
    
    func didScanAllPickedImages() {
        extractAndFillFieldValuesFromScanResults()
    }
    
    func extractAndFillFieldValuesFromScanResults() {
        Task {
            guard let fieldValues = await sources.tryExtractFieldsFromScanResults() else {
                return
            }
            didExtractFieldValues(fieldValues)
        }
    }
    
    func didExtractFieldValues(_ fieldValues: [FieldValue]) {
        fields.handleExtractedFieldsValues(fieldValues)
        sources.imageSetStatus = .scanned(
            numberOfImages: sources.imageViewModels.count,
//            counts: fields.dataPointsCount //TODO: Do this
            counts: DataPointsCount(total: 0, autoFilled: 0, selected: 0, barcodes: 0)
        )
    }
    

    //MARK: - Sources
    func tappedAddSource() {
        showingSourcesMenu = true
    }
    
    func handleSourcesAction(_ action: SourcesAction) {
        switch action {
        case .removeLink:
            showingConfirmRemoveLinkMenu = true
        case .addLink:
            showingAddLinkMenu = true
        case .showPhotosMenu:
            showingPhotosMenu = true
        case .removeImage(index: let index):
            resetFillForFieldsUsingImage(at: index)
            sources.removeImage(at: index)
        }
    }
    
    /// Change all `.scanned` and `.selection` autofills that depend on this to `.userInput`
    //TODO: Move this to a Fields
    func resetFillForFieldsUsingImage(at index: Int) {
//        guard index < imageViewModels.count else {
//            return
//        }
//
//        let id = imageViewModels[index].id
//
//        /// Selectively reset fills for fields that are using this image
//        for fieldViewModel in allFieldViewModels {
//            fieldViewModel.registerDiscardScanIfUsingImage(withId: id)
//        }
//
//        /// Now remove the saved scanned field values that are also using this image
//        scannedFieldValues = scannedFieldValues.filter {
//            !$0.fill.usesImage(with: id)
//        }
    }

    //MARK: - Wizard Actions
    func tappedWizardButton(_ button: WizardButton) {
        Haptics.feedback(style: .soft)
        dismissWizard()
        switch button {
        case .background, .startWithEmptyFood:
            break
//            dismissWizard()
        case .takePhotos:
            showingCamera = true
        case .scanAFoodLabel:
            showingFoodLabelCamera = true
        case .choosePhotos:
            showingPhotosPicker = true
        case .prefill:
            showingPrefill = true
        case .prefillInfo:
            showingPrefillInfo = true
        }
    }
    
    func dismissWizard() {
        withAnimation(WizardAnimation) {
            showingWizard = false
        }
        withAnimation(.easeOut(duration: 0.1)) {
            showingWizardOverlay = false
        }
        formDisabled = false
    }
}
