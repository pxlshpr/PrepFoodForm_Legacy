import FoodLabelScanner
import PrepUnits

extension ScanResult {
    var servingFieldValue: FieldValue? {
        guard let servingAmount else { return nil }
        return FieldValue.serving(FieldValue.DoubleValue(
            double: servingAmount,
            string: servingAmount.cleanAmount,
            unit: servingFormUnit,
            fillType: .userInput //TODO: Do FillType
        ))
    }
    
    var servingFormUnit: FormUnit {
        if let servingUnitNameText {
            let size = Size(
                name: servingUnitNameText.string,
                amount: servingUnitAmount,
                unit: servingUnitSizeUnit
            )
            return .size(size, nil)
        } else {
            return servingUnit?.formUnit ?? .weight(.g)
        }
    }
    
    var servingUnitAmount: Double {
        if let equivalentSize {
            return equivalentSize.amount
        } else {
            return servingAmount ?? 1
        }
    }
    
    var servingUnitSizeUnit: FormUnit {
        if let equivalentSizeFormUnit {
            return equivalentSizeFormUnit
        } else {
            return .serving
        }
    }
    
    
    var equivalentSizeFormUnit: FormUnit? {
        if let equivalentSizeUnitSize {
            return .size(equivalentSizeUnitSize, nil)
        } else {
            return equivalentSize?.unit?.formUnit ?? .weight(.g)
        }
    }
    
    var equivalentSizeUnitSize: Size? {
        guard let equivalentSize, equivalentSize.amount > 0,
              let servingAmount, servingAmount > 0
        else {
            return nil
        }
        
        if let unitNameText = equivalentSize.unitNameText {
            return Size(
                name: unitNameText.string,
                amount: 1.0/servingAmount/equivalentSize.amount,
                unit: .serving)
        } else {
            return nil
        }
    }
    
    var servingAmount: Double? {
        serving?.amount
    }
    
    var servingUnitNameText: StringText? {
        serving?.unitNameText
    }
    
    var servingUnit: FoodLabelUnit? {
        serving?.unit
    }
    var equivalentSize: ScanResult.Serving.EquivalentSize? {
        serving?.equivalentSize
    }
}

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
                    
                    /// Equivalent Size Unit-Size
                    let size2 = Size(
                        name: equivalentSizeUnitNameText.string,
                        amount: 1.0/servingAmount/equivalentSize.amount,
                        unit: .serving)
                    
                    /// **Serving Size Unit-Size**
                    size = Size(
                        name: unitNameText.string,
                        amount: equivalentSize.amount,
                        unit: .size(size2, nil))
                    sizesToAdd = [size, size2]
                } else {
                    let unit = equivalentSize.unit?.formUnit ?? .weight(.g)
                    
                    /// **Serving Size Unit-Size**
                    size = Size(
                        name: unitNameText.string,
                        amount: equivalentSize.amount,
                        unit: unit)
                    sizesToAdd = [size]
                }
            } else {
                
                /// **Serving Size Unit-Size**
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
