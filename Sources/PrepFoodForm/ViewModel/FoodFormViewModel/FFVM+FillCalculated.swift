import FoodLabelScanner

extension FoodFormViewModel {

    func calculatedFieldValue(for fieldValue: FieldValue) -> FieldValue? {
        var newFieldValue = fieldValue

        switch fieldValue {
        case .energy:
            /// First check if we have a calculated value from the scanResult (which will be indicated by it not having an associated text)
            if let energyFieldValue = calculatedFieldValueFromScanResults(for: .energy) {
                return energyFieldValue
            } else {
                /// If this is not the case—do the calculation ourself by seeing if we have 3 other components of the energy equation and if so—calculating it

            }


        case .macro:
            /// First check if we have a calculated value from the scanResult (which will be indicated by it not having an associated text)
            if let macroFieldValue = calculatedFieldValueFromScanResults(for: fieldValue.macroValue.macro.attribute) {
                return macroFieldValue
            } else {
                /// If this is not the case—do the calculation ourself by seeing if we have 3 other components of the energy equation and if so—calculating it
                newFieldValue.macroValue.double = 54

            }


        default:
            return nil
        }
        newFieldValue.fillType = .calculated
        return newFieldValue
    }

    func calculatedFieldValueFromScanResults(for attribute: Attribute) -> FieldValue? {
        guard let fieldValue = fieldValueFromScanResults(for: attribute),
              fieldValue.fillType == .calculated
        else {
            return nil
        }
        return fieldValue
    }
}
