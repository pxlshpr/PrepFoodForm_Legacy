import Foundation

//MARK: - FFVM + FillOptions
extension FoodFormViewModel {

    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        
        /// Detected text option (if its available) + its alts
        fillOptions.append(contentsOf: autofillOptions(for: fieldValue))
        fillOptions.append(contentsOf: selectionOptions(for: fieldValue))
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

        //TODO: Also add any additional values detected in the string as alt values for that same text (even if not selected)

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

    //MARK: Image Selection
    func selectionOptions(for fieldValue: FieldValue) -> [FillOption] {
        /// Selected text option (if its available) + its alts
        guard case .imageSelection(let primaryText, _, supplementaryTexts: let supplementaryTexts, value: let value) = fieldValue.fillType else {
            return []
        }

        var fillOptions: [FillOption] = []
        /// Add options for the text and each of the supplementary texts here (in case of string values where we have multiple texts attached with our image selection fill type
        for text in ([primaryText] + supplementaryTexts) {
            fillOptions.append(
                FillOption(
                    string: text.fillButtonString(for: fieldValue),
                    systemImage: FillType.SystemImage.imageSelection,
                    isSelected: value == nil, /// only shows as selected if we haven't selected one of the altValue's generated for this text
                    type: .fillType(fieldValue.fillType)
                )
            )
        }
        //TODO: If we have a `value` set—and `altValues` doesn't contain it anymore—(if our code that generates it changes for example); create an option to show that it is selected here anyway.
        
        //TODO: Also show any `altValues` for the text if we have them—these should include misread alts and any additional values detected int he selected string
//        for alternateValue in fieldValue.altValues {
//            guard let valueText = fieldValue.fillType.valueText, let scanResultId = fieldValue.fillType.scanResultId else {
//                continue
//            }
//            fillOptions.append(
//                FillOption(
//                    string: alternateValue.fillOptionString,
//                    systemImage: FillType.SystemImage.imageAutofill,
//                    isSelected: autofillFieldValue.matchesFieldValue(fieldValue, withValue: alternateValue),
//                    type: .fillType(.imageAutofill(valueText: valueText, scanResultId: scanResultId, value: alternateValue))
//                )
//            )
//        }
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

