import SwiftUI
import MFPScraper
import VisionSugar
import FoodLabelScanner
import PrepDataTypes
import PrepNetworkController

//
//extension WeightUnit {
//    var serverInt: Int16 {
//        rawValue
//    }
//}
//
//extension FormUnit {
//    var sizeUnitId: UUID? {
//        guard case .size(let size, _) = self else { return nil }
//        return size.id
//    }
//    
//    var sizeUnitVolumePrefixUnitInt: Int16? {
//        guard case .size(_, let volumeUnit) = self else { return nil }
//        return volumeUnit?.serverInt
//    }
//    
//    var volumeUnitServerInt: Int16? {
//        guard case .volume(let volumeUnit) = self else { return nil }
//        return volumeUnit.serverInt
//    }
//
//    var weightUnitServerInt: Int16? {
//        guard case .weight(let weightUnit) = self else { return nil }
//        return weightUnit.serverInt
//    }
//    
//    var serverInt: Int16 {
//        switch self {
//        case .weight:   return 1
//        case .volume:   return 2
//        case .size:     return 3
//        case .serving:  return 4
//        }
//    }
//}
