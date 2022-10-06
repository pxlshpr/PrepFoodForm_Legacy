import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit
import PrepUnits

enum PrefillField {
    case name
    case detail
    case brand
}

enum FillType: Hashable {
    case userInput
    
    /// `supplementaryTexts` are used for string based fields such as `name` and `detail` where multile texts may be selected and joined together to form the filled value
    case imageSelection(recognizedText: RecognizedText, scanResultId: UUID, supplementaryTexts: [RecognizedText] = [], value: FoodLabelValue? = nil)
    case imageAutofill(valueText: ValueText, scanResultId: UUID, value: FoodLabelValue? = nil)
    
    case calculated
    
    case prefill(prefillFields: [PrefillField] = [])
    
    case barcodeScan
    
    struct SystemImage {
        static let imageSelection = "hand.tap"
        static let prefill = "link"
        static let calculated = "equal.square"
        static let imageAutofill = "text.viewfinder"
        static let barcodeScan = "barcode.viewfinder"
        static let userInput = "keyboard"
    }
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return SystemImage.userInput
        case .imageSelection:
            return SystemImage.imageSelection
        case .calculated:
            return SystemImage.calculated
        case .imageAutofill:
            return SystemImage.imageAutofill
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
        //        case .imageSelection:
        //            return "hand.tap"
        //        case .imageAutofill:
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
        case .imageAutofill:
            return "Auto-filled from image"
        case .calculated:
            return "Calculated"
        case .imageSelection:
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
        case .imageAutofill:
            return true
        default:
            return false
        }
    }
    
    var usesImage: Bool {
        switch self {
        case .imageSelection, .imageAutofill:
            return true
        default:
            return false
        }
    }
    
    var isImageSelection: Bool {
        switch self {
        case .imageSelection:
            return true
        default:
            return false
        }
    }
    
    var valueText: ValueText? {
        switch self {
        case .imageAutofill(let valueText, _, _):
            return valueText
        default:
            return nil
        }
    }

    var attributeText: RecognizedText? {
        switch self {
        case .imageAutofill(let valueText, _, _):
            return valueText.attributeText
        default:
            return nil
        }
    }
    
    var text: RecognizedText? {
        switch self {
        case .imageAutofill(let valueText, _, _):
            return valueText.text
        case .imageSelection(let recognizedText, _, _, _):
            return recognizedText
        default:
            return nil
        }
    }
    
    var boundingBoxToCrop: CGRect? {
        switch self {
        case .imageAutofill(let valueText, _, _):
            if let attributeText = valueText.attributeText, attributeText != valueText.text {
                return attributeText.boundingBox.union(valueText.text.boundingBox)
            } else {
                return valueText.text.boundingBox
            }
        case .imageSelection(let recognizedText, _, _, _):
            return recognizedText.boundingBox
        default:
            return nil
        }
    }

    var scanResultId: UUID? {
        switch self {
        case .imageSelection(_, let scanResultId, _, _):
            return scanResultId
        case .imageAutofill(_, let scanResultId, _):
            return scanResultId
        default:
            return nil
        }
    }
    
    func boxRect(for image: UIImage) -> CGRect? {
        //        return CGRect(x: 20, y: 50, width: 20, height: 20)
        switch self {
        case .imageSelection, .imageAutofill:
            return boundingBox?.rectForSize(image.size)
        default:
            return nil
        }
    }

    var boundingBox: CGRect? {
        switch self {
        case .imageSelection, .imageAutofill:
            return text?.boundingBox
        default:
            return nil
        }
    }

    var boundingBoxForImagePicker: CGRect? {
        switch self {
        case .imageSelection(let recognizedText, _, _, _):
            return recognizedText.boundingBox
        case .imageAutofill(let valueText, _, _):
            if let attributeText = valueText.attributeText {
                return attributeText.boundingBox.union(valueText.text.boundingBox)
            } else {
                return valueText.text.boundingBox
            }
        default:
            return nil
        }
    }

}

extension FillType {
    var detectedValues: [FoodLabelValue] {
        text?.string.values ?? []
    }
    
    var isAltValue: Bool {
        altValue != nil
    }

    /// Returns the `FoodLabelValue` represented by this fill type.
    var value: FoodLabelValue? {
        switch self {
        case .imageSelection(let recognizedText, _, _, let value):
            return value ?? recognizedText.firstFoodLabelValue
        case .imageAutofill(let valueText, _, let value):
            return value ?? valueText.value
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
            case .imageSelection(_, _, _, let value):
                return value
            case .imageAutofill(_, _, let value):
                return value
            default:
                return nil
            }
        }
        set {
            switch self {
            case .imageSelection(let recognizedText, let scanResultId, let supplementaryTexts, _):
                self = .imageSelection(recognizedText: recognizedText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: newValue)
            case .imageAutofill(let valueText, let scanResultId, _):
                self = .imageAutofill(valueText: valueText, scanResultId: scanResultId, value: newValue)
            default:
                break
            }
        }
    }
}

extension FillType {
    var energyValue: FoodLabelValue? {
        switch self {
        case .imageSelection(let recognizedText, _, _, let altValue):
            return altValue ?? recognizedText.string.energyValue
        case .imageAutofill(let valueText, _, let altValue):
            return altValue ?? valueText.value
        default:
            return nil
        }
    }
}

extension FillType {
    func uses(text: RecognizedText) -> Bool {
        switch self {
        case .imageSelection(let recognizedText, _, _, _):
            return recognizedText.id == text.id
        case .imageAutofill(let valueText, _, _):
            return valueText.text.id == text.id || valueText.attributeText?.id == text.id
        default:
            return false
        }
    }
}
