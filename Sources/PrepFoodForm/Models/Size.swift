import Foundation
import PrepUnits

struct Size: Hashable, Codable {
    
    var volumePrefixUnit: FormUnit?
    var name: String
    var unit: FormUnit
    
    /**
     These are required to support decimal places in textfields.
     
     For instance, if the user is in the midst of typing out `3.5`:
        - as soon as they enter the text `3.`
        - the value gets stored as the double `3.0`, losing the information of the decimal place
        - this then gets reset to `3` by the getter of the `amountString` or `quantityString` helper, thus never being able to see the `.` being entered.
     */
    private var internalQuantityString = ""
    private var internalAmountString = ""
    
    private var internalQuantity: Double?
    private var internalAmount: Double?

    init(quantity: Double = 1,
         volumePrefixUnit: FormUnit? = nil,
         name: String = "",
         amount: Double? = nil,
         unit: FormUnit = .serving
    ) {
        self.volumePrefixUnit = volumePrefixUnit
        self.name = name
        self.unit = unit
        
        self.amount = amount
        self.quantity = quantity
    }
    
    var isValid: Bool {
        guard let quantity, quantity > 0,
              let amount, amount > 0,
              !name.isEmpty else {
            return false
        }
        return true
    }
}

extension Size {
    
    var quantity: Double? {
        get {
            return internalQuantity
        }
        set {
            internalQuantity = newValue
            internalQuantityString = newValue?.cleanAmount ?? ""
        }
    }

    var amount: Double? {
        get {
            return internalAmount
        }
        set {
            internalAmount = newValue
            internalAmountString = newValue?.cleanAmount ?? ""
        }
    }

    var amountString: String {
        get {
            internalAmountString
        }
        set {
            guard !newValue.isEmpty else {
                internalAmount = nil
                internalAmountString = newValue /// empty string
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            internalAmount = double
            internalAmountString = newValue /// this is required to ensure strings such as "3." are captured while the user is typing them out
        }
    }
    
    var quantityString: String {
        get {
            internalQuantityString
        }
        set {
            guard !newValue.isEmpty else {
                internalQuantity = nil
                internalQuantityString = newValue /// empty string
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            internalQuantity = double
            internalQuantityString = newValue /// this is required to ensure strings such as "3." are captured while the user is typing them out
        }
    }
}

extension Size: Identifiable {
    var id: Int {
        hashValue
    }
}

extension Size {
    
    var isEmpty: Bool {
        quantity == 1
        && volumePrefixUnit == nil
        && name == ""
        && amount == nil
    }

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
