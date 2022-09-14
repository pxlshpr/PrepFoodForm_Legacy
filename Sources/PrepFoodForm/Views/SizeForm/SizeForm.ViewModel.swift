import SwiftUI

extension SizeForm {
    class ViewModel: ObservableObject {
        
        @Published var path: [Route] = []

        @Published var name: String = ""
        @Published var quantityString: String = "1"
        @Published var amountString: String = ""
        @Published var amountUnit: FormUnit = .weight(.g)

        @Published var showingVolumePrefix = false
        @Published var volumePrefixUnit: FormUnit = .volume(.cup)
        
        @Published var quantity: Double = 1

        init() {
        }
    }
}

extension SizeForm.ViewModel {
    var size: Size? {
        guard isValid, let amount = amount else {
            return nil
        }
        return Size(
            quantity: quantity,
            volumePrefixUnit: showingVolumePrefix ? volumePrefixUnit : nil,
            name: name,
            amount: amount,
            amountUnit: amountUnit
        )
    }
}

extension SizeForm.ViewModel {
    
    var isValid: Bool {
        guard let _ = amount else { return false }
        return !name.isEmpty
        && quantity > 0
    }
    
    var amountIsValid: Bool {
        guard let amount = amount, amount > 0 else {
            return false
        }
        return true
    }
    var amount: Double? {
        Double(amountString) ?? 0
    }
    
    var nameFieldString: String {
        guard !name.isEmpty else {
            return ""
        }
        return name
    }
    
    var amountFieldString: String {
        guard let amount = amount, amountIsValid else {
            return ""
        }
        
        return "\(amount.cleanAmount) \(amountUnit.shortDescription)"
    }
}
