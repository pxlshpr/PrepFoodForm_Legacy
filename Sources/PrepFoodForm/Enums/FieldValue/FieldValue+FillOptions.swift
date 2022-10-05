import Foundation
import PrepUnits
import VisionSugar

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
    
    func selectionEnergyValues(for primaryText: RecognizedText, and supplementaryTexts: [RecognizedText]) -> [FoodLabelValue]
    {
        var values: [FoodLabelValue] = []
        for text in ([primaryText] + supplementaryTexts) {
            /// Go through all the candidates provided by the Vision framework
            for candidate in text.candidates {
                for value in candidate.values {
                    
                    let energyValue = value.withEnergyUnit
                    
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
        return values
    }
    
    func selectionMacroValues(for primaryText: RecognizedText, and supplementaryTexts: [RecognizedText]) -> [FoodLabelValue]
    {
        var values: [FoodLabelValue] = []
        for text in ([primaryText] + supplementaryTexts) {
            /// Go through all the candidates provided by the Vision framework
            for candidate in text.candidates {
                for value in candidate.values {
                    
                    let macroValue = value.withMacroUnit
                    
                    guard !values.contains(macroValue) else { continue }
                    values.append(macroValue)
                }
            }
        }
        return values
    }
    
    func selectionFillValues(for primaryText: RecognizedText, and supplementaryTexts: [RecognizedText]) -> [FoodLabelValue] {
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
        case .energy:
            return selectionEnergyValues(for: primaryText, and: supplementaryTexts)
        case .macro:
            return selectionMacroValues(for: primaryText, and: supplementaryTexts)
//        case .micro(let microValue):
//            <#code#>
        default:
            return []
        }
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

        let values = selectionFillValues(for: primaryText, and: supplementaryTexts)
        
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
        case .macro(let macroValue):
            return macroValue.description
//        case .micro(let microValue):
//            <#code#>
        default:
            return "(not implemented)"
        }
    }
}

extension FieldValue.MacroValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}
extension FieldValue.EnergyValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}
