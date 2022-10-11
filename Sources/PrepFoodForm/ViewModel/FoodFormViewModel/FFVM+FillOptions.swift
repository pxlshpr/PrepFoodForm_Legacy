import FoodLabelScanner
import VisionSugar
import PrepUnits

extension FoodFormViewModel {

    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        
        /// Detected text option (if its available) + its alts
        fillOptions.append(contentsOf: scannedFillOptions(for: fieldValue))
        fillOptions.append(contentsOf: selectionFillOptions(for: fieldValue))
        fillOptions.append(contentsOf: prefillOptions(for: fieldValue))
        fillOptions.append(contentsOf: calculatedOptions(for: fieldValue))
        
//        fillOptions.removeFillOptionValueDuplicates()
        
        if let selectFillOption = selectFillOption(for: fieldValue) {
            fillOptions .append(selectFillOption)
        }
        
        return fillOptions
    }
    
    func selectionFillOptions(for fieldValue: FieldValue) -> [FillOption] {
        guard case .density = fieldValue else {
            return fieldValue.selectionFillOptions
        }

        guard case .selection(let info) = fieldValue.fill,
              let selectedText = info.imageText?.text,
              selectedText != FoodFormViewModel.shared.firstScannedText(for: fieldValue)
        else {
            return []
        }
        
        return [
            FillOption(
                string: fillButtonString(for: fieldValue),
                systemImage: Fill.SystemImage.selection,
                isSelected: true,
                type: .fill(fieldValue.fill)
            )
        ]
    }
    
    func scannedFillOptions(for fieldValue: FieldValue) -> [FillOption] {
        let scannedFieldValues = FoodFormViewModel.shared.scannedFieldValues(for: fieldValue)
        var fillOptions: [FillOption] = []
        
        for scannedFieldValue in scannedFieldValues {
            guard case .scanned(let info) = scannedFieldValue.fill else {
                continue
            }
            
            fillOptions.append(
                FillOption(
                    string: fillButtonString(for: scannedFieldValue),
                    systemImage: Fill.SystemImage.scanned,
                    //                isSelected: self.value == autofillFieldValue.value,
                    isSelected: fieldValue.equalsScannedFieldValue(scannedFieldValue),
                    type: .fill(scannedFieldValue.fill)
                )
            )
            
            /// Show alts if selected (only check the text because it might have a different value attached to it)
            for altValue in scannedFieldValue.altValues {
                fillOptions.append(
                    FillOption(
                        string: altValue.fillOptionString,
                        systemImage: Fill.SystemImage.scanned,
                        isSelected: fieldValue.value == altValue && fieldValue.fill.isImageAutofill,
                        type: .fill(.scanned(info.withAltValue(altValue)))
                    )
                )
            }
        }
                
        return fillOptions
    }

    func fillButtonString(for fieldValue: FieldValue) -> String {
        switch fieldValue {
//        case .name(let stringValue):
//            <#code#>
//        case .emoji(let stringValue):
//            <#code#>
//        case .brand(let stringValue):
//            <#code#>
//        case .barcode(let stringValue):
//            <#code#>
//        case .detail(let stringValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.description
        case .energy(let energyValue):
            return energyValue.description
        case .macro(let macroValue):
            return macroValue.description
        case .micro(let microValue):
            return microValue.description
        case .density(let densityValue):
            return densityValue.description(weightFirst: isWeightBased)
        case .size(let sizeValue):
            return sizeValue.size.fullNameString
        default:
            return "(not implemented)"
        }
    }
    
    //MARK: Calculated
    func calculatedOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        //TODO: Add calculated option here for case where we have all other 3 values in the energy equation and the current value in the field isn't within the threshold
        return fillOptions
    }

    //MARK: Choose
    func selectFillOption(for fieldValue: FieldValue) -> FillOption? {
        
        guard fieldValue.supportsSelectingText,
              hasAvailableTexts(for: fieldValue) else {
            return nil
        }
        return FillOption(
            string: "Select",
            systemImage: Fill.SystemImage.selection,
            isSelected: false, /// never selected as we only use this to pop up the `TextPicker`
            type: .select
        )
    }
    
    //MARK: - Helpers
    
    func shouldShowFillOptions(for fieldValue: FieldValue) -> Bool {
        !fillOptions(for: fieldValue).isEmpty
    }
    
    func scannedFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        
        switch fieldValue {
        case .energy:
            return scannedFieldValues.filter({ $0.isEnergy })
        case .macro(let macroValue):
            return scannedFieldValues.filter({ $0.isMacro && $0.macroValue.macro == macroValue.macro })
        case .micro(let microValue):
            return scannedFieldValues.filter({ $0.isMicro && $0.microValue.nutrientType == microValue.nutrientType })
        case .amount:
            return scannedFieldValues.filter({ $0.isAmount })
        case .serving:
            return scannedFieldValues.filter({ $0.isServing })
        case .density:
            return scannedFieldValues.filter({ $0.isDensity })
        case .size:
            return scannedSizeFieldValues(for: fieldValue)
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
        default:
            return []
        }
    }
    
    func prefillSizeOptionFieldValues(for fieldValue: FieldValue, from sizeFieldValues: [FieldValue]) -> [FieldValue] {
        sizeFieldValues
            .filter { $0.isSize }
            .filter {
                /// Always include the size that's being used by this fieldValue currently (so that we can see it toggled on)
                guard fieldValue.size != $0.size, let size = $0.size else {
                    return true
                }
                
                /// If we're currently editing a size—it may not be filtered in as we'd want it to if the user has edited it slightly.
                /// This is because it would not match the current `fieldValue.size` (since the user has edited it)
                ///     while still being present in the `allSizes` array—as the user hasn't commited the change yet.
                /// So we will always store the current size being edited here so that we can disregard the following check and include it anyway.
//                if let sizeBeingEdited, sizeBeingEdited == $0.size {
//                    return true
//                }
                
                /// Make sure we're not using it already
                return !containsSize(withName: size.name, andVolumePrefixUnit: size.volumePrefixUnit, ignoring: sizeBeingEdited)
            }
    }
    
    func scannedSizeFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        prefillSizeOptionFieldValues(for: fieldValue, from: scannedFieldValues)
    }

    func firstScannedText(for fieldValue: FieldValue) -> RecognizedText? {
        guard let fill = scannedFieldValues(for: fieldValue).first?.fill else {
            return nil
        }
        return fill.text
    }

    func firstScannedFill(for fieldValue: FieldValue, with text: RecognizedText) -> Fill? {
        guard let fill = scannedFieldValues(for: fieldValue).first?.fill,
              fill.text == text else {
            return nil
        }
        return fill
    }
    
    func firstScannedFill(for fieldValue: FieldValue, with densityValue: FieldValue.DensityValue) -> Fill? {
        guard let fill = scannedFieldValues(for: fieldValue).first?.fill,
              let fillDensityValue = fill.densityValue,
              fillDensityValue.equalsValues(of: densityValue) else {
            return nil
        }
        return fill
    }

}

