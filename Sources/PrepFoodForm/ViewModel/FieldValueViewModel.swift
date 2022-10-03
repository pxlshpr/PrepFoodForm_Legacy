import SwiftUI
import FoodLabelScanner

class FieldValueViewModel: ObservableObject {
    @Published var showingImageTextPicker: Bool = false
    @Published var imageToDisplay: UIImage? = nil
    @Published var shouldShowImage: Bool = false

    @Published var fieldValue: FieldValue

    /** Indicates that the `fieldValue` is being filled behind-the-scenes and any changes shouldn't be registered as a `FillType.userInput` while this is set to `true`.*/
    @Published var isFilling: Bool = false
    
    //TODO: Remove this
    @Published var ignoreNextChange: Bool = false

    init(fieldValue: FieldValue) {
        self.fieldValue = fieldValue
    }
    
    func cropFilledImage() {
        guard fieldValue.fillType.usesImage else {
            withAnimation {
                imageToDisplay = nil
                shouldShowImage = false
            }
            return
        }
        Task {
            guard let croppedImage = await FoodFormViewModel.shared.croppedImage(for: fieldValue.fillType) else {
                print("⚠️ Couldn't get cropped image for: \(self.fieldValue.description)")
                return
            }

            await MainActor.run {
                withAnimation {
                    print("✂️ Got cropped image for: \(self.fieldValue.description)")
                    self.imageToDisplay = croppedImage
                    self.shouldShowImage = true
                }
            }
        }
    }
    
//    func changeFillType(to fillType: FillType) {
//        print("🔘 🔒 isFilling set to true for: \(fieldValue.description)")
//        isFilling = true
//
//        fieldValue.fillType = fillType
//        switch fillType {
//        case .imageSelection(let text, let scanResultId, let supplementaryTexts, let value):
//            break
//        case .imageAutofill(let valueText, scanResultId: _, value: let value):
//            changeFillTypeToAutofill(of: valueText, withAltValue: value)
//        default:
//            break
//        }
//
//        isFilling = false
//        print("🔘 🔓 isFilling set to false for: \(fieldValue.description)")
//    }
    
//    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: Value?) {
//        guard let altValue else {
//            fieldValue.double = valueText.value.amount
//            fieldValue.nutritionUnit = valueText.value.unit
//            return
//        }
//        fieldValue.double = altValue.amount
//        fieldValue.nutritionUnit = altValue.unit
//    }
}
