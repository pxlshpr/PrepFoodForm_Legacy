import Foundation
import PrepUnits

extension FieldValue {
    var selectionFillOptions: [FillOption] {
        /// Selected text option (if its available) + its alts
        guard case .imageSelection(let primaryText, let scanResultId, supplementaryTexts: let supplementaryTexts, value: let value) = fillType else {
            return []
        }

        /// This is **only valid for energy and needs to be rejigged for other types**
        var values: [FoodLabelValue] = []
        for text in ([primaryText] + supplementaryTexts) {
            for value in text.string.values {
                let energyValue = value.asEnergyValue
                guard !values.contains(energyValue) else { continue }
                values.append(energyValue)
                
                let oppositeValue = energyValue.withOppositeEnergyUnit
                if !values.contains(oppositeValue) {
                    values.append(oppositeValue)
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
