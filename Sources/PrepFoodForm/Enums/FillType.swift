import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit

enum PrefillField {
    case name
    case detail
    case brand
}

enum FillType: Hashable {
    case userInput
    
    /// `value` is used to identify the specific `Value` for each of these that the user picked (for instances where alternative's may have been suggested and the user picked one of those instead)—so that we can later mark it as selected
    /// `supplementaryTexts` are used for string based fields such as `name` and `detail` where multile texts may be selected and joined together to form the filled value
    case imageSelection(recognizedText: RecognizedText, scanResultId: UUID, supplementaryTexts: [RecognizedText] = [], value: Value? = nil, croppedImage: UIImage? = nil)
    case imageAutofill(valueText: ValueText, scanResultId: UUID, value: Value? = nil, croppedImage: UIImage? = nil)
    
    case calculated
    
    /// `prefilledFields` is used for string based fields such as `name` and `detail` where multile prefill fields may be selected and joined together to form the filled value. For instance, if the user joins what the prefill food has as its `.name` and `.detail` into the name field, this would be `.prefill([.name, .detail])`
    case prefill(prefillFields: [PrefillField] = [])
    
    case barcodeScan
    
    struct SystemImage {
        static let imageSelection = "hand.tap"
        static let prefill = "link"
        static let calculated = "equal.square"
        static let imageAutofill = "text.viewfinder"
        static let barcodeScan = "barcode.viewfinder"
    }
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return ""
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
        case .imageAutofill(let valueText, _, _, _):
            return valueText
        default:
            return nil
        }
    }

    var text: RecognizedText? {
        switch self {
        case .imageAutofill(let valueText, _, _, _):
            return valueText.text
        case .imageSelection(let recognizedText, _, _, _, _):
            return recognizedText
        default:
            return nil
        }
    }
    
    var boundingBoxToCrop: CGRect? {
        switch self {
        case .imageAutofill(let valueText, _, _, _):
            if let attributeText = valueText.attributeText, attributeText != valueText.text {
                return attributeText.boundingBox.union(valueText.text.boundingBox)
            } else {
                return valueText.text.boundingBox
            }
        case .imageSelection(let recognizedText, _, _, _, _):
            return recognizedText.boundingBox
        default:
            return nil
        }
    }

    var scanResultId: UUID? {
        switch self {
        case .imageSelection(_, let scanResultId, _, _, _):
            return scanResultId
        case .imageAutofill(_, let scanResultId, _, _):
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
//        return CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.3)
        switch self {
        case .imageSelection, .imageAutofill:
            return text?.boundingBox
        default:
            return nil
        }
    }

}
