import SwiftUI
import FoodLabelScanner

class FieldViewModel: ObservableObject, Identifiable {
    @Published var id = UUID()
    @Published var fieldValue: FieldValue
    
    @Published var imageToDisplay: UIImage? = nil
    @Published var isCroppingNextImage: Bool = false

    init(fieldValue: FieldValue) {
        self.fieldValue = fieldValue
    }
    
    func fillScannedFieldValue(_ fieldValue: FieldValue) {
        self.fieldValue = fieldValue
        resetAndCropImage()
    }

    //MARK: - Fill Manipulation
    
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
    
    //MARK: - Image Cropping
    func resetAndCropImage() {
        imageToDisplay = nil
        isCroppingNextImage = true
        cropFilledImage()
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
    
    //MARK: - Copying
    
    var copy: FieldViewModel {
        let new = FieldViewModel(fieldValue: fieldValue)
        new.copyData(from: self)
        return new
    }
    
    func copyData(from fieldViewModel: FieldViewModel) {
        fieldValue = fieldViewModel.fieldValue
        
        if fieldValue.fill.usesImage {
            /// If the the image is still being cropped—do the crop ourselves instead of setting it here incorrectly
            if fieldViewModel.isCroppingNextImage {
                isCroppingNextImage = true
                cropFilledImage()
            } else {
                imageToDisplay = fieldViewModel.imageToDisplay
                isCroppingNextImage = false
            }

        } else if fieldValue.fill.isPrefill {
//            prefillUrl = FoodFormViewModel.shared.prefilledFood?.sourceUrl
        }
    }
    
    //MARK: - Convenience
    
    var isValid: Bool {
        switch fieldValue {
        case .size(let sizeValue):
            return sizeValue.size.isValid
        default:
            return false
        }
    }
    
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
//        && lhs.prefillUrl == rhs.prefillUrl
//        && lhs.isPrefilled == rhs.isPrefilled
    }
}
