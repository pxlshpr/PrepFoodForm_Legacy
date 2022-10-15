import FoodLabelScanner
import PrepUnits

extension ScanResult {
        
    func amountFieldValue(for column: Int) -> FieldValue? {
        if headerType(for: column) != .perServing {
            return headerFieldValue(for: column)
        } else {
            guard let valueText = amountValueText(for: column) else { return nil }
            return FieldValue.amount(FieldValue.DoubleValue(
                double: 1, string: "1", unit: .serving, fill: scannedFill(
                    for: valueText,
                    value: FoodLabelValue(amount: 1, unit: nil)
                ))
            )
        }
    }
    
    func servingFieldValue(for column: Int) -> FieldValue? {
        /// If we have a header type for the column and it's not `.perServing`, return `nil` immediately
        if let headerType = headerType(for: column) {
            guard headerType == .perServing else {
                return nil
            }
        }
        
        if let servingAmount, let servingAmountValueText {
            return FieldValue.serving(FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: servingFormUnit,
                fill: scannedFill(
                    for: servingAmountValueText,
                    value: FoodLabelValue(
                        amount: servingAmount,
                        unit: servingFormUnit.foodLabelUnit
                    )
                )
            ))
        }
        //        else if headerType(for: column) == .perServing {
        //            return headerFieldValue(for: column)
        //        } else {
        //            return nil
        //        }
        else {
            return headerFieldValue(for: column)
        }
    }
    
    func energyFieldValue(at column: Int) -> FieldValue? {
        guard let row = row(for: .energy),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              valueText.text.id != defaultUUID /// Ignores all calculated values without an attached `RecognizedText`
        else {
            return nil
        }
        return FieldValue.energy(FieldValue.EnergyValue(
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.energyUnit ?? .kcal,
            fill: .scanned(.init(valueText: valueText, imageId: id))
        ))
    }
    
    func macroFieldValue(for macro: Macro, at column: Int) -> FieldValue? {
        guard let row = row(for: macro.attribute),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              valueText.text.id != defaultUUID /// Ignores all calculated values without an attached `RecognizedText`
        else {
            return nil
        }
        
        return FieldValue.macro(FieldValue.MacroValue(
            macro: macro,
            double: value.amount,
            string: value.amount.cleanAmount,
            fill: .scanned(.init(valueText: valueText, imageId: id))
        ))
    }

    func microFieldValue(for nutrientType: NutrientType, at column: Int) -> FieldValue? {
        guard let attribute = nutrientType.attribute,
              let row = row(for: attribute),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              valueText.text.id != defaultUUID /// Ignores all calculated values without an attached `RecognizedText`
        else {
            return nil
        }
        
        let fill = Fill.scanned(.init(valueText: valueText, imageId: id))
        let unit = value.unit?.nutrientUnit(for: nutrientType) ?? nutrientType.defaultUnit
        
        return FieldValue.micro(FieldValue.MicroValue(
            nutrientType: nutrientType,
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: unit,
            fill: fill)
        )
    }

    
    func row(for attribute: Attribute) -> ScanResult.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}
