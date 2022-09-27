import Foundation
import PrepUnits

enum NewSize {
    case standard(quantity: Double? = 1, quantityString: String = "", name: String = "", amount: Double?, amountString: String = "", unit: FormUnit = .weight(.g))
    case volumePrefixed(quantity: Double? = 1, quantityString: String = "", volumePrefixUnit: VolumeUnit = .cup, name: String = "", amount: Double?, amountString: String = "", unit: FormUnit = .weight(.g))
}

extension NewSize {
    var volumePrefixString: String? {
        switch self {
        case .standard(_, _, _, _, _, _):
            return nil
        case .volumePrefixed(_, _, let volumePrefixUnit, _, _, _, _):
            return volumePrefixUnit.shortDescription
        }
    }
    
    var nameString: String {
        get {
            switch self {
            case .standard(_, _, let name, _, _, _):
                return name
            case .volumePrefixed(_, _, _, let name, _, _, _):
                return name
            }
        }
        set {
            switch self {
            case .standard(let quantity, let quantityString, _, let amount, let amountString, let unit):
                self = .standard(quantity: quantity, quantityString: quantityString, name: newValue, amount: amount, amountString: amountString, unit: unit)
            case .volumePrefixed(let quantity, let quantityString, let volumePrefixUnit, _, let amount, let amountString, let unit):
                self = .volumePrefixed(quantity: quantity, quantityString: quantityString, volumePrefixUnit: volumePrefixUnit, name: newValue, amount: amount, amountString: amountString, unit: unit)
            }
        }
    }
    
