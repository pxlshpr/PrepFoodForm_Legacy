import FoodLabelScanner

extension ScanResult {
    var fieldValueForServing: (fieldValue: FieldValue, sizesToAdd: [Size])? {
        guard let serving, let servingAmount = serving.amount, servingAmount > 0
        else {
            return nil
        }
        
        var sizesToAdd: [Size] = []
        let fieldValue: FieldValue
        if let unitNameText = serving.unitNameText {
            let size: Size
            if let equivalentSize = serving.equivalentSize {
                if let equivalentSizeUnitNameText = serving.equivalentSize?.unitNameText {
                    let size2 = Size(
                        name: equivalentSizeUnitNameText.string,
                        amount: 1.0/servingAmount/equivalentSize.amount,
                        unit: .serving)
                    size = Size(
                        name: unitNameText.string,
                        amount: equivalentSize.amount,
                        unit: .size(size2, nil))
                    sizesToAdd = [size, size2]
                } else {
                    let unit = equivalentSize.unit?.formUnit ?? .weight(.g)
                    size = Size(
                        name: unitNameText.string,
                        amount: equivalentSize.amount,
                        unit: unit)
                    sizesToAdd = [size]
                }
            } else {
                size = Size(
                    name: unitNameText.string,
                    amount: 1.0/servingAmount,
                    unit: .serving)
                sizesToAdd = [size]
            }
            
            /// We have a size now
            fieldValue = FieldValue.serving(FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: .size(size, nil),
                fillType: .userInput
            ))

        } else {
            let unit = serving.unit?.formUnit ?? .weight(.g)
            fieldValue = FieldValue.serving(FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: unit,
                fillType: .userInput
            ))
        }
        return (fieldValue, sizesToAdd)
//        guard let row = row(for: .energy),
//              let valueText = row.valueText1,
//              let value = row.value1
//        else {
//            return nil
//        }
//        let fillType = .imageAutofill(valueText: valueText, scanResultId: self.id)
//        return FieldValue.energy(FieldValue.EnergyValue(
//            double: value.amount,
//            string: value.amount.cleanAmount,
//            unit: value.unit?.energyUnit ?? .kcal,
//            fillType: fillType)
//        )
    }
    
}
