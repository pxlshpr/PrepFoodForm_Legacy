import SwiftUI
import SwiftHaptics
import FoodLabelScanner

extension FoodForm {

    func appeared() {
        func appeared() {
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
    }
    
    //MARK: - Handlers
    func receivedScanResult(_ scanResult: ScanResult, for image: UIImage) {
        let imageViewModel = ImageViewModel(image: image, scanResult: scanResult)
        imageViewModels.append(imageViewModel)
        processScanResults()
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
