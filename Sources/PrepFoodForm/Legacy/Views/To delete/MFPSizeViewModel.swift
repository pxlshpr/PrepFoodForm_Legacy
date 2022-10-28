//import MFPScraper
//
//struct MFPSizeViewModel: Hashable {
//    let size: MFPProcessedFood.Size
//
//    var nameString: String {
//        size.name.lowercased()
//    }
//    
//    var fullNameString: String {
//        if let prefixVolumeUnit = size.prefixVolumeUnit {
//            return "\(prefixVolumeUnit.shortDescription), \(nameString)"
//        } else {
//            return nameString
//        }
//    }
//
//    var scaledAmountString: String {
//        "\(scaledAmount.cleanAmount) \(amountUnitDescription.lowercased())"
//    }
//    
//    var amountUnitDescription: String {
//        switch size.amountUnit {
//        case .weight(let weightUnit):
//            return weightUnit.description
//        case .volume(let volumeUnit):
//            return volumeUnit.description
//        case .size(let size):
//            return size.nameDescription
//        case .serving:
//            return "serving"
//        }
//    }
//
//    var scaledAmount: Double {
//        guard size.quantity > 0 else {
//            return 0
//        }
//        return size.amount / size.quantity
//    }
//}
