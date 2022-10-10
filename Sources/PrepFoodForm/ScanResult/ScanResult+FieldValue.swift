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

extension FoodLabelUnit {
    func isCompatibleForDensity(with other: FoodLabelUnit) -> Bool {
        guard let unitType, let otherUnitType = other.unitType else {
            return false
        }
        return (unitType == .weight && otherUnitType == .volume)
        ||
        (unitType == .volume && otherUnitType == .weight)
    }
    
    var unitType: UnitType? {
        switch self {
        case .cup, .ml, .tbsp:
            return .volume
        case .mcg, .mg, .g, .oz:
            return .weight
        default:
            return nil
        }
    }
    
    var weightFormUnit: FormUnit? {
        switch self {
        case .mcg:
            return nil /// Not yet supported
        case .mg:
            return .weight(.mg)
        case .g:
            return .weight(.g)
        case .oz:
            return .weight(.oz)
        default:
            return nil
        }
    }
    
    var volumeFormUnit: FormUnit? {
        switch self {
        case .cup:
            return .volume(.cup)
        case .ml:
            return .volume(.mL)
        case .tbsp:
            return .volume(.tablespoon)
        default:
            return nil
        }
    }
}
extension ScanResult {

    var equivalentSizeDensityValue: FieldValue.DensityValue? {
        guard let equivalentSize,
              let equivalentSizeUnit = equivalentSize.unit,
              let servingUnit, let servingAmount,
              servingUnit.isCompatibleForDensity(with: equivalentSizeUnit)
        else {
            return nil
        }
        
        let unitFill: Fill = Fill.scanned(ScannedFillInfo(
            resultText: ImageText(
                text: equivalentSize.amountText.text, imageId: id)
        ))
        let weight: FieldValue.DoubleValue
        let volume: FieldValue.DoubleValue
        if let weightUnit = equivalentSizeUnit.weightFormUnit {
            weight = FieldValue.DoubleValue(
                double: equivalentSize.amount,
                string: equivalentSize.amount.cleanAmount,
                unit: weightUnit,
                fill: unitFill)
            guard let volumeUnit = servingUnit.volumeFormUnit else {
                return nil
            }
            volume = FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: volumeUnit,
                fill: unitFill)
        } else if let weightUnit = servingUnit.weightFormUnit {
            weight = FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: weightUnit,
                fill: unitFill)
            guard let volumeUnit = equivalentSizeUnit.volumeFormUnit else {
                return nil
            }
            volume = FieldValue.DoubleValue(
                double: equivalentSize.amount,
                string: equivalentSize.amount.cleanAmount,
                unit: volumeUnit,
                fill: unitFill)
        } else {
            return nil
        }
        
        let fill: Fill = Fill.scanned(ScannedFillInfo(
            resultText: ImageText(
                text: equivalentSize.amountText.text, imageId: id),
            densityValue: FieldValue.DensityValue(weight: weight, volume: volume, fill: unitFill)
        ))
        return FieldValue.DensityValue(weight: weight, volume: volume, fill: fill)
    }
    
    var headerEquivalentSizeDensityValue: FieldValue.DensityValue? {
        return nil
    }
    
    var densityFieldValue: FieldValue? {
        /// Check if we have an equivalent serving size
        if let equivalentSizeDensityValue {
            return FieldValue.density(equivalentSizeDensityValue)
        }
        /// Otherwise check if we have a header equivalent size for any of the headers
        if let headerEquivalentSizeDensityValue {
            return FieldValue.density(headerEquivalentSizeDensityValue)
        }
        return nil
    }
    
    func amountFieldValue(for column: Int) -> FieldValue? {
        if headerType(for: column) != .perServing {
            return headerFieldValue(for: column)
        } else {
            guard let valueText = amountValueText(for: column) else { return nil }
            return FieldValue.amount(FieldValue.DoubleValue(
                double: 1, string: "1", unit: .serving, fill: autoFillType(
                    for: valueText,
                    value: FoodLabelValue(amount: 1, unit: nil)
                ))
            )
        }
    }
    
    func amountValueText(for column: Int) -> ValueText? {
        if let servingAmountValueText {
            return servingAmountValueText
        } else {
            return headerValueText(for: column)
        }
    }
    
    func servingFieldValue(for column: Int) -> FieldValue? {
        if let servingAmount, let servingAmountValueText {
            return FieldValue.serving(FieldValue.DoubleValue(
                double: servingAmount,
                string: servingAmount.cleanAmount,
                unit: servingFormUnit,
                fill: autoFillType(
                    for: servingAmountValueText,
                    value: FoodLabelValue(
                        amount: servingAmount,
                        unit: servingFormUnit.foodLabelUnit
                    )
                )
            ))
        }
        else if headerType(for: column) == .perServing {
            return headerFieldValue(for: column)
        } else {
            return nil
        }
    }
    
    func headerFieldValue(for column: Int) -> FieldValue? {
        guard let headerAmount = headerAmount(for: column),
                let headerValueText = headerValueText(for: column)
        else {
            return nil
        }
        return FieldValue.serving(FieldValue.DoubleValue(
            double: headerAmount,
            string: headerAmount.cleanAmount,
            unit: headerFormUnit(for: column),
            fill: autoFillType(
                for: headerValueText,
                value: FoodLabelValue(
                    amount: headerAmount,
                    unit: headerFormUnit(for: column).foodLabelUnit
                )
            )
        ))
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
    
    func headerAmount(for column: Int) -> Double? {
        guard let headerType = headerType(for: column) else {
            return nil
        }
        switch headerType {
        case .per100g, .per100ml:
            return 100
        case .perServing:
            return headerServingAmount
        }
    }

    func headerText(for column: Int) -> HeaderText? {
        column == 1 ? headers?.headerText1 : headers?.headerText2
    }
    
    func headerValueText(for column: Int) -> ValueText? {
        guard let headerText = headerText(for: column) else { return nil }
        return headerText.text.asValueText
    }
    
    func headerType(for column: Int) -> HeaderType? {
        column == 1 ? headers?.header1Type : headers?.header2Type
    }
    
    func headerFormUnit(for column: Int) -> FormUnit {
        guard let headerType = headerType(for: column) else {
            return .serving
        }
        
        switch headerType {
        case .per100g:
            return .weight(.g)
        case .per100ml:
            return .volume(.mL)
        case .perServing:
            return headerServingFormUnit
        }
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
