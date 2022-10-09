import FoodLabelScanner

extension ScanResult {
    var servingSizeViewModels: [FieldViewModel] {
        [servingUnitSizeViewModel, equivalentUnitSizeViewModel, perContainerSizeViewModel].compactMap { $0 }
    }
    
    var perContainerSizeViewModel: FieldViewModel? {
        guard let perContainerSize, let perContainerSizeValueText else {
            return nil
        }
        
        return FieldViewModel(fieldValue: .size(FieldValue.SizeValue(
            size: perContainerSize,
            fill: autoFillType(
                for: perContainerSizeValueText,
                value: FoodLabelValue(amount: perContainerSize.amount ?? 0,
                                      unit: perContainerSize.unit.foodLabelUnit)
            ))
        ))
    }
    
    var perContainerSize: Size? {
        guard let perContainer = serving?.perContainer else {
            return nil
        }
        return Size(
            quantity: 1,
            name: perContainer.name ?? "container",
            amount: perContainer.amount,
            unit: .serving
        )
    }
    var servingUnitSizeViewModel: FieldViewModel? {
        guard let servingUnitSize, let servingUnitSizeValueText else {
            return nil
        }
        
        let fieldValue: FieldValue = .size(.init(
            size: servingUnitSize,
            fill: autoFillType(
                for: servingUnitSizeValueText,
                value: FoodLabelValue(
                    amount: servingUnitSize.amount ?? 0,
                    unit: servingUnitSize.unit.foodLabelUnit
                )
            )
        ))
        return FieldViewModel(fieldValue: fieldValue)
    }
    
    var equivalentUnitSizeViewModel: FieldViewModel? {
        guard let equivalentUnitSize, let equivalentUnitSizeValueText else {
            return nil
        }
        
        let fieldValue: FieldValue = .size(.init(
            size: equivalentUnitSize,
            fill: autoFillType(
                for: equivalentUnitSizeValueText,
                value: FoodLabelValue(
                    amount: equivalentUnitSize.amount ?? 0,
                    unit: equivalentUnitSize.unit.foodLabelUnit
                )
            )
        ))
        return FieldViewModel(fieldValue: fieldValue)
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
 
    //MARK: - Value Texts
    var servingAmountValueText: ValueText? {
        guard let amountText = serving?.amountText else {
            return nil
        }
        return amountText.asValueText
    }
    var perContainerSizeValueText: ValueText? {
        serving?.perContainer?.amountText.asValueText
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
    
    //MARK: - Helpers
    func autoFillType(for valueText: ValueText, value: FoodLabelValue) -> Fill {
        .scanAuto(.init(valueText: valueText, resultId: id, altValue: value))
    }
}

import PrepUnits

extension DoubleText {
    var asValueText: ValueText? {
        ValueText(value: .zero, text: self.text, attributeText: self.attributeText)
//        ValueText(value: FoodLabelValue(amount: double), text: self.text, attributeText: self.attributeText)
    }
}

extension StringText {
    var asValueText: ValueText? {
        ValueText(value: .zero, text: self.text, attributeText: self.attributeText)
    }
}

import VisionSugar

extension RecognizedText {
    var asValueText: ValueText? {
        ValueText(value: .zero, text: self, attributeText: self)
//        asValueText(for: 1)
    }

//    func asValueText(for column: Int) -> ValueText? {
//        let index = column - 1
//        let values = string.values
//        let value: FoodLabelValue
//        if index >= 0, index < values.count {
//            value = values[column]
//        } else {
//            value = .zero
//        }
//        return ValueText(value: value, text: self, attributeText: self)
//    }
}
