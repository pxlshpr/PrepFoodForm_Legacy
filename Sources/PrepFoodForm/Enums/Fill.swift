import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit
import PrepUnits

struct ImageText: Hashable {
    let text: RecognizedText
    let attributeText: RecognizedText?
    let imageId: UUID
    
    init(text: RecognizedText, attributeText: RecognizedText? = nil, imageId: UUID) {
        self.text = text
        self.imageId = imageId
        self.attributeText = attributeText
    }
    
    init(valueText: ValueText, imageId: UUID) {
        self.text = valueText.text
        self.attributeText = valueText.attributeText
        self.imageId = imageId
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
}

struct PrefillFillInfo: Hashable {
    var fields: [PrefillField] = []
}

enum Fill: Hashable {
    
    case scanned(ScannedFillInfo)
    case selection(SelectionFillInfo)
    
    case prefill(prefillFields: [PrefillField] = [])
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
    
    var isThirdPartyFoodPrefill: Bool {
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
