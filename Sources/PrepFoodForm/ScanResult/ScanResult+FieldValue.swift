import FoodLabelScanner
import PrepUnits

extension ScanResult.Headers {
    var serving: HeaderText.Serving? {
        if header1Type == .perServing {
            return headerText1?.serving
        } else if header2Type == .perServing {
            return headerText2?.serving
        } else {
            return nil
        }
    }
}

extension ScanResult {

    var amountFieldValue: FieldValue? {
        if false {
            //TODO: Header
            /// get amountPer from header here
        } else {
            /// As a fallback return the `servingFieldValue` as we'll be using that if no headers were found
            return servingFieldValue(for: 1) //TODO: Header
        }
    }

    func servingFieldValue(for column: Int) -> FieldValue? {
        if let servingAmount, let servingAmountValueText {
            return FieldValue.serving(FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: servingFormUnit,
                fillType: autoFillType(for: servingAmountValueText)
            ))
        }
        else if let headerServingAmount, let headerServingValueText {
            return FieldValue.serving(FieldValue.DoubleValue(
                double: headerServingAmount,
                string: headerServingAmount.cleanAmount,
                unit: headerServingFormUnit,
                fillType: autoFillType(for: headerServingValueText)
            ))
        }
        return nil
    }
    
    var headerServingValueText: ValueText? {
        guard let headers else { return nil }
        if headers.header1Type == .perServing {
            return headers.headerText1?.text.asValueText
        } else if headers.header2Type == .perServing {
            return headers.headerText2?.text.asValueText
        } else {
            return nil
        }
    }
    
    var headerServingAmount: Double? {
        return headers?.serving?.amount
    }

    var headerServingFormUnit: FormUnit {
        if let headerServingUnitName {
            let size = Size(
                name: headerServingUnitName,
                amount: headerServingUnitAmount,
                unit: headerServingUnitSizeUnit
            )
            return .size(size, nil)
        } else {
            return headerServingUnit?.formUnit ?? .weight(.g)
        }
    }
    
    var headerServingUnitName: String? {
        headers?.serving?.unitName
    }
    
    var headerServingUnitAmount: Double {
        if let headerEquivalentSize {
            return headerEquivalentSize.amount
        } else {
            return headers?.serving?.amount ?? 1
        }
    }
    
    var headerServingUnitSizeUnit: FormUnit {
        headerEquivalentSizeFormUnit ?? .serving
    }
    
    var headerServingUnit: FoodLabelUnit? {
        headers?.serving?.unit
    }

    var headerEquivalentSize: HeaderText.Serving.EquivalentSize? {
        headers?.serving?.equivalentSize
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
        equivalentSizeFormUnit ?? .serving
    }
    
    var equivalentSizeFormUnit: FormUnit? {
        if let equivalentSizeUnitSize {
            return .size(equivalentSizeUnitSize, nil)
        } else {
            return equivalentSize?.unit?.formUnit ?? .weight(.g)
        }
    }
    
    var headerEquivalentSizeFormUnit: FormUnit? {
        if let headerEquivalentSizeUnitSize {
            return .size(headerEquivalentSizeUnitSize, nil)
        } else {
            return headerEquivalentSize?.unit?.formUnit ?? .weight(.g)
        }
    }
    
    var headerEquivalentSizeUnitSize: Size? {
        guard let headerEquivalentSize, headerEquivalentSize.amount > 0,
              let headerServingAmount, headerServingAmount > 0
        else {
            return nil
        }
        
        if let unitName = headerEquivalentSize.unitName {
            return Size(
                name: unitName,
                amount: 1.0/headerServingAmount/headerEquivalentSize.amount,
                unit: .serving)
        } else {
            return nil
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
