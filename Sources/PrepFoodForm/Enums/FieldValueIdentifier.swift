import SwiftUI
import PrepUnits

enum FieldValueIdentifier: Hashable {
    case name
    case detail
    case energy
    case macro(Macro)
    case micro(NutrientType)
    
    var valueType: FieldValueType {
        switch self {
        case .name:
            return .string
        case .detail:
            return .string
        case .energy, .macro, .micro:
            return .nutrient
        }
    }
    
    var usesString: Bool {
        valueType == .string
    }
    
    var usesDouble: Bool {
        valueType == .double || valueType == .nutrient
    }
}

extension FieldValueIdentifier: CustomStringConvertible {
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .detail:
            return "Detail"
        case .energy:
            return "Energy"
        case .macro(let macro):
            return macro.description
        case .micro(let micro):
            return micro.description
        }
    }
    
    var iconImageName: String {
        switch self {
        case .energy: return "flame.fill"
        case .macro: return "circle.circle.fill"
        case .micro: return "circle.circle"
        default:
            return ""
        }
    }
    
    func textColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .energy:
            return .accentColor
        case .macro(let macro):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
        default:
            return .primary
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
        default:
            return []
        }
    }
    
    var defaultUnit: NutritionFactUnit {
        supportedUnits.first ?? .g
    }
    
    var nutrientType: NutrientType? {
        switch self {
        case .micro(let type):
            return type
        default:
            return nil
        }
    }
}
