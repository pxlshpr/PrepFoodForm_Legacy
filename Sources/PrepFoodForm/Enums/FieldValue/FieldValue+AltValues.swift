import FoodLabelScanner

extension FieldValue {
    var altValues: [Value] {
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
    var altValues: [Value] {
        guard let double else { return [] }
        
        /// First add the opposite unit
        var values: [Value] = []
        switch unit {
        case .kJ:
            values.append(Value(amount: double, unit: .kcal))
        case .kcal:
            values.append(Value(amount: double, unit: .kj))
        }
        
        /// Add any other values that were found
        for value in fillType.detectedValues {
            guard value.amount != double else { continue }
            values.append(Value(amount: value.amount, unit: value.unit?.isEnergy == true ? value.unit : nil))
        }
        
        return values
    }
}
