import SwiftUI

extension SizeForm {
    class ViewModel: ObservableObject {

        @Published var includeServing: Bool
        @Published var allowAddSize: Bool

        @Published var path: [Route] = []
        
        @Published var name: String = "" {
            didSet {
                withAnimation {
                    isValid = getIsValid()
                }
            }
        }
        
        @Published var quantityString: String = "1" {
            didSet {
                withAnimation {
                    isValid = getIsValid()
                }
            }
        }
        
        @Published var amountString: String = "" {
            didSet {
                withAnimation {
                    isValid = getIsValid()
                }
            }
        }
        
        @Published var amountUnit: FormUnit = .weight(.g)

        @Published var showingVolumePrefix = false
        @Published var volumePrefixUnit: FormUnit = .volume(.cup)
        
        @Published var quantity: Double = 1
        
        @Published var isValid: Bool = false

        init(includeServing: Bool = true, allowAddSize: Bool = true) {
            self.includeServing = includeServing
            self.allowAddSize = allowAddSize
        }
    }
}

extension SizeForm.ViewModel {
    var size: Size? {
        guard isValid, let amount = amount else {
            return nil
        }
        let shouldSaveVolumePrefix = amountUnit.unitType == .weight && showingVolumePrefix
        return Size(
            quantity: quantity,
            volumePrefixUnit: shouldSaveVolumePrefix ? volumePrefixUnit : nil,
            name: name,
            amount: amount,
            amountUnit: amountUnit
        )
    }
}

extension SizeForm.ViewModel {
    
    func getIsValid() -> Bool {
        guard !amountString.isEmpty, let _ = amount else { return false }
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
