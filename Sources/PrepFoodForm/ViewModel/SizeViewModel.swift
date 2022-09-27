import SwiftUI

struct SizeViewModel: Hashable {
    let size: Size
    
    var volumePrefixString: String? {
        guard let unit = size.volumePrefixUnit else {
            return nil
        }
        return unit.shortDescription
    }
    
    var nameString: String {
        size.name
    }
    
    var fullNameString: String {
        if let volumePrefixUnit = size.volumePrefixUnit {
            return "\(volumePrefixUnit.shortDescription), \(nameString)"
        } else {
            return nameString
        }
    }
    
    var quantity: Double {
        size.quantity
    }
    var quantityString: String {
        size.quantity.cleanAmount
    }
    
    var amountString: String {
        "\(size.amount.cleanAmount) \(size.amountUnit.shortDescription)"
    }
    
    var scaledAmount: Double {
        guard size.quantity > 0 else {
            return 0
        }
        return size.amount / size.quantity
    }
    
    var scaledAmountString: String {
        "\(scaledAmount.cleanAmount) \(size.amountUnit.shortDescription)"
    }
}
