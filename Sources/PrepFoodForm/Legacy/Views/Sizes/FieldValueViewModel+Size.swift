import Foundation
import PrepDataTypes

extension Field {
    var size: FormSize? {
        value.size
    }

    var fill: Fill {
        value.fill
    }

    var sizeVolumePrefixString: String {
        sizeVolumePrefixUnit.shortDescription
    }
    
    var sizeAmountUnitString: String {
        sizeAmountUnit.shortDescription
    }
    var sizeNameString: String {
        size?.name ?? ""
    }
    
    var sizeAmountDescription: String {
        guard let amount = size?.amount, amount > 0 else {
            return ""
        }
        return "\(amount.cleanAmount) \(sizeAmountUnitString)"
    }
    
    var sizeAmountString: String {
        get {
            size?.amountString ?? ""
        }
        set {
            guard let size = self.size else {
                return
            }
            var newSize = size
            newSize.amountString = newValue
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    var sizeVolumePrefixUnit: FormUnit {
        size?.volumePrefixUnit ?? .volume(.cup)
    }
    
    var sizeQuantityString: String {
        get {
            size?.quantityString ?? "1"
        }
        set {
            guard let size = self.size else {
                return
            }
            var newSize = size
            newSize.quantityString = newValue
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    
    var sizeQuantity: Double {
        get {
            size?.quantity ?? 1
        }
        set {
            guard let size = self.size else { return }
            var newSize = size
            newSize.quantity = newValue
            newSize.quantityString = newValue.cleanAmount
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    
    var sizeAmountUnit: FormUnit {
        get {
            size?.unit ?? .serving
        }
        set {
            guard let size = self.size else { return }
            var newSize = size
            newSize.unit = newValue
            self.value = .size(.init(size: newSize, fill: value.fill))
        }
    }
    
    var sizeAmountIsValid: Bool {
        guard let amount = size?.amount, amount > 0 else {
            return false
        }
        return true
    }

}
