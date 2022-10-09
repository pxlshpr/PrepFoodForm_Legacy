import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit
import PrepUnits

struct ResultText: Hashable {
    let text: RecognizedText
    let attributeText: RecognizedText?
    let resultId: UUID
    
    init(text: RecognizedText, attributeText: RecognizedText? = nil, resultId: UUID) {
        self.text = text
        self.resultId = resultId
        self.attributeText = attributeText
    }
    
    init(valueText: ValueText, resultId: UUID) {
        self.text = valueText.text
        self.attributeText = valueText.attributeText
        self.resultId = resultId
    }
}

struct ScannedFillInfo: Hashable {
    var resultText: ResultText
    var value: FoodLabelValue?
    var altValue: FoodLabelValue? = nil
    
    init(resultText: ResultText, value: FoodLabelValue? = nil, altValue: FoodLabelValue? = nil) {
        self.value = value
        self.resultText = resultText
        self.altValue = altValue
    }
    
    init(valueText: ValueText, resultId: UUID, altValue: FoodLabelValue? = nil) {
        self.value = valueText.value
        self.resultText = ResultText(valueText: valueText, resultId: resultId)
        self.altValue = altValue
    }
    
    func withAltValue(_ value: FoodLabelValue) -> ScannedFillInfo {
        var newInfo = self
        newInfo.altValue = value
        return newInfo
    }
}

struct SelectionFillInfo: Hashable {
    var resultTexts: [ResultText]
    var altValue: FoodLabelValue? = nil
}

struct PrefillFillInfo: Hashable {
    var fields: [PrefillField] = []
}

enum Fill: Hashable {
    
    case scanned(ScannedFillInfo)
    case selection(recognizedText: RecognizedText, scanResultId: UUID, supplementaryTexts: [RecognizedText] = [], value: FoodLabelValue? = nil)
    
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
        switch self {
        case .scanned(let info):
            return info.resultText.attributeText
        default:
            return nil
        }
    }
    
    var text: RecognizedText? {
        switch self {
        case .scanned(let info):
            return info.resultText.text
        case .selection(let recognizedText, _, _, _):
            return recognizedText
        default:
            return nil
        }
    }
    
    var resultId: UUID? {
        switch self {
        case .scanned(let scannedFillInfo):
            return scannedFillInfo.resultText.resultId
        case .selection(_, let resultId, _, _):
            return resultId
        default:
            return nil
        }
    }
    
    //TODO: Merge boundingBoxToCrop and boundingBoxForImagePicker into one
    var boundingBoxToCrop: CGRect? {
        switch self {
        case .scanned(let info):
            if let attributeText = attributeText, attributeText != text {
                return attributeText.boundingBox.union(info.resultText.text.boundingBox)
            } else {
                return info.resultText.text.boundingBox
            }
        case .selection(let recognizedText, _, _, _):
            return recognizedText.boundingBox
        default:
            return nil
        }
    }

    var boundingBoxForImagePicker: CGRect? {
        switch self {
        case .scanned(let info):
            if let attributeText = attributeText {
                return attributeText.boundingBox.union(info.resultText.text.boundingBox)
            } else {
                return info.resultText.text.boundingBox
            }
        case .selection(let recognizedText, _, _, _):
            return recognizedText.boundingBox
        default:
            return nil
        }
    }
    
    func boxRect(for image: UIImage) -> CGRect? {
        switch self {
        case .selection, .scanned:
            return boundingBox?.rectForSize(image.size)
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

}

extension Fill {
    var detectedValues: [FoodLabelValue] {
        text?.string.values ?? []
    }
    
    var isAltValue: Bool {
        altValue != nil
    }

    /// Returns the `FoodLabelValue` represented by this fill type.
    var value: FoodLabelValue? {
        switch self {
        case .scanned(let info):
            return info.altValue ?? info.value
        case .selection(let recognizedText, _, _, let value):
            return value ?? recognizedText.firstFoodLabelValue
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
            case .selection(_, _, _, let value):
                return value
            case .scanned(let info):
                return info.altValue
            default:
                return nil
            }
        }
        set {
            switch self {
            case .selection(let recognizedText, let scanResultId, let supplementaryTexts, _):
                self = .selection(recognizedText: recognizedText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: newValue)
            case .scanned(let info):
                var newInfo = info
                newInfo.value = newValue
                self = .scanned(newInfo)
            default:
                break
            }
        }
    }
}

extension Fill {
    var energyValue: FoodLabelValue? {
        switch self {
        case .selection(let recognizedText, _, _, let altValue):
            return altValue ?? recognizedText.string.energyValue
        case .scanned(let info):
            return info.altValue ?? info.value
        default:
            return nil
        }
    }
}

extension Fill {
    func uses(text: RecognizedText) -> Bool {
        switch self {
        case .selection(let recognizedText, _, _, _):
            return recognizedText.id == text.id
        case .scanned(let info):
            return info.resultText.text.id == text.id || info.resultText.attributeText?.id == text.id
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
