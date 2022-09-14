import Foundation

struct Size: Hashable {
    var quantity: Double
    var volumePrefixUnit: FormUnit? = nil
    var name: String
    var amount: Double
    var amountUnit: FormUnit
}
