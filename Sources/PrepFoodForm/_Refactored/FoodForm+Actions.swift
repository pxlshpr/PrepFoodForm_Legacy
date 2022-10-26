import SwiftUI
import SwiftHaptics

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
    
    func dismissWizard() {
        withAnimation(WizardAnimation) {
            showingWizard = false
        }
        withAnimation(.easeOut(duration: 0.1)) {
            showingWizardOverlay = false
        }
        formDisabled = false
    }
    
    func startWithEmptyFood() {
        Haptics.feedback(style: .soft)
        dismissWizard()
    }
}