extension FieldValue.DensityValue {
    /// Checks if two `DensityValue`s are equal, disregarding the `Fill`
    func equalsValues(of other: FieldValue.DensityValue) -> Bool {
        weight.equalsValues(of: other.weight)
        && volume.equalsValues(of: other.volume)
    }
}

extension FieldValue.DoubleValue {
    /// Checks if two `DoubleValue`s are equal, disregarding the `Fill`
    func equalsValues(of other: FieldValue.DoubleValue) -> Bool {
        double == other.double
        && unit == other.unit
    }
}


extension Fill {
    var densityValue: FieldValue.DensityValue? {
        switch self {
        case .scanned(let scannedFillInfo):
            return scannedFillInfo.densityValue
        case .selection(let selectionFillInfo):
            return selectionFillInfo.densityValue
        case .prefill(let prefillFillInfo):
            return prefillFillInfo.densityValue
        default:
            return nil
        }
    }
}

extension FillOption {
    var foodLabelValue: FoodLabelValue? {
        switch self.type {
        case .fill(let fill):
            return fill.value
        default:
            return nil
        }
    }
}

extension Array where Element == FillOption {
    func removingFillOptionValueDuplicates() -> [Element] {
        var uniqueDict = [FoodLabelValue: Bool]()

        return filter {
            guard let key = $0.foodLabelValue else { return true }
            return uniqueDict.updateValue(true, forKey: key) == nil
        }
    }

    mutating func removeFillOptionValueDuplicates() {
        self = self.removingFillOptionValueDuplicates()
    }
}

extension FieldValue {
    func equalsScannedFieldValue(_ other: FieldValue) -> Bool {
        switch self {
        case .amount, .serving, .energy, .macro, .micro:
            return value == other.fill.value
        case .density(let densityValue):
            return densityValue == other.densityValue
        case .size(let sizeValue):
            return sizeValue.size == other.size
        default:
            return false
        }
    }
}
