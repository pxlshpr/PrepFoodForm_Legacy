import Foundation

extension FieldValueViewModel {
    var size: Size? {
        fieldValue.size
    }

    var fillType: FillType {
        fieldValue.fillType
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
            self.fieldValue = .size(.init(size: newSize, fillType: fieldValue.fillType))
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
            self.fieldValue = .size(.init(size: newSize, fillType: fieldValue.fillType))
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
            self.fieldValue = .size(.init(size: newSize, fillType: fieldValue.fillType))
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
            self.fieldValue = .size(.init(size: newSize, fillType: fieldValue.fillType))
        }
    }
    
    var sizeAmountIsValid: Bool {
        guard let amount = size?.amount, amount > 0 else {
            return false
        }
        return true
    }

}
