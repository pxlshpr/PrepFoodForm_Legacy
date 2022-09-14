import Foundation

struct Size: Hashable, Equatable {
    var quantity: Double
    var volumePrefixUnit: FormUnit? = nil
    var name: String
    var amount: Double
    var amountUnit: FormUnit
    
    var isVolumePrefixed: Bool {
        volumePrefixUnit != nil
    }
}
