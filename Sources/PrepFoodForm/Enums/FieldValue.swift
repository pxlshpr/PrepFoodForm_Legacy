import SwiftUI
import PrepUnits

enum FieldValue: Hashable {
    
    struct MicroValue: Hashable {
        var nutrientType: NutrientType
        var internalDouble: Double?
        var internalString: String
        var unit: NutrientUnit
        var fillType: FillType

        init(nutrientType: NutrientType, double: Double? = nil, string: String = "", unit: NutrientUnit = .g, fillType: FillType = .userInput) {
            self.nutrientType = nutrientType
            self.internalDouble = double
            self.internalString = string
            self.unit = unit
            self.fillType = fillType
        }
        
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
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
        
        func textColor(for colorScheme: ColorScheme) -> Color {
            .gray
        }
        
        var supportedNutrientUnits: [NutrientUnit] {
            nutrientType.units.map {
                $0
            }
        }
    }

    struct MacroValue: Hashable {
        var macro: Macro
        var internalDouble: Double?
        var internalString: String
        var fillType: FillType

        init(macro: Macro, double: Double? = nil, string: String = "", fillType: FillType = .userInput) {
            self.macro = macro
            self.internalDouble = double
            self.internalString = string
            self.fillType = fillType
        }
        
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
        
        var isEmpty: Bool {
            double == nil
        }
        
        var unitDescription: String {
            NutrientUnit.g.shortDescription
        }
        
        func textColor(for colorScheme: ColorScheme) -> Color {
            macro.textColor(for: colorScheme)
        }
    }
    
    struct EnergyValue: Hashable {
        var internalDouble: Double?
        var internalString: String
        var unit: EnergyUnit
        var fillType: FillType

        init(double: Double? = nil, string: String = "", unit: EnergyUnit = .kcal, fillType: FillType = .userInput) {
            self.internalDouble = double
            self.internalString = string
            self.unit = unit
            self.fillType = fillType
        }
        
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
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
        
        func textColor(for colorScheme: ColorScheme) -> Color {
            .accentColor
        }
        
    }
    
    struct DoubleValue: Hashable {
        var internalDouble: Double? = nil
        var internalString: String = ""
        var unit: FormUnit
        var fillType: FillType

        init(double: Double? = nil, string: String = "", unit: FormUnit, fillType: FillType = .userInput) {
            self.internalDouble = double
            self.internalString = string
            self.unit = unit
            self.fillType = fillType
        }
        
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
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var isEmpty: Bool {
            double == nil
        }
    }
    
    struct DensityValue: Hashable {
        static let DefaultWeight = DoubleValue(unit: .weight(.g))
        static let DefaultVolume = DoubleValue(unit: .volume(.cup))
        var weight = DefaultWeight
        var volume = DefaultVolume
        var fillType: FillType = .userInput
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
    case amount(DoubleValue = DoubleValue(unit: .serving))
    case serving(DoubleValue = DoubleValue(unit: .weight(.g)))
    case density(DensityValue? = nil)
    case energy(EnergyValue = EnergyValue())
    case macro(MacroValue)
    case micro(MicroValue)
}

extension FieldValue {
    init(micronutrient: NutrientType, fillType: FillType = .userInput) {
        let microValue = MicroValue(nutrientType: micronutrient, double: nil, string: "", unit: micronutrient.units.first ?? .g, fillType: fillType)
        self = .micro(microValue)
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
        case .macro(let macroValue):
            return macroValue.macro.description
        case .micro(let microValue):
            return microValue.nutrientType.description
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
            
        case .energy(let energyValue):
            return energyValue.isEmpty
            
        case .macro(let macroValue):
            return macroValue.isEmpty
        case .micro(let microValue):
            return microValue.isEmpty
        }
    }
}


