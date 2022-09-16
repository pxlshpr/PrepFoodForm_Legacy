import SwiftUI
import PrepUnits

enum NutritionFactUnit {
    case kcal
    case kj
    case g
    case mg
    case mcg
    case mgAT
    case mgNE
    case mcgDFE
    case mcgRAE
    case IU
}

extension NutritionFactUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .kcal:
            return "kcal"
        case .kj:
            return "kJ"
        default:
            return NutrientUnit(self)?.shortDescription ?? ""
        }
    }
}


extension NutrientUnit {
    init?(_ nutritionFactUnit: NutritionFactUnit) {
        switch nutritionFactUnit {
        case .g:
            self = .g
        case .mg:
            self = .mg
        case .mcg:
            self = .mcg
        case .mgAT:
            self = .mgAT
        case .mgNE:
            self = .mgNE
        case .mcgDFE:
            self = .mcgDFE
        case .mcgRAE:
            self = .mcgRAE
        case .IU:
            self = .IU
        default:
            return nil
        }
    }
    var nutritionFactUnit: NutritionFactUnit {
        switch self {
        case .g:
            return .g
        case .mg:
            return .mg
        case .mgAT:
            return .mgAT
        case .mgNE:
            return .mgNE
        case .mcg:
            return .mcg
        case .mcgDFE:
            return .mcgDFE
        case .mcgRAE:
            return .mcgRAE
        case .IU:
            return .IU
        }
    }
}
