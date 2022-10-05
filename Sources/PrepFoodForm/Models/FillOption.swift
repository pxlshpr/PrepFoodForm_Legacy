import Foundation
import PrepUnits

struct FillOption: Hashable {
    let string: String
    let systemImage: String
    let isSelected: Bool
    let disableWhenSelected: Bool
    let type: FillOptionType
    
    init(string: String, systemImage: String, isSelected: Bool, disableWhenSelected: Bool = true, type: FillOptionType) {
        self.string = string
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.disableWhenSelected = disableWhenSelected
        self.type = type
    }
}

extension FoodLabelValue {
    public var fillOptionString: String {
        if let unit = unit {
            return "\(amount.cleanAmount) \(unit.description)"
        } else {
            return "\(amount.cleanAmount)"
        }
    }
}
