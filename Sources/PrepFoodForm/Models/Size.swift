import Foundation
import PrepUnits


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
