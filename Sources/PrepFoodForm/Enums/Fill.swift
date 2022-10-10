import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit
import PrepUnits

struct ImageText: Hashable {
    let text: RecognizedText
    let attributeText: RecognizedText?
    let imageId: UUID
    var pickedCandidate: String?
    
    init(text: RecognizedText, attributeText: RecognizedText? = nil, imageId: UUID, pickedCandidate: String? = nil) {
        self.text = text
        self.imageId = imageId
        self.attributeText = attributeText
        self.pickedCandidate = pickedCandidate
    }
    
    init(valueText: ValueText, imageId: UUID, pickedCandidate: String? = nil) {
        self.text = valueText.text
        self.attributeText = valueText.attributeText
        self.imageId = imageId
        self.pickedCandidate = pickedCandidate
    }
    
    var withoutPickedCandidate: ImageText {
        var newImageText = self
        newImageText.pickedCandidate = nil
        return newImageText
    }
}

struct ScannedFillInfo: Hashable {
    var imageText: ImageText
    var value: FoodLabelValue?
    var altValue: FoodLabelValue? = nil
    
    init(resultText: ImageText, value: FoodLabelValue? = nil, altValue: FoodLabelValue? = nil) {
        self.value = value
        self.imageText = resultText
        self.altValue = altValue
    }
    
    init(valueText: ValueText, imageId: UUID, altValue: FoodLabelValue? = nil) {
        self.value = valueText.value
        self.imageText = ImageText(valueText: valueText, imageId: imageId)
        self.altValue = altValue
    }
    
    func withAltValue(_ value: FoodLabelValue) -> ScannedFillInfo {
        var newInfo = self
        newInfo.altValue = value
        return newInfo
    }
}

struct SelectionFillInfo: Hashable {
    var imageTexts: [ImageText]
    var altValue: FoodLabelValue? = nil
    
    func withAltValue(_ value: FoodLabelValue) -> SelectionFillInfo {
        var newInfo = self
        newInfo.altValue = value
        return newInfo
    }
    
    var concatenated: String {
        imageTexts
            .map { $0.pickedCandidate ?? $0.text.string }
            .map { $0.capitalized }
            .joined(separator: ", ")
    }
}

struct PrefillFieldString: Hashable {
    let string: String
    let field: PrefillField
}

struct PrefillFillInfo: Hashable {
    var fieldStrings: [PrefillFieldString] = []
    
    
    var concatenated: String {
        fieldStrings
            .map { $0.string.capitalized }
            .joined(separator: ", ")
    }
}

enum Fill: Hashable {
    
    case scanned(ScannedFillInfo)
    case selection(SelectionFillInfo)
    
    case prefill(PrefillFillInfo = .init())
    case userInput
    case calculated
    case barcodeScan
}

extension Fill {
    
    struct SystemImage {
        static let scanned = "text.viewfinder"
        static let selection = "hand.tap"
        static let prefill = "link"
        static let userInput = "keyboard"
        static let calculated = "function"
        static let barcodeScan = "barcode.viewfinder"
    }
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return SystemImage.userInput
        case .selection:
            return SystemImage.selection
        case .calculated:
            return SystemImage.calculated
        case .scanned:
            return SystemImage.scanned
        case .prefill:
            return SystemImage.prefill
        case .barcodeScan:
            return SystemImage.barcodeScan
        }
    }
    
    var buttonSystemImage: String {
        iconSystemImage
        //        switch self {
        //        case .userInput:
        //            return "circle.dashed"
        //        case .selection:
        //            return "hand.tap"
        //        case .scanResult:
        //            return "viewfinder.circle.fill"
        //        case .prefill:
        //            return "link"
        //        case .barcodeScan:
        //            return "viewfinder.circle.fill"
        //        }
    }
    
    var sectionHeaderString: String {
        switch self {
        case .prefill:
            return "Copied from third-pary food"
        case .scanned:
            return "Auto-filled from image"
        case .calculated:
            return "Calculated"
        case .selection:
            return "Selected from image"
        case .userInput:
            //            if !fieldValue.isEmpty {
            //                return "Manually entered"
            //            }
            return ""
        default:
            break
        }
        return ""
    }
    
    var isCalculated: Bool {
        switch self {
        case .calculated:
            return true
        default:
            return false
        }
    }
    
    var isPrefill: Bool {
        switch self {
        case .prefill:
            return true
        default:
            return false
        }
    }
    
    var isImageAutofill: Bool {
        switch self {
        case .scanned:
            return true
        default:
            return false
        }
    }
    
    var usesImage: Bool {
        switch self {
        case .selection, .scanned:
            return true
        default:
            return false
        }
    }
    
    var isImageSelection: Bool {
        switch self {
        case .selection:
            return true
        default:
            return false
        }
    }
    
    var attributeText: RecognizedText? {
        imageText?.attributeText
    }
    
    var texts: [RecognizedText] {
        switch self {
        case .scanned(let info):
            return [info.imageText.text]
        case .selection(let info):
            return info.imageTexts.map { $0.text }
        default:
            return []
        }
    }
}

