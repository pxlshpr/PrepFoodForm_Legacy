import Foundation

enum FillType: Hashable {
    case userInput
    case imageSelection(UUID)
    case imageAutofill(UUID)
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
        switch self {
        case .userInput:
            return "circle.dashed"
        case .imageSelection:
            return "photo.circle.fill"
        case .imageAutofill:
            return "viewfinder.circle.fill"
        case .thirdPartyFoodPrefill:
            return "link.circle.fill"
        case .barcodeScan:
            return "viewfinder.circle.fill"
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
}