extension FieldValue {

    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }
    
    var iconImageName: String {
        switch self {
        case .energy:
            return "flame.fill"
        case .macro:
            return "circle.circle.fill"
        case .micro:
            return "circle.circle"
        default:
            return ""
        }
    }
    
    var amountString: String {
        switch self {
        case .energy(let energyValue):
            return energyValue.double?.cleanAmount ?? "Required"
        case .macro(let macroValue):
            return macroValue.double?.cleanAmount ?? "Required"
        case .micro(let microValue):
            return microValue.double?.cleanAmount ?? ""
        default:
            return ""
        }
    }
    
    var double: Double? {
        switch self {
        case .energy(let energyValue):
            return energyValue.double
        case .macro(let macroValue):
            return macroValue.double
        case .micro(let microValue):
            return microValue.double
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.double
        default:
            return nil
        }
    }

    var unitString: String {
        switch self {
        case .energy(let energyValue):
            return energyValue.unitDescription
        case .macro(let macroValue):
            return macroValue.unitDescription
        case .micro(let microValue):
            return microValue.unitDescription
        default:
            return ""
        }
    }

    func labelColor(for colorScheme: ColorScheme) -> Color {
        guard !isEmpty else {
            return Color(.secondaryLabel)
        }
        switch self {
        case .energy(let energyValue):
            return energyValue.textColor(for: colorScheme)
        case .macro(let macroValue):
            return macroValue.textColor(for: colorScheme)
        case .micro(let microValue):
            return microValue.textColor(for: colorScheme)
        default:
            return .gray
        }
    }

    var fillType: FillType {
        get {
            switch self {
            case .energy(let energyValue):
                return energyValue.fillType
            case .macro(let macroValue):
                return macroValue.fillType
            case .micro(let microValue):
                return microValue.fillType
            case .name(let stringValue), .emoji(let stringValue), .brand(let stringValue), .barcode(let stringValue), .detail(let stringValue):
                return stringValue.fillType
            case .amount(let doubleValue), .serving(let doubleValue):
                return doubleValue.fillType
            case .density(let density):
                return density?.fillType ?? .userInput
            }
        }
        set {
            switch self {
            case .name(let stringValue):
                self = .name(StringValue(string: stringValue.string, fillType: newValue))
            case .emoji(let stringValue):
                self = .emoji(StringValue(string: stringValue.string, fillType: newValue))
            case .brand(let stringValue):
                self = .brand(StringValue(string: stringValue.string, fillType: newValue))
            case .barcode(let stringValue):
                self = .barcode(StringValue(string: stringValue.string, fillType: newValue))
            case .detail(let stringValue):
                self = .detail(StringValue(string: stringValue.string, fillType: newValue))
            case .amount(let doubleValue):
                self = .amount(DoubleValue(
                    double: doubleValue.double,
                    string: doubleValue.string,
                    unit: doubleValue.unit,
                    fillType: newValue)
                )
            case .serving(let doubleValue):
                self = .serving(DoubleValue(
                    double: doubleValue.double,
                    string: doubleValue.string,
                    unit: doubleValue.unit,
                    fillType: newValue)
                )
            case .density(let densityValue):
                self = .density(DensityValue(
                    weight: densityValue?.weight ?? DensityValue.DefaultWeight,
                    volume: densityValue?.volume ?? DensityValue.DefaultVolume,
                    fillType: newValue)
                )
            case .energy(let energyValue):
                self = .energy(EnergyValue(
                    double: energyValue.double,
                    string: energyValue.string,
                    unit: energyValue.unit,
                    fillType: newValue)
                )
            case .macro(let macroValue):
                self = .macro(MacroValue(
                    macro: macroValue.macro,
                    double: macroValue.double,
                    string: macroValue.string,
                    fillType: newValue)
                )
            case .micro(let microValue):
                self = .micro(MicroValue(
                    nutrientType: microValue.nutrientType,
                    double: microValue.double,
                    string: microValue.string,
                    unit: microValue.unit,
                    fillType: newValue)
                )
            }
        }
    }
    
    var fillButtonString: String {
        switch self {
        case .energy(let energyValue):
            return "\(energyValue.string) \(energyValue.unitDescription)"
        case .macro(let macroValue):
            return "\(macroValue.string) \(macroValue.unitDescription)"
        case .micro(let microValue):
            return "\(microValue.string) \(microValue.unitDescription)"
        default:
            return ""
        }
    }
}


extension FieldValue {
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
                self = .amount(newValue)
            case .serving:
                self = .serving(newValue)
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
    
    var energyValue: EnergyValue {
        get {
            switch self {
            case .energy(let energyValue):
                return energyValue
            default:
                return EnergyValue()
            }
        }
        set {
            switch self {
            case .energy:
                self = .energy(newValue)
            default:
                break
            }
        }
    }
    
    var macroValue: MacroValue {
        get {
            switch self {
            case .macro(let macroValue):
                return macroValue
            default:
                return MacroValue(macro: .carb)
            }
        }
        set {
            switch self {
            case .macro:
                self = .macro(newValue)
            default:
                break
            }
        }
    }

    var microValue: MicroValue {
        get {
            switch self {
            case .micro(let microValue):
                return microValue
            default:
                return MicroValue(nutrientType: .addedSugars)
            }
        }
        set {
            switch self {
            case .micro:
                self = .micro(newValue)
            default:
                break
            }
        }
    }

    var weight: DoubleValue {
        get {
            switch self {
            case .density(let density):
                return density?.weight ?? DensityValue.DefaultWeight
            default:
                return DensityValue.DefaultWeight
            }
        }
        set {
            switch self {
            case .density(let density):
                self = .density(DensityValue(weight: newValue, volume: density?.volume ?? DensityValue.DefaultVolume))
            default:
                break
            }
        }
    }
    
    var volume: DoubleValue {
        get {
            switch self {
            case .density(let density):
                return density?.volume ?? DensityValue.DefaultVolume
            default:
                return DensityValue.DefaultVolume
            }
        }
        set {
            switch self {
            case .density(let density):
                self = .density(DensityValue(weight: density?.weight ?? DensityValue.DefaultWeight, volume: newValue))
            default:
                break
            }
        }
    }

}
