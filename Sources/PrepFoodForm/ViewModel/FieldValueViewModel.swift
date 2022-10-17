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
//        lhs.hashValue == rhs.hashValue
        lhs.id == rhs.id
        && lhs.fieldValue == rhs.fieldValue
        && lhs.imageToDisplay == rhs.imageToDisplay
        && lhs.isCroppingNextImage == rhs.isCroppingNextImage
        && lhs.prefillUrl == rhs.prefillUrl
        && lhs.isPrefilled == rhs.isPrefilled
    }
}

class FieldViewModel: ObservableObject, Identifiable {
    @Published var id = UUID()
    @Published var fieldValue: FieldValue {
        didSet {
           withAnimation {
                isPrefilled = fieldValue.fill.isPrefill
            }
        }
    }
    @Published var imageToDisplay: UIImage? = nil
    @Published var isCroppingNextImage: Bool = false

    //TODO: Don't store this here, we only need one copy if FFVM
    @Published var prefillUrl: String? = nil
    @Published var isPrefilled: Bool = false

    func fillScannedFieldValue(_ fieldValue: FieldValue) {
        self.fieldValue = fieldValue
        resetAndCropImage()
    }
    
    func resetAndCropImage() {
        prefillUrl = nil
        isPrefilled = false
        imageToDisplay = nil
        
        isCroppingNextImage = true
        cropFilledImage()
    }
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
    
    func registerDiscardedScan() {
        fieldValue.fill = .discardable
        imageToDisplay = nil
    }
    
    func registerDiscardScanIfUsingImage(withId id: UUID) {
        if fieldValue.fill.usesImage(with: id) {
            registerDiscardedScan()
        }
    }
    
    func assignNewScannedFill(_ fill: Fill) {
        let previousFill = fieldValue.fill
        fieldValue.fill = fill

        if fill.text?.id != previousFill.text?.id {
            isCroppingNextImage = true
            cropFilledImage()
        }
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

//            try await sleepTask(2)
            
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
    
    func contains(_ fieldString: PrefillFieldString) -> Bool {
        guard case .prefill(let info) = fieldValue.fill else {
            return false
        }
        return info.fieldStrings.contains(fieldString)
    }
    
    func imageTextMatchingText(of imageText: ImageText) -> ImageText? {
        nil
    }
    
    func toggleComponentText(_ componentText: ComponentText) {
        if fieldValue.contains(componentText: componentText) {
            fieldValue.fill.removeComponentText(componentText)
        } else {
            fieldValue.fill.appendComponentText(componentText)
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

