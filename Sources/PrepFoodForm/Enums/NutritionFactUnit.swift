import SwiftUI

enum NutritionFactUnit {
    case kcal
    case kj
    case g
    case mg
    case ug
}

extension NutritionFactUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .kcal:
            return "kcal"
        case .kj:
            return "kJ"
        case .g:
            return "g"
        case .mg:
            return "mg"
        case .ug:
            return "μ"
        }
    }
}

