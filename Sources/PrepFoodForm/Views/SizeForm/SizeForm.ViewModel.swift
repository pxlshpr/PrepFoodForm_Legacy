import SwiftUI

extension SizeForm {
    class ViewModel: ObservableObject {
        
        @Published var path: [Route] = []

        @Published var name: String = ""
        @Published var quantityString: String = "1"
        @Published var amountString: String = ""
        @Published var amountUnit: FormUnit = .weight(.g)

        @Published var showingVolumePrefix = false
        @Published var nameVolumeUnit: FormUnit = .volume(.cup)
        
        @Published var quantity: Double = 1

        init() {
        }
    }
}

extension SizeForm.ViewModel {
    
    var amount: Double? {
        guard let amount = Double(amountString) else {
            return nil
        }
        return amount > 0 ? amount : nil
    }
    
    var nameFieldString: String {
        guard !name.isEmpty else {
            return ""
        }
        return name
    }
    
    var amountFieldString: String {
        guard let amount = amount else {
            return ""
        }
        
        return "\(amount.cleanAmount) \(amountUnit.shortDescription)"
    }
}

extension SizeForm.ViewModel: UnitSelectorDelegate {
    func didPickUnit(unit: FormUnit) {
        withAnimation {
            amountUnit = unit
        }
    }
}
