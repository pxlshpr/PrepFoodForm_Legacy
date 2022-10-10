import Foundation
import PrepUnits
import VisionSugar

//MARK: Selection Options

extension FieldValue {
    var selectionFillOptions: [FillOption] {
        if self.usesValueBasedTexts {
            return valueBasedSelectionFillOptions
        } else {
            return stringBasedSelectionFillOptions
        }
    }
    var valueBasedSelectionFillOptions: [FillOption] {
        guard case .selection(let info) = fill,
              info.imageText?.text != FoodFormViewModel.shared.scannedText(for: self) /// skip over selections of the autofilled text (although the picker shouldn't allow that to begin with)
        else {
            return []
        }

        let values = selectionFillValues(for: fill.texts)
        
        var fillOptions: [FillOption] = []
        for value in values {
            fillOptions.append(
                FillOption(
                    string: value.description,
                    systemImage: Fill.SystemImage.selection,
                    isSelected: value.matchesSelection(self.value) && self.fill.isImageSelection,
                    type: .fill(.selection(info.withAltValue(value)))
                )
            )
        }
        return fillOptions
    }
    
    var stringBasedSelectionFillOptions: [FillOption] {
        
        guard case .selection(let info) = fill else {
            return []
        }

        func fillOption(for imageText: ImageText, with stringOverride: String? = nil) -> FillOption {
            
            let isSelected: Bool
            let fillImageText: ImageText
            let string: String
            if let stringOverride {
                fillImageText = ImageText(text: imageText.text, imageId: imageText.imageId, pickedCandidate: stringOverride)
                //TODO: Replace this with components stuff
                isSelected = false
//                isSelected = info.imageTexts.contains(fillImageText)
                string = stringOverride
            } else {
                isSelected = false
//                isSelected = info.imageTexts.contains(imageText.withoutPickedCandidate)
                fillImageText = imageText
                string = imageText.text.string
            }
            
            return FillOption(
                string: string,
                systemImage: Fill.SystemImage.selection,
                isSelected: isSelected,
                disableWhenSelected: false,
                //TODO: Replace this with components stuff
//                type: .fill(.selection(.init(imageTexts: [fillImageText])))
                type: .fill(.selection(.init(imageText: nil)))
            )
        }
        

        var fillOptions: [FillOption] = []
        //TODO: Here we need a helper that grabs the unique set of imageTexts from the componentsTexts
//        for imageText in info.imageTexts {
//            for component in imageText.text.string.selectionComponents {
//                guard !fillOptions.contains(where: { $0.string == component }) else { continue }
//                fillOptions.append(
//                    fillOption(for: imageText, with: component)
//                )
//            }
            
//            for candidate in imageText.text.candidates {
//                for component in candidate.components {
//                    guard !fillOptions.contains(where: { $0.string == component }) else { continue }
//                    fillOptions.append(
//                        fillOption(for: imageText, with: component)
//                    )
//                }
//            }
//        }
        return fillOptions
    }
    
    func selectionDoubleValues(for primaryText: RecognizedText) -> [FoodLabelValue] {
        var values: [FoodLabelValue] = []
        /// Go through all the candidates provided by the Vision framework
        for candidate in primaryText.candidates {
            for value in candidate.detectedValues {
                
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

    func selectionEnergyValues(for text: RecognizedText) -> [FoodLabelValue] {
        var values: [FoodLabelValue] = []
        /// Go through all the candidates provided by the Vision framework
        for candidate in text.candidates {
            for value in candidate.detectedValues {
                
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
        return values
    }
    
    func selectionMacroValues(for text: RecognizedText) -> [FoodLabelValue] {
        var values: [FoodLabelValue] = []
        /// Go through all the candidates provided by the Vision framework
        for candidate in text.candidates {
            for value in candidate.detectedValues {
                
                let macroValue = value.withMacroUnit
                
                guard !values.contains(macroValue) else { continue }
                values.append(macroValue)
            }
        }
        return values
    }

    func selectionMicroValues(for text: RecognizedText, nutrientType: NutrientType) -> [FoodLabelValue] {
        var values: [FoodLabelValue] = []
        /// Go through all the candidates provided by the Vision framework
        for candidate in text.candidates {
            for value in candidate.detectedValues {
                
                let microValue = value.withMicroUnit(for: nutrientType)
                
                guard !values.contains(microValue) else { continue }
                values.append(microValue)
            }
        }
        return values
    }

    func selectionFillValues(for texts: [RecognizedText]) -> [FoodLabelValue] {
        guard let firstText = texts.first else { return [] }
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
            return selectionDoubleValues(for: firstText)
        case .energy:
            return selectionEnergyValues(for: firstText)
        case .macro:
            return selectionMacroValues(for: firstText)
        case .micro(let microValue):
            return selectionMicroValues(for: firstText, nutrientType: microValue.nutrientType)
        default:
            return []
        }
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