    var quantityString: String {
        get {
            switch self {
            case .standard(_, let quantityString, _, _, _, _):
                return quantityString
            case .volumePrefixed(_, let quantityString, _, _, _, _, _):
                return quantityString
            }
        }
        set {
            switch self {
            case .standard(_, _, let name, let amount, let amountString, let unit):
                guard !newValue.isEmpty else {
                    self = .standard(quantity: nil, quantityString: newValue, name: name, amount: amount, amountString: amountString, unit: unit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .standard(quantity: double, quantityString: newValue, name: name, amount: amount, amountString: amountString, unit: unit)
            case .volumePrefixed(_, _, let volumePrefixUnit, let name, let amount, let amountString, let unit):
                guard !newValue.isEmpty else {
                    self = .volumePrefixed(quantity: nil, quantityString: newValue, volumePrefixUnit: volumePrefixUnit, name: name, amount: amount, amountString: amountString, unit: unit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .volumePrefixed(quantity: double, quantityString: newValue, volumePrefixUnit: volumePrefixUnit, name: name, amount: amount, amountString: amountString, unit: unit)
            }
        }
    }
    
    var amountString: String {
        get {
            switch self {
            case .standard(_, _, _, _, let amountString, _):
                return amountString
            case .volumePrefixed(_, _, _, _, _, let amountString, _):
                return amountString
            }
        }
        set {
            switch self {
            case .standard(let quantity, let quantityString, let name, _, _, let unit):
                guard !newValue.isEmpty else {
                    self = .standard(quantity: quantity, quantityString: quantityString, name: name, amount: nil, amountString: newValue, unit: unit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .standard(quantity: quantity, quantityString: quantityString, name: name, amount: double, amountString: newValue, unit: unit)
            case .volumePrefixed(let quantity, let quantityString, let volumePrefixUnit, let name, _, _, let unit):
                guard !newValue.isEmpty else {
                    self = .volumePrefixed(quantity: quantity, quantityString: quantityString, volumePrefixUnit: volumePrefixUnit, name: name, amount: nil, amountString: newValue, unit: unit)
                    return
                }
                guard let double = Double(newValue) else {
                    return
                }
                self = .volumePrefixed(quantity: quantity, quantityString: quantityString, volumePrefixUnit: volumePrefixUnit, name: name, amount: double, amountString: newValue, unit: unit)
            }
        }
    }
    
    var quantityDouble: Double? {
        get {
            switch self {
            case .standard(let quantity, _, _, _, _, _):
                return quantity
            case .volumePrefixed(let quantity, _, _, _, _, _, _):
                return quantity
            }
        }
        set {
            switch self {
            case .standard(_, _, let name, let amount, let amountString, let unit):
                self = .standard(quantity: newValue, quantityString: newValue?.cleanAmount ?? "", name: name, amount: amount, amountString: amountString, unit: unit)
            case .volumePrefixed(_, _, let volumePrefixUnit, let name, let amount, let amountString, let unit):
                self = .volumePrefixed(quantity: newValue, quantityString: newValue?.cleanAmount ?? "", volumePrefixUnit: volumePrefixUnit, name: name, amount: amount, amountString: amountString, unit: unit)
            }
        }
    }
    
    var amountDouble: Double? {
        get {
            switch self {
            case .standard(_, _, _, let amount, _, _):
                return amount
            case .volumePrefixed(_, _, _, _, let amount, _, _):
                return amount
            }
        }
        set {
            switch self {
            case .standard(let quantity, let quantityString, let name, _, _, let unit):
                self = .standard(quantity: quantity, quantityString: quantityString, name: name, amount: newValue, amountString: newValue?.cleanAmount ?? "", unit: unit)
            case .volumePrefixed(let quantity, let quantityString, let volumePrefixUnit, let name, _, _, let unit):
                self = .volumePrefixed(quantity: quantity, quantityString: quantityString, volumePrefixUnit: volumePrefixUnit, name: name, amount: newValue, amountString: newValue?.cleanAmount ?? "", unit: unit)
            }
        }
    }
    
    var unit: FormUnit {
        get {
            switch self {
            case .standard(_, _, _, _, _, let unit):
                return unit
            case .volumePrefixed(_, _, _, _, _, _, let unit):
                return unit
            }
        }
        set {
            switch self {
            case .standard(let quantity, let quantityString, let name, let amount, let amountString, _):
                self = .standard(quantity: quantity, quantityString: quantityString, name: name, amount: amount, amountString: amountString, unit: newValue)
            case .volumePrefixed(let quantity, let quantityString, let volumePrefixUnit, let name, let amount, let amountString, _):
                self = .volumePrefixed(quantity: quantity, quantityString: quantityString, volumePrefixUnit: volumePrefixUnit, name: name, amount: amount, amountString: amountString, unit: newValue)
            }
        }
    }
}

extension NewSize {
    
    var fullNameString: String {
        if let volumePrefixString {
            return "\(volumePrefixString), \(nameString)"
        } else {
            return nameString
        }
    }

    var scaledAmount: Double {
        guard let quantityDouble, let amountDouble, quantityDouble > 0 else {
            return 0
        }
        return amountDouble / quantityDouble
    }
    
    var scaledAmountString: String {
        "\(scaledAmount.cleanAmount) \(unit.shortDescription)"
    }
}

class Size: Identifiable {
    var id = UUID()
    var quantity: Double
    var volumePrefixUnit: FormUnit? = nil
    var name: String
    var amount: Double
    var amountUnit: FormUnit
    
    init(quantity: Double, volumePrefixUnit: FormUnit? = nil, name: String, amount: Double, amountUnit: FormUnit) {
        self.quantity = quantity
        self.volumePrefixUnit = volumePrefixUnit
        self.name = name
        self.amount = amount
        self.amountUnit = amountUnit
    }
    
    var isVolumePrefixed: Bool {
        volumePrefixUnit != nil
    }
    
    var prefixedName: String {
        if let volumePrefixUnit = volumePrefixUnit {
            return "\(volumePrefixUnit.shortDescription) \(name)"
        } else {
            return name
        }
    }
    
    func namePrefixed(with volumeUnit: VolumeUnit?) -> String {
        if let volumeUnit = volumeUnit {
            return "\(volumeUnit.shortDescription) \(name)"
        } else {
            return prefixedName
        }
    }
    
    var isServingBased: Bool {
        amountUnit.isServingBased
    }
    
    var isMeasurementBased: Bool {
        amountUnit.isMeasurementBased
    }
    
    var isWeightBased: Bool {
        amountUnit.isWeightBased
    }
    
    var isVolumeBased: Bool {
        amountUnit.isVolumeBased
    }
}

extension Size: Equatable {
    static func ==(lhs: Size, rhs: Size) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension Size: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(quantity)
        hasher.combine(volumePrefixUnit)
        hasher.combine(name)
        hasher.combine(amount)
        hasher.combine(amountUnit)
    }
}
