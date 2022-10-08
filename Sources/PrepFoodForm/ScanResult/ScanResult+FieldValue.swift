import FoodLabelScanner
import PrepUnits

extension ScanResult {

    var amountFieldValue: FieldValue? {
        if false {
            /// get amountPer from header here
        } else {
            /// As a fallback return the `servingFieldValue` as we'll be using that if no headers were found
            return servingFieldValue
        }
    }

    var servingFieldValue: FieldValue? {
        guard let servingAmount, let servingAmountValueText else { return nil }
        return FieldValue.serving(FieldValue.DoubleValue(
            double: servingAmount,
            string: servingAmount.cleanAmount,
            unit: servingFormUnit,
            fillType: autoFillType(for: servingAmountValueText)
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
