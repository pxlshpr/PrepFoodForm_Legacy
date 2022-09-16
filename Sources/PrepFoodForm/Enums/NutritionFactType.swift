import SwiftUI
import PrepUnits

enum NutritionFactType: Hashable {
    case energy
    case macro(Macro)
    case micro(NutrientType)
    
    func textColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .energy:
            return .accentColor
        case .macro(let macro):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
//                return Color(.secondaryLabel)
        }
    }
    
    var supportedUnits: [NutritionFactUnit] {
        switch self {
        case .energy:
            return [.kcal, .kj]
        case .macro:
            return [.g]
        case .micro(let nutrientType):
            return nutrientType.units.map {
                $0.nutritionFactUnit
            }
        }
    }
    
    var defaultUnit: NutritionFactUnit {
        supportedUnits.first ?? .g
    }
}

extension NutritionFactType: CustomStringConvertible {
    var description: String {
        switch self {
        case .energy:
            return "Energy"
        case .macro(let macro):
            return macro.description
        case .micro(let micro):
            return micro.description
        }
    }
}
