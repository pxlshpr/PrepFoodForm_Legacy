import Foundation
import PrepUnits

struct Size: Hashable {
    
    var quantity: Double? = 1
    var quantityString: String = ""
    var volumePrefixUnit: FormUnit? = nil
    var name: String = ""
    var amount: Double?
    var amountString: String = ""
    var unit: FormUnit = .weight(.g)
    
    var fillType: FillType = .userInput
}

extension Size: Identifiable {
    var id: Int {
        hashValue
    }
}

extension Size {

    var isVolumePrefixed: Bool {
        volumePrefixUnit != nil
    }
    
    var volumePrefixString: String? {
        volumePrefixUnit?.shortDescription
    }
    
    var fullNameString: String {
        if let volumePrefixString {
            return "\(volumePrefixString), \(name)"
        } else {
            return name
        }
    }

    var scaledAmount: Double {
        guard let quantity, let amount, quantity > 0 else {
            return 0
        }
        return amount / quantity
    }
    
    var scaledAmountString: String {
        "\(scaledAmount.cleanAmount) \(unit.shortDescription)"
    }
    
    var isServingBased: Bool {
        unit.isServingBased
    }
    
    var isMeasurementBased: Bool {
        unit.isMeasurementBased
    }
    
    var isWeightBased: Bool {
        unit.isWeightBased
    }
    
    var isVolumeBased: Bool {
        unit.isVolumeBased
    }

    func namePrefixed(with volumeUnit: VolumeUnit?) -> String {
        if let volumeUnit = volumeUnit {
            return "\(volumeUnit.shortDescription) \(name)"
        } else {
            return prefixedName
        }
    }
    
    var prefixedName: String {
        if let volumePrefixString {
            return "\(volumePrefixString) \(name)"
        } else {
            return name
        }
    }
}
