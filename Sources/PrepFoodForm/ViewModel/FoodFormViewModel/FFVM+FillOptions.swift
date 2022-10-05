import FoodLabelScanner

extension FoodFormViewModel {

    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        
        /// Detected text option (if its available) + its alts
        fillOptions.append(contentsOf: autofillOptions(for: fieldValue))
        fillOptions.append(contentsOf: fieldValue.selectionFillOptions)
        fillOptions.append(contentsOf: prefillOptions(for: fieldValue))
        fillOptions.append(contentsOf: calculatedOptions(for: fieldValue))
        if let chooseOption = chooseOption(for: fieldValue) {
            fillOptions .append(chooseOption)
        }
        
        return fillOptions
    }
    
    //MARK: Image Autofill
    func autofillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        guard let autofillFieldValue = autofillOptionFieldValue(for: fieldValue) else {
            return []
        }
        fillOptions.append(
            FillOption(
                string: autofillFieldValue.fillButtonString,
                systemImage: FillType.SystemImage.imageAutofill,
                isSelected: fieldValue == autofillFieldValue,
                type: .fillType(autofillFieldValue.fillType)
            )
        )

        /// Show alts if selected (only check the text because it might have a different value attached to it)
        for alternateValue in autofillFieldValue.altValues {
            guard let valueText = autofillFieldValue.fillType.valueText, let scanResultId = autofillFieldValue.fillType.scanResultId else {
                continue
            }
            fillOptions.append(
                FillOption(
                    string: alternateValue.fillOptionString,
                    systemImage: FillType.SystemImage.imageAutofill,
                    isSelected: fieldValue.fillType.value == alternateValue,
                    type: .fillType(.imageAutofill(valueText: valueText, scanResultId: scanResultId, value: alternateValue))
                )
            )
        }
        
        return fillOptions
    }

    //MARK: Prefill
    
    func prefillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        //TODO: Check this again
        /// Prefill Options
        //TODO: Check that array returns name, detail and brand for string fields
        for prefillFieldValue in prefillOptionFieldValues(for: fieldValue) {
            let option = FillOption(
                string: prefillFieldValue.stringValue.string,
                systemImage: FillType.SystemImage.prefill,
                isSelected: fieldValue.fillType.isThirdPartyFoodPrefill,
                type: .fillType(.prefill())
            )
            fillOptions.append(option)
        }
        return fillOptions
    }
    
    //MARK: Calculated
    func calculatedOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        //TODO: Add calculated option here for case where we have all other 3 values in the energy equation and the current value in the field isn't within the threshold
        return fillOptions
    }

    //MARK: Choose
    func chooseOption(for fieldValue: FieldValue) -> FillOption? {
        guard hasAvailableTexts(for: fieldValue) else {
            return nil
        }
        return FillOption(
            string: "Choose",
            systemImage: FillType.SystemImage.imageSelection,
            isSelected: false, /// never selected as we only use this to pop up the `TextPicker`
            type: .chooseText
        )
    }
    
    //MARK: - Helpers
    
    func shouldShowFillOptions(for fieldValue: FieldValue) -> Bool {
        !fillOptions(for: fieldValue).isEmpty
    }
}

