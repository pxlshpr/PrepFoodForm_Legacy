import Foundation

extension FieldValue {
    var selectionFillOptions: [FillOption] {
        /// Selected text option (if its available) + its alts
        guard case .imageSelection(let primaryText, let scanResultId, supplementaryTexts: let supplementaryTexts, value: let value) = fillType else {
            return []
        }

        var fillOptions: [FillOption] = []
        /// Add options for the text and each of the supplementary texts here (in case of string values where we have multiple texts attached with our image selection fill type
        for text in ([primaryText] + supplementaryTexts) {
            fillOptions.append(
                FillOption(
                    string: text.fillButtonString(for: self),
                    systemImage: FillType.SystemImage.imageSelection,
                    isSelected: value == nil, /// only shows as selected if we haven't selected one of the altValue's generated for this text
                    type: .fillType(.imageSelection(
                        recognizedText: primaryText,
                        scanResultId: scanResultId,
                        supplementaryTexts: supplementaryTexts,
                        value: nil /// make sure this is cleared out when creating it from a filltype with an altValue
                    ))
                )
            )
        }
        //TODO: If we have a `value` set—and `altValues` doesn't contain it anymore—(if our code that generates it changes for example); create an option to show that it is selected here anyway.
        
        for altValue in altValues {
            fillOptions.append(
                FillOption(
                    string: altValue.fillOptionString,
                    systemImage: FillType.SystemImage.imageSelection,
                    isSelected: fillType.value == altValue,
                    type: .fillType(.imageSelection(recognizedText: primaryText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: altValue))
                )
            )
        }
        return fillOptions
    }
}
