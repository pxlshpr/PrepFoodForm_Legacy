import SwiftUI
import SwiftHaptics

class SizeFormViewModel: ObservableObject {
    @Published var includeServing: Bool
    @Published var allowAddSize: Bool
    @Published var showingVolumePrefix: Bool
    @Published var formState: FormState
    
    init(includeServing: Bool, allowAddSize: Bool, formState: FormState) {
        self.includeServing = includeServing
        self.allowAddSize = allowAddSize
        self.formState = formState
        self.showingVolumePrefix = false
    }
    
    func updateFormState(of sizeViewModel: FieldValueViewModel, comparedToExisting existingSizeViewModel: FieldValueViewModel? = nil) {
        let newFormState = sizeViewModel.formState(existingFieldValueViewModel: existingSizeViewModel)
        guard self.formState != newFormState else {
            return
        }
        
        let animation = Animation.interpolatingSpring(
            mass: 0.5,
            stiffness: 220,
            damping: 10,
            initialVelocity: 2
        )

        withAnimation(animation) {
//        withAnimation(.easeIn(duration: 4)) {
            self.formState = newFormState
            print("Updated form state from \(self.formState) to \(newFormState)")

            switch formState {
            case .okToSave:
                Haptics.successFeedback()
            case .invalid:
                Haptics.errorFeedback()
            case .duplicate:
                Haptics.warningFeedback()
            default:
                break
            }
        }
    }
}

extension FieldValueViewModel {
    static var emptySize: FieldValueViewModel {
        .init(fieldValue: .size(.init(size: Size(), fillType: .userInput)))
    }
}
