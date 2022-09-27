import SwiftUI
import PrepUnits

enum FieldValue: Hashable {
    case name(string: String = "", fillType: FieldFillType = .userInput)
    case emoji(string: String = "")
    case brand(string: String = "", fillType: FieldFillType = .userInput)
    case barcode(string: String = "", fillType: FieldFillType = .barcodeScan)
    case detail(string: String = "", fillType: FieldFillType = .userInput)
    
    case amount(double: Double? = nil, string: String = "", unit: FormUnit = .serving)
    case serving(double: Double? = nil, string: String = "", unit: FormUnit = .weight(.g))

    case energy(double: Double? = nil, string: String = "", unit: EnergyUnit = .kcal, fillType: FieldFillType = .userInput)
    case macro(macro: Macro, double: Double? = nil, string: String = "", fillType: FieldFillType = .userInput)
    case micro(nutrientType: NutrientType, double: Double? = nil, string: String = "", unit: NutrientUnit = .g, fillType: FieldFillType = .userInput)
}

extension FieldValue {
    init(micronutrient: NutrientType, fillType: FieldFillType = .userInput) {
        self = .micro(
            nutrientType: micronutrient,
            double: nil,
            string: "",
            unit: micronutrient.units.first ?? .g,
            fillType: fillType
        )
    }
}

extension FieldValue: CustomStringConvertible {
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .detail:
            return "Detail"
        case .emoji:
            return "Emoji"
        case .brand:
            return "Brand"
        case .barcode:
            return "Barcode"
        
        case .amount:
            return "Amount Per"
        case .serving:
            return "Serving Size"

        case .energy:
            return "Energy"
        case .macro(macro: let macro, _, _, _):
            return macro.description
        case .micro(nutrientType: let nutrientType, _, _, _, _):
            return nutrientType.description
        }
    }
}

extension FieldValue {
    var isEmpty: Bool {
        switch self {
        case .name(let string, _):
            return string.isEmpty
        case .emoji(let string):
            return string.isEmpty
        case .detail(let string, _):
            return string.isEmpty
        case .brand(let string, _):
            return string.isEmpty
        case .barcode(string: let string, _):
            return string.isEmpty
        
        case .amount(double: let double, _, _):
            return double == nil
        case .serving(double: let double, _, _):
            return double == nil

        case .energy(let double, _, _, _):
            return double == nil
        case .macro(_, let double, _, _):
            return double == nil
        case .micro(_, let double, _, _, _):
            return double == nil
        }
    }
    
