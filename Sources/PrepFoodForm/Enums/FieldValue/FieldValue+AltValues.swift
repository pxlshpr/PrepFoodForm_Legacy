import FoodLabelScanner
import PrepUnits

extension FieldValue {
    var altValues: [FoodLabelValue] {
//        guard !fillType.isAltValue else { return [] }
        switch self {
        case .energy(let energyValue):
            return energyValue.altValues
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .name(let stringValue):
//            <#code#>
//        case .emoji(let stringValue):
//            <#code#>
//        case .brand(let stringValue):
//            <#code#>
//        case .barcode(let stringValue):
//            <#code#>
//        case .detail(let stringValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
        default:
            return []
        }
    }
}

extension FieldValue.EnergyValue {
    var altValues: [FoodLabelValue] {
        guard let originalImageValue else { return [] }
        
        /// First add the opposite unit
        var values: [FoodLabelValue] = []
        let unit = originalImageValue.unit?.energyUnit ?? .kcal
        switch unit {
        case .kJ:
            values.append(FoodLabelValue(amount: originalImageValue.amount, unit: .kcal))
        case .kcal:
            values.append(FoodLabelValue(amount: originalImageValue.amount, unit: .kj))
        }
        
        /// Add any other values that were found
        for value in fillType.detectedValues {
            guard value.amount != double else { continue }
            values.append(FoodLabelValue(amount: value.amount, unit: value.unit?.isEnergy == true ? value.unit : nil))
        }
        
        return values
    }
}
