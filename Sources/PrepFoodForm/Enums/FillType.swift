import Foundation
import NutritionLabelClassifier
import UIKit

enum FillType: Hashable {
    case userInput
    case imageSelection(valueText: ValueText, outputId: UUID)
    case imageAutofill(valueText: ValueText, outputId: UUID)
    case thirdPartyFoodPrefill
    case barcodeScan
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return ""
        case .imageSelection:
            return "hand.tap"
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
        case .imageSelection(let valueText, _):
            return valueText
        case .imageAutofill(let valueText, _):
            return valueText
        default:
            return nil
        }
    }
    var outputId: UUID? {
        switch self {
        case .imageSelection(_, let outputId):
            return outputId
        case .imageAutofill(_, let outputId):
            return outputId
        default:
            return nil
        }
    }
    
    func boxRect(for image: UIImage) -> CGRect? {
        //        return CGRect(x: 20, y: 50, width: 20, height: 20)
        switch self {
        case .imageSelection(let valueText, _), .imageAutofill(let valueText, _):
            return valueText.boundingBoxForCrop.rectForSize(image.size)
        default:
            return nil
        }
    }

    var boundingBox: CGRect? {
//        return CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.3)
        switch self {
        case .imageSelection(let valueText, _), .imageAutofill(let valueText, _):
            return valueText.boundingBoxForCrop
        default:
            return nil
        }
    }

}
