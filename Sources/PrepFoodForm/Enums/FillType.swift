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
            return "keyboard"
        case .imageSelection:
            return "photo"
        case .imageAutofill:
            return "text.viewfinder"
        case .thirdPartyFoodPrefill:
            return "link"
        case .barcodeScan:
            return "barcode.viewfinder"
        }
    }
    
    var buttonSystemImage: String {
//        buttonSystemImageWithoutFill + ".fill"
        buttonSystemImageWithoutFill
    }
    var buttonSystemImageWithoutFill: String {
        switch self {
        case .userInput:
            return "pencil.circle"
        case .imageSelection:
            return "photo.circle"
        case .imageAutofill:
            return "viewfinder.circle"
        case .thirdPartyFoodPrefill:
            return "link.circle"
        case .barcodeScan:
            return "viewfinder.circle"
        }
    }
}
