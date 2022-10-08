import SwiftUI
import FoodLabelScanner

extension FieldViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(fieldValue)
        hasher.combine(imageToDisplay)
        hasher.combine(isCroppingNextImage)
    }
}

extension FieldViewModel: Equatable {
    static func ==(lhs: FieldViewModel, rhs: FieldViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class FieldViewModel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var fieldValue: FieldValue
    @Published var imageToDisplay: UIImage? = nil
    @Published var isCroppingNextImage: Bool = false

    init(fieldValue: FieldValue) {
        self.fieldValue = fieldValue
    }
    
    var copy: FieldViewModel {
        let new = FieldViewModel(fieldValue: fieldValue)
        new.copyData(from: self)
        return new
    }
    
    func copyData(from fieldViewModel: FieldViewModel) {
        fieldValue = fieldViewModel.fieldValue
        
        /// If the the image is still being cropped—do the crop ourselves instead of setting it here incorrectly
        if fieldViewModel.isCroppingNextImage {
            isCroppingNextImage = true
            cropFilledImage()
        } else {
            imageToDisplay = fieldViewModel.imageToDisplay
            isCroppingNextImage = false
        }
    }
    
    func registerUserInput() {
        fieldValue.fillType = .userInput
        imageToDisplay = nil
    }
    
    func cropFilledImage() {
        guard fieldValue.fillType.usesImage else {
            withAnimation {
                imageToDisplay = nil
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
                    self.isCroppingNextImage = false
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

extension FieldViewModel {
    var isValid: Bool {
        switch fieldValue {
        case .size(let sizeValue):
            return sizeValue.size.isValid
        default:
            return false
        }
    }
}
