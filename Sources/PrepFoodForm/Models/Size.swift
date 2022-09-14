import Foundation
import PrepUnits

struct Size: Hashable, Equatable {
    var quantity: Double
    var volumePrefixUnit: FormUnit? = nil
    var name: String
    var amount: Double
    var amountUnit: FormUnit
    
    var isVolumePrefixed: Bool {
        volumePrefixUnit != nil
    }
    
    var prefixedName: String {
        if let volumePrefixUnit = volumePrefixUnit {
            return "\(volumePrefixUnit.shortDescription) \(name)"
        } else {
            return name
        }
    }
    
    func namePrefixed(with volumeUnit: VolumeUnit?) -> String {
        if let volumeUnit = volumeUnit {
            return "\(volumeUnit.shortDescription) \(name)"
        } else {
            return prefixedName
        }
    }
}
