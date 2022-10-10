import FoodLabelScanner
import VisionSugar
import PrepUnits

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

extension FoodFormViewModel {

    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        
        /// Detected text option (if its available) + its alts
        fillOptions.append(contentsOf: fieldValue.scannedFillOptions)
        fillOptions.append(contentsOf: fieldValue.selectionFillOptions)
        fillOptions.append(contentsOf: prefillOptions(for: fieldValue))
        fillOptions.append(contentsOf: calculatedOptions(for: fieldValue))
        
//        fillOptions.removeFillOptionValueDuplicates()
        
        if let chooseOption = chooseOption(for: fieldValue) {
            fillOptions .append(chooseOption)
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
            string: "Select",
            systemImage: Fill.SystemImage.selection,
            isSelected: false, /// never selected as we only use this to pop up the `TextPicker`
            type: .chooseText
        )
    }
    
    //MARK: - Helpers
    
    func shouldShowFillOptions(for fieldValue: FieldValue) -> Bool {
        !fillOptions(for: fieldValue).isEmpty
    }
    
    func scannedFieldValue(for fieldValue: FieldValue) -> FieldValue? {
        
        switch fieldValue {
        case .energy:
            return scannedFieldValues.first(where: { $0.isEnergy })
        case .macro(let macroValue):
            return scannedFieldValues.first(where: { $0.isMacro && $0.macroValue.macro == macroValue.macro })
        case .micro(let microValue):
            return scannedFieldValues.first(where: { $0.isMicro && $0.microValue.nutrientType == microValue.nutrientType })
        case .amount:
            return scannedFieldValues.first(where: { $0.isAmount })
        case .serving:
            return scannedFieldValues.first(where: { $0.isServing })
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
        default:
            return nil
        }
    }

    func scannedText(for fieldValue: FieldValue) -> RecognizedText? {
        guard let fill = scannedFieldValue(for: fieldValue)?.fill else {
            return nil
        }
        return fill.text
    }

    func scannedFill(for fieldValue: FieldValue, with text: RecognizedText) -> Fill? {
        guard let fill = scannedFieldValue(for: fieldValue)?.fill,
              fill.text == text else {
            return nil
        }
        return fill
    }
}

