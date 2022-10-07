import FoodLabelScanner

extension ScanResult.Serving {
    var sizeViewModels: [FieldValueViewModel] {
        [servingUnitSizeViewModel, equivalentUnitSizeViewModel].compactMap { $0 }
    }
    
    var servingUnitSizeViewModel: FieldValueViewModel? {
        guard let servingUnitSize else { return nil }
        //TODO: Change this to autofill and attach the `RecognizedText`
        let fillType: FillType = .userInput
        let fieldValue: FieldValue = .size(.init(size: servingUnitSize, fillType: fillType))
        return FieldValueViewModel(fieldValue: fieldValue)
    }
    
    var equivalentUnitSizeViewModel: FieldValueViewModel? {
        guard let equivalentUnitSize else { return nil }
        //TODO: Change this to autofill and attach the `RecognizedText`
        let fillType: FillType = .userInput
        let fieldValue: FieldValue = .size(.init(size: equivalentUnitSize, fillType: fillType))
        return FieldValueViewModel(fieldValue: fieldValue)
    }

    //MARK: Units Sizes
    
    var servingUnitSize: Size? {
        guard let unitNameText,
              let amount, amount > 0
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
                sizeAmount = 1.0/amount/equivalentSize.amount
                sizeUnit = .size(equivalentSizeUnitSize, nil)
            } else {
                sizeAmount = equivalentSize.amount
                sizeUnit = equivalentSize.unit?.formUnit ?? .weight(.g)
            }
        } else {
            sizeAmount = 1.0/amount
            sizeUnit = .serving
        }
        return Size(
            name: unitNameText.string,
            amount: sizeAmount,
            unit: sizeUnit
        )
    }

    var equivalentUnitSize: Size? {
        guard let amount, amount > 0,
              let equivalentSize, equivalentSize.amount > 0,
              let unitNameText = equivalentSize.unitNameText
        else {
            return nil
        }
        
        return Size(
            name: unitNameText.string,
//            amount: 1.0/amount/equivalentSize.amount,
            amount: amount/equivalentSize.amount,
            unit: servingUnit
        )
    }
}
