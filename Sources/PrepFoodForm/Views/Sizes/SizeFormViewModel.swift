import SwiftUI
import SwiftHaptics

class SizeFormViewModel: ObservableObject {
    @Published var includeServing: Bool
    @Published var allowAddSize: Bool
    @Published var showingVolumePrefix: Bool
    @Published var formState: FormState
    
    
    @Published var showingUnitPickerForVolumePrefix = false
    @Published var showingQuantityForm = false
    @Published var showingNamePicker = false
    @Published var showingAmountForm = false

    init(includeServing: Bool, allowAddSize: Bool, formState: FormState) {
        self.includeServing = includeServing
        self.allowAddSize = allowAddSize
        self.formState = formState
        self.showingVolumePrefix = false
    }
    
    func updateFormState(of sizeViewModel: FieldViewModel, comparedToExisting existingSizeViewModel: FieldViewModel? = nil) {
        let newFormState = sizeViewModel.formState(existingFieldViewModel: existingSizeViewModel)
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

extension FieldViewModel {
    static var emptySize: FieldViewModel {
        .init(fieldValue: .size(.init(size: Size(), fillType: .userInput)))
    }
}
