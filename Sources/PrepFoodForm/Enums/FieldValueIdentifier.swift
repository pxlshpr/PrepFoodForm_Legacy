import SwiftUI
import PrepUnits

enum FieldValueIdentifier: Hashable {
    case name(String = "")
    case detail(String = "")
    case energy(Double? = nil, String = "", EnergyUnit = .kcal)
    case macro(Macro, Double? = nil, String = "")
    case micro(NutrientType, Double? = nil, String = "", NutrientUnit = .g)
    
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
    
    var amountString: String {
        switch self {
        case .energy(let double, _, _):
            return double?.cleanAmount ?? "Required"
        case .macro(_, let double, _):
            return double?.cleanAmount ?? "Required"
        case .micro(_, let double, _, _):
            return double?.cleanAmount ?? ""
        default:
            return ""
        }
    }
    
    var unitString: String {
        switch self {
        case .energy(_, _, let energyUnit):
            return energyUnit.shortDescription
        case .macro:
            return NutrientUnit.g.shortDescription
        case .micro(_, _, _, let nutrientUnit):
            return nutrientUnit.shortDescription
        default:
            return ""
        }
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
        case .macro(let macro, _, _):
            return macro.description
        case .micro(let nutrientType, _, _, _):
            return nutrientType.description
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
        case .macro(let macro, _, _):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
        default:
            return .primary
        }
    }
    
    var supportedUnits: [NutrientUnit] {
        switch self {
        case .energy:
//            return [.kcal, .kj]
            return [.g]
        case .macro:
            return [.g]
        case .micro(let nutrientType, _, _, _):
            return nutrientType.units.map {
                $0
            }
        default:
            return []
        }
    }
    
    var defaultUnit: NutrientUnit {
        supportedUnits.first ?? .g
    }
    
    var nutrientType: NutrientType? {
        switch self {
        case .micro(let nutrientType, _, _, _):
            return nutrientType
        default:
            return nil
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .name(let string):
            return string.isEmpty
        case .detail(let string):
            return string.isEmpty
        case .energy(let double, _, _):
            return double == nil
        case .macro(_, let amount, _):
            return amount == nil
        case .micro(_, let amount, _, _):
            return amount == nil
        }
    }
}


extension FieldValueIdentifier {
    
    var double: Double? {
        get {
            switch self {
            case .energy(let double, _, _):
                return double
            case .macro(_, let double, _):
                return double
            case .micro(_, let double, _, _):
                return double
            default:
                return nil
            }
        }
        set {
            switch self {
            case .energy(_, _, let energyUnit):
                self = .energy(newValue, newValue?.cleanAmount ?? "", energyUnit)
            case .macro(let macro, _, _):
                self = .macro(macro, newValue, newValue?.cleanAmount ?? "")
            case .micro(let nutrientType, _, _, let nutrientUnit):
                self = .micro(nutrientType, newValue, newValue?.cleanAmount ?? "", nutrientUnit)
            default:
                break
            }
        }
    }
    
    var string: String {
        get {
            switch self {
            case .name(let string):
                return string
            case .detail(let string):
                return string
            case .energy(_, let string, _):
                return string
            case .macro(_, _, let string):
                return string
            case .micro(_, _, let string, _):
                return string
            }
        }
        set {
            switch self {
            case .name:
                self = .name(newValue)
            case .detail:
                self = .detail(newValue)
            case .energy(_, _, let energyUnit):
                guard !newValue.isEmpty else {
                    self = .energy(nil, newValue, energyUnit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .energy(double, newValue, energyUnit)
            case .macro(let macro, _, _):
                guard !newValue.isEmpty else {
                    self = .macro(macro, nil, newValue)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .macro(macro, double, newValue)
            case .micro(let nutrientType, _, _, let nutrientUnit):
                guard !newValue.isEmpty else {
                    self = .micro(nutrientType, nil, newValue, nutrientUnit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .micro(nutrientType, double, newValue, nutrientUnit)
            }
        }
    }
    
    var nutrientUnit: NutrientUnit {
        get {
            switch self {
            case .macro:
                return .g
            case .micro(_, _, _, let nutrientUnit):
                return nutrientUnit
            default:
                return .g
            }
        }
        set {
            switch self {
            case .micro(let nutrientType, let double, let string, _):
                self = .micro(nutrientType, double, string, newValue)
            default:
                break
            }
        }
    }
    
    var energyUnit: EnergyUnit {
        get {
            switch self {
            case .energy(_, _, let energyUnit):
                return energyUnit
            default:
                return .kcal
            }
        }
        set {
            switch self {
            case .energy(let double, let string, _):
                self = .energy(double, string, newValue)
            default:
                break
            }
        }
    }
}
