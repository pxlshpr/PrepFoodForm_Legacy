import Foundation
import FoodLabelScanner
import VisionSugar
import UIKit

enum FillType: Hashable {
    case userInput
    case imageSelection(recognizedText: RecognizedText, scanResultId: UUID)
    case imageAutofill(valueText: ValueText, scanResultId: UUID)
    case calculated
    case thirdPartyFoodPrefill
    case barcodeScan
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return ""
        case .imageSelection:
            return "hand.tap"
        case .calculated:
            return "equal.square"
        case .imageAutofill:
            return "text.viewfinder"
        case .thirdPartyFoodPrefill:
            return "link"
        case .barcodeScan:
            return "barcode.viewfinder"
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
        //        case .thirdPartyFoodPrefill:
        //            return "link"
        //        case .barcodeScan:
        //            return "viewfinder.circle.fill"
        //        }
    }
    
    var sectionHeaderString: String {
        switch self {
        case .thirdPartyFoodPrefill:
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
    
    var text: RecognizedText? {
        switch self {
        case .imageAutofill(let valueText, _):
            return valueText.text
        case .imageSelection(let recognizedText, _):
            return recognizedText
        default:
            return nil
        }
    }
    var scanResultId: UUID? {
        switch self {
        case .imageSelection(_, let scanResultId):
            return scanResultId
        case .imageAutofill(_, let scanResultId):
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
