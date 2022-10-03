import FoodLabelScanner

extension FillType {
    var isAltValue: Bool {
        altValue != nil
    }
    var altValue: Value? {
        switch self {
        case .imageSelection(_, _, _, let value):
            return value
        case .imageAutofill(_, _, let value):
            return value
        default:
            return nil
        }
    }
}
extension FieldValue {
    var altValues: [Value] {
        guard !fillType.isAltValue else { return [] }
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
        var values: [Value] = []
        switch unit {
        case .kJ:
            values.append(Value(amount: double, unit: .kcal))
        case .kcal:
            values.append(Value(amount: double, unit: .kj))
        }
        return values
    }
}
