import SwiftUI
import PrepUnits

enum FieldValue: Hashable {
    
    struct DoubleValue: Hashable {
        var internalDouble: Double? = nil
        var internalString: String = ""
        var double: Double? {
            get {
                return internalDouble
            }
            set {
                internalDouble = newValue
                internalString = newValue?.cleanAmount ?? ""
            }
        }
        
        var string: String {
            get {
                return internalString
            }
            set {
                guard !newValue.isEmpty else {
                    internalDouble = nil
                    internalString = newValue
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self.internalDouble = double
                self.internalString = newValue
            }
        }
        var unit: FormUnit
        
        init(double: Double? = nil, string: String = "", unit: FormUnit) {
            self.internalDouble = double
            self.internalString = string
            self.unit = unit
        }
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
    }
    
    struct Density: Hashable {
        static let DefaultWeight = DoubleValue(unit: .weight(.g))
        static let DefaultVolume = DoubleValue(unit: .volume(.cup))
        var weight = DefaultWeight
        var volume = DefaultVolume
    }

    struct StringValue: Hashable {
        var string: String = ""
        var fillType: FillType = .userInput
        
        var isEmpty: Bool {
            string.isEmpty
        }
    }
    
    case name(StringValue = StringValue())
    case emoji(StringValue = StringValue())
    case brand(StringValue = StringValue())
    case barcode(StringValue = StringValue())
    case detail(StringValue = StringValue())
    
    case amount(doubleValue: DoubleValue = DoubleValue(unit: .serving))
    case serving(doubleValue: DoubleValue = DoubleValue(unit: .weight(.g)))

    case density(density: Density? = nil)

    case energy(double: Double? = nil, string: String = "", unit: EnergyUnit = .kcal, fillType: FillType = .userInput)
    case macro(macro: Macro, double: Double? = nil, string: String = "", fillType: FillType = .userInput)
    case micro(nutrientType: NutrientType, double: Double? = nil, string: String = "", unit: NutrientUnit = .g, fillType: FillType = .userInput)
}

extension FieldValue {
    init(micronutrient: NutrientType, fillType: FillType = .userInput) {
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
        case .density:
            return "Density"

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
        case .name(let stringValue), .detail(let stringValue), .brand(let stringValue), .barcode(let stringValue), .emoji(let stringValue):
            return stringValue.isEmpty
            
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.isEmpty
            
        case .density(let density):
            return density == nil

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
            case .energy(_, let string, _, _):
                return string
            case .macro(_, _, let string, _):
                return string
            case .micro(_, _, let string, _, _):
                return string
            default:
                return ""
            }
        }
        set {
            switch self {
            //MARK: Nutrients
                
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
            default:
                break
            }
        }
    }
    
    var double: Double? {
        get {
            switch self {
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
    
    var doubleValue: DoubleValue {
        get {
            switch self {
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue
            default:
                return DoubleValue(unit: .weight(.g))
            }
        }
        set {
            switch self {
            case .amount:
                self = .amount(doubleValue: newValue)
            case .serving:
                self = .serving(doubleValue: newValue)
            default:
                break
            }
        }
    }
    
    var stringValue: StringValue {
        get {
            switch self {
            case .name(let stringValue), .barcode(let stringValue), .detail(let stringValue), .brand(let stringValue), .emoji(let stringValue):
                return stringValue
            default:
                return StringValue()
            }
        }
        set {
            switch self {
            case .name:
                self = .name(newValue)
            case .brand:
                self = .brand(newValue)
            case .emoji:
                self = .emoji(newValue)
            case .detail:
                self = .detail(newValue)
            case .barcode:
                self = .barcode(newValue)
            default:
                break
            }
        }
    }
    
    var weight: DoubleValue {
        get {
            switch self {
            case .density(let density):
                return density?.weight ?? Density.DefaultWeight
            default:
                return Density.DefaultWeight
            }
        }
        set {
            switch self {
            case .density(let density):
                self = .density(density: Density(weight: newValue, volume: density?.volume ?? Density.DefaultVolume))
            default:
                break
            }
        }
    }
    
    var volume: DoubleValue {
        get {
            switch self {
            case .density(let density):
                return density?.volume ?? Density.DefaultVolume
            default:
                return Density.DefaultVolume
            }
        }
        set {
            switch self {
            case .density(let density):
                self = .density(density: Density(weight: density?.weight ?? Density.DefaultWeight, volume: newValue))
            default:
                break
            }
        }
    }

}