//TODO: Selection will return multiple for these
extension Fill {
    var imageText: ImageText? {
        switch self {
        case .scanned(let info):
            return info.imageText
        case .selection(let info):
            return info.imageTexts.first
        default:
            return nil
        }
    }
    
    var text: RecognizedText? {
        imageText?.text
    }
    
    var resultId: UUID? {
        imageText?.imageId
    }
    
    var boundingBoxToCrop: CGRect? {
        switch self {
        case .scanned(let info):
            if let attributeText = attributeText, attributeText != text {
                return attributeText.boundingBox.union(info.imageText.text.boundingBox)
            } else {
                return info.imageText.text.boundingBox
            }
        case .selection:
            return text?.boundingBox
        default:
            return nil
        }
    }
    
    var boundingBox: CGRect? {
        switch self {
        case .selection, .scanned:
            return text?.boundingBox
        default:
            return nil
        }
    }
    
    var detectedValues: [FoodLabelValue] {
        text?.string.values ?? []
    }
}

extension Fill {
    
    var isAltValue: Bool {
        altValue != nil
    }

    /// Returns the `FoodLabelValue` represented by this fill type.
    var value: FoodLabelValue? {
        switch self {
        case .scanned(let info):
            return info.altValue ?? info.value
        case .selection(let info):
            return info.altValue ?? info.imageTexts.first?.text.firstFoodLabelValue
        case .calculated:
            //TODO: Do this
            return nil
        default:
            return nil
        }
    }
    
    /// Returns the `FoodLabelValue` associated with this fill type as an alt value. This does not return the actual `FoodLabelValue` that this fill type represents if it doesn't have an alt value.
    var altValue: FoodLabelValue? {
        get {
            switch self {
            case .scanned(let info):
                return info.altValue
            case .selection(let info):
                return info.altValue
            default:
                return nil
            }
        }
        set {
            switch self {
            case .scanned(let info):
                var newInfo = info
                newInfo.altValue = newValue
                self = .scanned(newInfo)
            case .selection(let info):
                var newInfo = info
                newInfo.altValue = newValue
                self = .selection(newInfo)
            default:
                break
            }
        }
    }
}

extension Fill {
    var energyValue: FoodLabelValue? {
        switch self {
        case .scanned(let info):
            return info.altValue ?? info.value
        case .selection(let info):
            return altValue ?? info.imageTexts.first?.text.string.energyValue
        default:
            return nil
        }
    }
}

extension Fill {
    func uses(text: RecognizedText) -> Bool {
        switch self {
        case .selection:
            return self.text?.id == text.id
        case .scanned(let info):
            return info.imageText.text.id == text.id || info.imageText.attributeText?.id == text.id
        default:
            return false
        }
    }
}

enum PrefillField {
    case name
    case detail
    case brand
}

extension Fill {
    mutating func removeImageText(_ imageText: ImageText) {
        guard case .selection(let info) = self else {
            return
        }
        var newInfo = info
        newInfo.imageTexts.removeAll(where: { $0 == imageText })
        self = .selection(newInfo)
    }
    
    mutating func appendImageText(_ imageText: ImageText) {
        let imageTexts: [ImageText]
        if case .selection(let info) = self {
            imageTexts = info.imageTexts + [imageText]
        } else {
            /// ** Note: ** This is now converting a possible `.scanned` Fill into a `.selection` one
            imageTexts = [imageText]
        }
        
        self = .selection(.init(imageTexts: imageTexts))
    }
}

extension Fill {
    mutating func appendPrefillFieldString(_ fieldString: PrefillFieldString) {
        let fieldStrings: [PrefillFieldString]
        if case .prefill(let info) = self {
            fieldStrings = info.fieldStrings + [fieldString]
        } else {
            /// ** Note: ** This is now converting a possible `.scanned` Fill into a `.selection` one
            fieldStrings = [fieldString]
        }
        
        self = .prefill(.init(fieldStrings: fieldStrings))
    }
    
    mutating func removePrefillFieldString(_ fieldString: PrefillFieldString) {
        guard case .prefill(let info) = self else {
            return
        }
        var newInfo = info
        newInfo.fieldStrings.removeAll(where: { $0 == fieldString })
        self = .prefill(newInfo)
    }
}