    var string: String {
        get {
            switch self {
            case .name(let string, _):
                return string
            case .emoji(let string):
                return string
            case .detail(let string, _):
                return string
            case .brand(string: let string, _):
                return string
            case .barcode(string: let string, _):
                return string
                
            case .amount(_, string: let string, _):
                return string
            case .serving(_, string: let string, _):
                return string

            case .energy(_, let string, _, _):
                return string
            case .macro(_, _, let string, _):
                return string
            case .micro(_, _, let string, _, _):
                return string
            }
        }
        set {
            switch self {
            case .name:
                self = .name(string: newValue)
            case .emoji:
                self = .emoji(string: newValue)
            case .detail:
                self = .detail(string: newValue)
            case .brand:
                self = .brand(string: newValue)
            case .barcode:
                self = .barcode(string: newValue)
                
            case .amount(_, _, unit: let formUnit):
                guard !newValue.isEmpty else {
                    self = .amount(double: nil, string: newValue, unit: formUnit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .amount(double: double, string: newValue, unit: formUnit)
            case .serving(_, _, unit: let formUnit):
                guard !newValue.isEmpty else {
                    self = .serving(double: nil, string: newValue, unit: formUnit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .serving(double: double, string: newValue, unit: formUnit)

            case .energy(_, _, let energyUnit, _):
                guard !newValue.isEmpty else {
                    self = .energy(double: nil, string: newValue, unit: energyUnit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .energy(double: double, string: newValue, unit: energyUnit)
            case .macro(let macro, _, _, _):
                guard !newValue.isEmpty else {
                    self = .macro(macro: macro, double: nil, string: newValue)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .macro(macro: macro, double: double, string: newValue)
            case .micro(let nutrientType, _, _, let nutrientUnit, _):
                guard !newValue.isEmpty else {
                    self = .micro(nutrientType: nutrientType, double: nil, string: newValue, unit: nutrientUnit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .micro(nutrientType: nutrientType, double: double, string: newValue, unit: nutrientUnit)
            }
        }
    }
    
    var double: Double? {
        get {
            switch self {
            case .amount(double: let double, _, _):
                return double
            case .serving(double: let double, _, _):
                return double

            case .energy(let double, _, _, _):
                return double
            case .macro(_, let double, _, _):
                return double
            case .micro(_, let double, _, _, _):
                return double
            default:
                return nil
            }
        }
        set {
            switch self {
            case .amount(_, _, unit: let formUnit):
                self = .amount(double: newValue, string: newValue?.cleanAmount ?? "", unit: formUnit)
            case .serving(_, _, unit: let formUnit):
                self = .serving(double: newValue, string: newValue?.cleanAmount ?? "", unit: formUnit)

            case .energy(_, _, let energyUnit, _):
                self = .energy(double: newValue, string: newValue?.cleanAmount ?? "", unit: energyUnit)
            case .macro(let macro, _, _, _):
                self = .macro(macro: macro, double: newValue, string: newValue?.cleanAmount ?? "")
            case .micro(let nutrientType, _, _, let nutrientUnit, _):
                self = .micro(nutrientType: nutrientType, double: newValue, string: newValue?.cleanAmount ?? "", unit: nutrientUnit)
            default:
                break
            }
        }
    }
    
}


extension FieldValue {
    var amountString: String {
        switch self {
        case .energy(let double, _, _, _):
            return double?.cleanAmount ?? "Required"
        case .macro(_, let double, _, _):
            return double?.cleanAmount ?? "Required"
        case .micro(_, let double, _, _, _):
            return double?.cleanAmount ?? ""
        default:
            return ""
        }
    }
    
    var unitString: String {
        switch self {
        case .energy(_, _, let energyUnit, _):
            return energyUnit.shortDescription
        case .macro:
            return NutrientUnit.g.shortDescription
        case .micro(_, _, _, let nutrientUnit, _):
            return nutrientUnit.shortDescription
        default:
            return ""
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
        case .macro(let macro, _, _, _):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
        default:
            return .primary
        }
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }
    
    func labelColor(for colorScheme: ColorScheme) -> Color {
        isEmpty ? Color(.secondaryLabel) :  textColor(for: colorScheme)
    }

    var fillTypeIconImage: String? {
        //TODO: Write this
        return nil
//        guard identifier.valueType == .nutrient else {
//            return fillType.iconSystemImage
//        }
//        guard fillType != .userInput else {
//            return nil
//        }
//        return fillType.iconSystemImage
    }

    var supportedNutrientUnits: [NutrientUnit] {
        switch self {
        case .micro(let nutrientType, _, _, _, _):
            return nutrientType.units.map {
                $0
            }
        default:
            return []
        }
    }
    
    var nutrientType: NutrientType? {
        switch self {
        case .micro(let nutrientType, _, _, _, _):
            return nutrientType
        default:
            return nil
        }
    }
}


extension FieldValue {
    var nutrientUnit: NutrientUnit {
        get {
            switch self {
            case .macro:
                return .g
            case .micro(_, _, _, let nutrientUnit, _):
                return nutrientUnit
            default:
                return .g
            }
        }
        set {
            switch self {
            case .micro(let nutrientType, let double, let string, _, _):
                self = .micro(nutrientType: nutrientType, double: double, string: string, unit: newValue)
            default:
                break
            }
        }
    }
    
    var energyUnit: EnergyUnit {
        get {
            switch self {
            case .energy(_, _, let energyUnit, _):
                return energyUnit
            default:
                return .kcal
            }
        }
        set {
            switch self {
            case .energy(let double, let string, _, _):
                self = .energy(double: double, string: string, unit: newValue)
            default:
                break
            }
        }
    }
    
    var unit: FormUnit {
        get {
            switch self {
            case .amount(_, _, unit: let formUnit):
                return formUnit
            case .serving(_, _, unit: let formUnit):
                return formUnit
            default:
                return .weight(.g)
            }
        }
        set {
            switch self {
            case .amount(double: let double, string: let string, _):
                self = .amount(double: double, string: string, unit: newValue)
            case .serving(double: let double, string: let string, _):
                self = .serving(double: double, string: string, unit: newValue)
            default:
                break
            }
        }
    }
}
