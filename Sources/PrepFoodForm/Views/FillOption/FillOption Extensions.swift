import PrepUnits
import VisionSugar

extension String {
    var energyValue: FoodLabelValue? {
        let values = FoodLabelValue.detect(in: self)
        /// Returns the first energy value detected, otherwise the first value regardless of the unit
        let value = values.first(where: { $0.unit?.isEnergy == true }) ?? values.first
        
        if let value, value.unit != .kj {
            ///  Always set the unit to kcal as a fallback for energy values
            return FoodLabelValue(amount: value.amount, unit: .kcal)
        }
        
        /// This would either be `nil` for `FoodLabelValue` with an energy unit
        return value
    }
    
    var energyValueDescription: String {
        guard let energyValue else { return "" }
        
        /// If the found `energyValue` actually has an energy unit—return its entire description, otherwise only return the number
        if energyValue.unit?.isEnergy == true {
            return energyValue.description
        } else {
            return "\(energyValue.amount.cleanAmount) kcal"
        }
    }
}

extension RecognizedText {
    func fillButtonString(for fieldValue: FieldValue) -> String {
        switch fieldValue {
        case .energy:
            return string.energyValueDescription
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
        default:
            return string
        }
    }
}
