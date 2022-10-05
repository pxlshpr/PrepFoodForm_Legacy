import Foundation
import PrepUnits

extension FoodFormViewModel {
    
}
extension FieldValue {
    //MARK: Image Autofill
    var autofillOptions: [FillOption] {
        var fillOptions: [FillOption] = []
        guard let autofillFieldValue = FoodFormViewModel.shared.autofillOptionFieldValue(for: self) else {
            return []
        }
        fillOptions.append(
            FillOption(
                string: autofillFieldValue.fillButtonString,
                systemImage: FillType.SystemImage.imageAutofill,
                isSelected: self.value == autofillFieldValue.value,
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
                    isSelected: self.value == alternateValue,
                    type: .fillType(.imageAutofill(valueText: valueText, scanResultId: scanResultId, value: alternateValue))
                )
            )
        }
        
        return fillOptions
    }
    
    //MARK: Image Selection
    var selectionFillOptions: [FillOption] {
        guard
            case .imageSelection(
                let primaryText,
                let scanResultId,
                let supplementaryTexts,
                value: _) = fillType
                ,
            primaryText != FoodFormViewModel.shared.autofillText(for: self) /// skip over selections of the autofilled text (although the picker shouldn't allow that to begin with)
        else {
            return []
        }

        /// This is **only valid for energy and needs to be rejigged for other types**
        var values: [FoodLabelValue] = []
        for text in ([primaryText] + supplementaryTexts) {
            /// Go through all the candidates provided by the Vision framework
            for candidate in text.candidates {
                for value in candidate.values {
                    
                    let energyValue = value.asEnergyValue
                    
                    /// Don't add duplicates
                    guard !values.contains(energyValue) else { continue }
                    values.append(energyValue)
                    
                    let oppositeValue = energyValue.withOppositeEnergyUnit
                    if !values.contains(oppositeValue) {
                        values.append(oppositeValue)
                    }
                }
            }
        }
        
        var fillOptions: [FillOption] = []
        for value in values {
            fillOptions.append(
                FillOption(
                    string: value.description,
                    systemImage: FillType.SystemImage.imageSelection,
                    isSelected: self.value == value,
                    type: .fillType(.imageSelection(recognizedText: primaryText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: value)
                    )
                )
            )
        }
        
        //TODO: If we have a `value` set—and `altValues` doesn't contain it anymore—(if our code that generates it changes for example); create an option to show that it is selected here anyway.

        /// Add options for the text and each of the supplementary texts here (in case of string values where we have multiple texts attached with our image selection fill type
//        for text in ([primaryText] + supplementaryTexts) {
//            fillOptions.append(
//                FillOption(
//                    string: text.fillButtonString(for: self),
//                    systemImage: FillType.SystemImage.imageSelection,
//                    isSelected: value == nil, /// only shows as selected if we haven't selected one of the altValue's generated for this text
//                    type: .fillType(.imageSelection(
//                        recognizedText: primaryText,
//                        scanResultId: scanResultId,
//                        supplementaryTexts: supplementaryTexts,
//                        value: nil /// make sure this is cleared out when creating it from a filltype with an altValue
//                    ))
//                )
//            )
//        }
//
//        for altValue in altValues {
//            fillOptions.append(
//                FillOption(
//                    string: altValue.fillOptionString,
//                    systemImage: FillType.SystemImage.imageSelection,
//                    isSelected: fillType.value == altValue,
//                    type: .fillType(.imageSelection(recognizedText: primaryText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: altValue))
//                )
//            )
//        }
        return fillOptions
    }
}

extension FieldValue {
    var fillButtonString: String {
        switch self {
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
        case .energy(let energyValue):
            return energyValue.description
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
        default:
            return "(not implemented)"
        }
    }
}

extension FieldValue.EnergyValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}
