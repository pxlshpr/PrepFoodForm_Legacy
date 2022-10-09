import Foundation
import PrepUnits
import VisionSugar

extension FieldValue {
    //MARK: Image Autofill
    var autofillOptions: [FillOption] {
        var fillOptions: [FillOption] = []
        guard let fieldValue = FoodFormViewModel.shared.scannedFieldValue(for: self),
              case .scanned(let info) = fieldValue.fill
        else {
            return []
        }
        fillOptions.append(
            FillOption(
                string: fieldValue.fillButtonString,
                systemImage: Fill.SystemImage.scanned,
//                isSelected: self.value == autofillFieldValue.value,
                isSelected: self == fieldValue,
                type: .fill(fieldValue.fill)
            )
        )

        /// Show alts if selected (only check the text because it might have a different value attached to it)
        for altValue in fieldValue.altValues {
            fillOptions.append(
                FillOption(
                    string: altValue.fillOptionString,
                    systemImage: Fill.SystemImage.scanned,
                    isSelected: self.value == altValue && self.fill.isImageAutofill,
                    type: .fill(.scanned(info.withAltValue(altValue)))
                )
            )
        }
        
        return fillOptions
    }

    func selectionDoubleValues(for primaryText: RecognizedText) -> [FoodLabelValue] {
        var values: [FoodLabelValue] = []
        /// Go through all the candidates provided by the Vision framework
        for candidate in primaryText.candidates {
            for value in candidate.values {
                
                var compatibleValue = value
                
                /// If it has a unit—make sure it is a `FormUnit` (only weight and measurements will be allowed)
                if let unit = compatibleValue.unit {
                    if unit.formUnit == nil {
                        /// and if not, set it to nil so we can at least use the number
                        compatibleValue.unit = nil
                    }
                }
                /// Don't add duplicates
                guard !values.contains(compatibleValue) else { continue }
                values.append(compatibleValue)
            }
        }
        return values
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

    func selectionMicroValues(for primaryText: RecognizedText, and supplementaryTexts: [RecognizedText], nutrientType: NutrientType) -> [FoodLabelValue]
    {
        var values: [FoodLabelValue] = []
        for text in ([primaryText] + supplementaryTexts) {
            /// Go through all the candidates provided by the Vision framework
            for candidate in text.candidates {
                for value in candidate.values {
                    
                    let microValue = value.withMicroUnit(for: nutrientType)
                    
                    guard !values.contains(microValue) else { continue }
                    values.append(microValue)
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
        case .amount, .serving:
            return selectionDoubleValues(for: primaryText)
        case .energy:
            return selectionEnergyValues(for: primaryText, and: supplementaryTexts)
        case .macro:
            return selectionMacroValues(for: primaryText, and: supplementaryTexts)
        case .micro(let microValue):
            return selectionMicroValues(for: primaryText, and: supplementaryTexts, nutrientType: microValue.nutrientType)
        default:
            return []
        }
    }
    
    //MARK: Image Selection
    var selectionFillOptions: [FillOption] {
        guard
            case .selection(
                let primaryText,
                let scanResultId,
                let supplementaryTexts,
                value: _) = fill
                ,
            primaryText != FoodFormViewModel.shared.scannedText(for: self) /// skip over selections of the autofilled text (although the picker shouldn't allow that to begin with)
        else {
            return []
        }

        let values = selectionFillValues(for: primaryText, and: supplementaryTexts)
        
        var fillOptions: [FillOption] = []
        for value in values {
            fillOptions.append(
                FillOption(
                    string: value.description,
                    systemImage: Fill.SystemImage.selection,
                    isSelected: value.matchesSelection(self.value) && self.fill.isImageSelection,
                    type: .fill(.selection(recognizedText: primaryText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: value)
                    )
                )
            )
        }
        
        return fillOptions
    }
}

extension FoodLabelValue {
    /// Returns true if the values match and both have units. However, if either one has a unit missing—then the amounts are only checked.
    func matchesSelection(_ other: FoodLabelValue?) -> Bool {
        guard let other else { return false }
        guard unit != nil, other.unit != nil else {
            return amount == other.amount
        }
        return self == other
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
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.description
        case .energy(let energyValue):
            return energyValue.description
        case .macro(let macroValue):
            return macroValue.description
        case .micro(let microValue):
            return microValue.description
        default:
            return "(not implemented)"
        }
    }
}

extension FieldValue.DoubleValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}

extension FieldValue.MacroValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}
extension FieldValue.MicroValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}
extension FieldValue.EnergyValue {
    var description: String {
        "\(internalString) \(unitDescription)"
    }
}

