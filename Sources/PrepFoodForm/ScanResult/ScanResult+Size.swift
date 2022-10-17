import FoodLabelScanner

extension ScanResult {
    /**
     Returns all the `FieldViewModel`s for sizes.
     
     The column is needed in case the column picked has a `HeaderType` of either `.per100g` or `.per100ml`,
     in which case—an additional size with the name "serving" will be returned with the amount of the
     */
    func allSizeViewModels(at column: Int) -> [FieldViewModel] {
        let sizeViewModels =
        [
            servingUnitSizeViewModel,
            equivalentUnitSizeViewModel,
            perContainerSizeViewModel,
            headerServingSizeViewModel,
            headerEquivalentUnitSizeViewModel
        ]
        .compactMap { $0 }
        
        if (headerType(for: column) == .per100g || headerType(for: column) == .per100ml),
           let servingSizeViewModel
        {
            return sizeViewModels + [servingSizeViewModel]
        } else {
            return sizeViewModels
        }
    }
    
    var servingSizeViewModel: FieldViewModel? {
        guard let servingSize, let servingSizeValueText else {
            return nil
        }
        
        return FieldViewModel(fieldValue: .size(FieldValue.SizeValue(
            size: servingSize,
            fill: scannedFill(
                for: servingSize,
                in: ImageText(text: servingSizeValueText.text, imageId: id))
        )))
    }
    
    var servingSize: Size? {
        guard let servingAmount else { return nil }
        return Size(
            name: "serving",
            amount: servingAmount,
            unit: servingFormUnit
        )
    }
    
    var servingSizeValueText: ValueText? {
        serving?.amountText?.asValueText
    }
    
    var perContainerSizeViewModel: FieldViewModel? {
        guard let perContainerSize, let perContainerSizeValueText else {
            return nil
        }
        
        return FieldViewModel(fieldValue: .size(FieldValue.SizeValue(
            size: perContainerSize,
            fill: scannedFill(
                for: perContainerSize,
                in: ImageText(text: perContainerSizeValueText.text, imageId: id))
        )))
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
    
    var headerServingSizeViewModel: FieldViewModel? {
        guard let headerServingSize, let valueText = servingBasedHeaderText?.asValueText else {
            return nil
        }
        
        let fieldValue: FieldValue = .size(.init(
            size: headerServingSize,
            fill: scannedFill(
                for: headerServingSize,
                in: ImageText(text: valueText.text, imageId: id)
            )
        ))
        return FieldViewModel(fieldValue: fieldValue)
    }

    var headerEquivalentUnitSizeViewModel: FieldViewModel? {
        guard let headerEquivalentUnitSize, let valueText = servingBasedHeaderText?.asValueText else {
            return nil
        }
        
        let fieldValue: FieldValue = .size(.init(
            size: headerEquivalentUnitSize,
            fill: scannedFill(
                for: headerEquivalentUnitSize,
                in: ImageText(text: valueText.text, imageId: id)
            )
        ))
        return FieldViewModel(fieldValue: fieldValue)
    }

//    var servingSizeViewModel: FieldViewModel? {
//        guard let
//    }
    var servingUnitSizeViewModel: FieldViewModel? {
        guard let servingUnitSize, let servingUnitSizeValueText else {
            return nil
        }
        
        let fieldValue: FieldValue = .size(.init(
            size: servingUnitSize,
            fill: scannedFill(
                for: servingUnitSize,
                in: ImageText(text: servingUnitSizeValueText.text, imageId: id)
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
            fill: scannedFill(
                for: equivalentUnitSize,
                in: ImageText(text: equivalentUnitSizeValueText.text, imageId: id)
            )
        ))
        return FieldViewModel(fieldValue: fieldValue)
    }
    
    //MARK: Units Sizes
    
    var headerServingSize: Size? {
        guard let headerServingUnitName,
              let headerServingAmount, headerServingAmount > 0
        else {
            return nil
        }
        
        let sizeAmount: Double
        let sizeUnit: FormUnit
        if let headerEquivalentSize {
            if let headerEquivalentSizeUnitSize {
                /// Foods that have a size for both the serving unit and equivalence
                ///     e.g. 1 pack (5 pieces)
                guard headerEquivalentSize.amount > 0 else {
                    return nil
                }
//                sizeAmount = 1.0/amount/equivalentSize.amount
                sizeAmount = headerEquivalentSize.amount/headerServingAmount
                sizeUnit = .size(headerEquivalentSizeUnitSize, nil)
            } else {
                sizeAmount = headerEquivalentSize.amount/headerServingAmount
                sizeUnit = headerEquivalentSize.unit?.formUnit ?? .weight(.g)
            }
        } else {
            sizeAmount = 1.0/headerServingAmount
            sizeUnit = .serving
        }
        return Size(
            name: headerServingUnitName,
            amount: sizeAmount,
            unit: sizeUnit
        )
    }
    
    var headerEquivalentUnitSize: Size? {
        guard let headerServingAmount, headerServingAmount > 0,
              let headerEquivalentSize, headerEquivalentSize.amount > 0,
              let unitName = headerEquivalentSize.unitName
        else {
            return nil
        }
        
        return Size(
            name: unitName,
//            amount: 1.0/amount/equivalentSize.amount,
            amount: headerServingAmount/headerEquivalentSize.amount,
            unit: headerServingFormUnit
        )
    }
 
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
    func scannedFill(for valueText: ValueText, value: FoodLabelValue) -> Fill {
        .scanned(.init(valueText: valueText, imageId: id, altValue: value))
    }
    
    func scannedFill(for size: Size, in imageText: ImageText) -> Fill {
        .scanned(.init(imageText: imageText, size: size))
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
