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

    @Published var prefillUrl: String? = nil

    init(fieldValue: FieldValue) {
        self.fieldValue = fieldValue
        
        if fieldValue.fill.isPrefill {
            self.prefillUrl = FoodFormViewModel.shared.prefilledFood?.sourceUrl
        }
    }
    
    var copy: FieldViewModel {
        let new = FieldViewModel(fieldValue: fieldValue)
        new.copyData(from: self)
        return new
    }
    
    func copyData(from fieldViewModel: FieldViewModel) {
        fieldValue = fieldViewModel.fieldValue
        
        if fieldValue.fill.usesImage {
            continueCroppingImageIfNeeded(for: fieldViewModel)
        } else if fieldValue.fill.isPrefill {
            prefillUrl = FoodFormViewModel.shared.prefilledFood?.sourceUrl
        }
    }
    
    func continueCroppingImageIfNeeded(for fieldViewModel: FieldViewModel) {
        /// If the the image is still being cropped (during a copy)—do the crop ourselves instead of setting it here incorrectly
        if fieldViewModel.isCroppingNextImage {
            isCroppingNextImage = true
            cropFilledImage()
        } else {
            imageToDisplay = fieldViewModel.imageToDisplay
            isCroppingNextImage = false
        }
    }
    
    func registerUserInput() {
        fieldValue.fill = .userInput
        imageToDisplay = nil
    }
    
    func cropFilledImage() {
        guard fieldValue.fill.usesImage else {
            withAnimation {
                imageToDisplay = nil
            }
            return
        }
        Task {
            guard let croppedImage = await FoodFormViewModel.shared.croppedImage(for: fieldValue.fill) else {
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
    
//    func changeFillType(to fill: FillType) {
//        print("🔘 🔒 isFilling set to true for: \(fieldValue.description)")
//        isFilling = true
//
//        fieldValue.fill = fill
//        switch fill {
//        case .selection(let text, let scanResultId, let supplementaryTexts, let value):
//            break
//        case .scanResult(let valueText, scanResultId: _, value: let value):
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

extension FieldViewModel {
    func contains(_ imageText: ImageText) -> Bool {
        guard case .selection(let info) = fieldValue.fill else {
            return false
        }
        return info.imageTexts.contains(imageText)
    }
    
    func contains(_ fieldString: PrefillFieldString) -> Bool {
        guard case .prefill(let info) = fieldValue.fill else {
            return false
        }
        return info.fieldStrings.contains(fieldString)
    }
    
    func replaceExistingImageText(with imageText: ImageText) {
        guard case .selection(let info) = fieldValue.fill else {
            return
        }
        var newInfo = info
        for i in newInfo.imageTexts.indices {
            if newInfo.imageTexts[i].text == imageText.text {
                newInfo.imageTexts[i].pickedCandidate = imageText.pickedCandidate
            }
        }
        fieldValue.fill = .selection(newInfo)
    }
    
    func imageTextMatchingText(of imageText: ImageText) -> ImageText? {
        nil
    }
    
    func toggle(_ imageText: ImageText) {
        if contains(imageText) {
            fieldValue.fill.removeImageText(imageText)
        } else {
            replaceExistingImageText(with: imageText)
        }
    }
    
    func toggle(_ fieldString: PrefillFieldString) {
        if contains(fieldString) {
            fieldValue.fill.removePrefillFieldString(fieldString)
        } else {
            fieldValue.fill.appendPrefillFieldString(fieldString)
        }
    }

}

