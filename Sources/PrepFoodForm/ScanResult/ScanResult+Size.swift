import FoodLabelScanner

extension ScanResult {
    var servingSizeViewModels: [FieldValueViewModel] {
        [servingUnitSizeViewModel, equivalentUnitSizeViewModel].compactMap { $0 }
    }
    
    var servingUnitSizeViewModel: FieldValueViewModel? {
        guard let servingUnitSize, let servingUnitSizeValueText else {
            return nil
        }
        
        let fillType: FillType = .imageAutofill(
            valueText: servingUnitSizeValueText,
            scanResultId: id,
            value: nil)
        let fieldValue: FieldValue = .size(.init(size: servingUnitSize, fillType: fillType))
        return FieldValueViewModel(fieldValue: fieldValue)
    }
    
    var equivalentUnitSizeViewModel: FieldValueViewModel? {
        guard let equivalentUnitSize, let equivalentUnitSizeValueText else {
            return nil
        }
        
        let fillType: FillType = .imageAutofill(
            valueText: equivalentUnitSizeValueText,
            scanResultId: id,
            value: nil)
        let fieldValue: FieldValue = .size(.init(size: equivalentUnitSize, fillType: fillType))
        return FieldValueViewModel(fieldValue: fieldValue)
    }

    //MARK: Units Sizes
    
    var servingUnitSize: Size? {
        guard let servingUnitNameText,
              let servingAmount, servingAmount > 0
        else {
            return nil
        }
        
        let sizeAmount: Double
        let sizeUnit: FormUnit
        if let equivalentSize {
            if let equivalentSizeUnitSize {
                /// Foods that have a size for both the serving unit and equivalence
                ///     e.g. 1 pack (5 pieces)
                guard equivalentSize.amount > 0 else {
                    return nil
                }
//                sizeAmount = 1.0/amount/equivalentSize.amount
                sizeAmount = equivalentSize.amount/servingAmount
                sizeUnit = .size(equivalentSizeUnitSize, nil)
            } else {
                sizeAmount = equivalentSize.amount / servingAmount
                sizeUnit = equivalentSize.unit?.formUnit ?? .weight(.g)
            }
        } else {
            sizeAmount = 1.0/servingAmount
            sizeUnit = .serving
        }
        return Size(
            name: servingUnitNameText.string,
            amount: sizeAmount,
            unit: sizeUnit
        )
    }

    var equivalentUnitSize: Size? {
        guard let servingAmount, servingAmount > 0,
              let equivalentSize, equivalentSize.amount > 0,
              let unitNameText = equivalentSize.unitNameText
        else {
            return nil
        }
        
        return Size(
            name: unitNameText.string,
//            amount: 1.0/amount/equivalentSize.amount,
            amount: servingAmount/equivalentSize.amount,
            unit: servingFormUnit
        )
    }
    
    var equivalentUnitSizeValueText: ValueText? {
        equivalentSize?.unitNameText?.asValueText
    }
    
    var servingUnitSizeValueText: ValueText? {
        guard let servingUnitNameText else {
            return nil
        }
        
        if let equivalentSize {
            if let equivalentUnitNameText = equivalentSize.unitNameText {
                return equivalentUnitNameText.asValueText
            } else {
                return servingUnitNameText.asValueText
            }
        } else {
            return servingUnitNameText.asValueText
        }
    }
}

extension StringText {
    var asValueText: ValueText? {
        ValueText(value: .zero, text: self.text, attributeText: self.attributeText)
    }
}
