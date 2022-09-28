import SwiftUI
import NutritionLabelClassifier
import SwiftHaptics
import PrepUnits

extension FoodFormViewModel {

    func fieldValueFromOutputs(for fieldValue: FieldValue) -> FieldValue? {
        switch fieldValue {
        case .energy:
            return fieldValueFromOutputs(for: .energy)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb:
                return fieldValueFromOutputs(for: .carbohydrate)
            case .fat:
                return fieldValueFromOutputs(for: .fat)
            case .protein:
                return fieldValueFromOutputs(for: .protein)
            }
        default:
            return nil
        }
    }
    
    var outputs: [Output] {
        imageViewModels.compactMap { $0.output }
    }

    func processAllClassifierOutputs() {
        //TODO: Decide which column we're going to be using
        extractEnergy()
        extractMacro(.carb)
        extractMacro(.protein)
        extractMacro(.fat)
    }

    func extractEnergy() {
        guard let fieldValue = fieldValueFromOutputs(for: .energy) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        withAnimation {
            energy = fieldValue
        }
    }
    
    func extractMacro(_ macro: Macro) {
        guard let fieldValue = fieldValueFromOutputs(for: macro.attribute) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        withAnimation {
            switch macro {
            case .carb:
                carb = fieldValue
            case .fat:
                fat = fieldValue
            case .protein:
                protein = fieldValue
            }
        }
    }
    
    func fieldValueFromOutputs(for attribute: Attribute) -> FieldValue? {
        var candidate: FieldValue? = nil
        var nutrientCountOfArrayContainingCandidate = 0
        for output in outputs {
            guard let fieldvalue = output.fieldValue(for: attribute) else {
                continue
            }
            
            /// Keep picking the candidate that comes from the output with the largest set of nutrients in case of duplicates (for now)
            //TODO: Improve this
            if output.nutrients.rows.count > nutrientCountOfArrayContainingCandidate {
                nutrientCountOfArrayContainingCandidate = output.nutrients.rows.count
                candidate = fieldvalue
            }
        }
        
        return candidate
    }
}

extension Output {
    
    func fieldValue(for attribute: Attribute) -> FieldValue? {
        switch attribute {
        case .energy:
            return energyFieldValue
        case .carbohydrate, .protein, .fat:
            return macroFieldValue(for: attribute)
        default:
            return nil
        }
    }
    
    var energyFieldValue: FieldValue? {
        guard let row = row(for: .energy),
              let valueText = row.valueText1,
              let value = row.value1
        else {
            return nil
        }
        return FieldValue.energy(FieldValue.EnergyValue(
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.energyUnit ?? .kcal,
            fillType: .imageAutofill(valueText: valueText, outputId: self.id)))
    }
    
    func macroFieldValue(for attribute: Attribute) -> FieldValue? {
        guard let row = row(for: attribute),
              let valueText = row.valueText1,
              let value = row.value1,
              let macro = attribute.macro
        else {
            return nil
        }
        return FieldValue.macro(FieldValue.MacroValue(
            macro: macro,
            double: value.amount,
            string: value.amount.cleanAmount,
            fillType: .imageAutofill(valueText: valueText, outputId: self.id)))
    }

    
    func row(for attribute: Attribute) -> Output.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}

extension NutritionUnit {
    var energyUnit: EnergyUnit {
        switch self {
        case .kcal:
            return .kcal
        case .kj:
            return .kJ
        default:
            return .kcal
        }
    }
}

extension Attribute {
    var macro: Macro? {
        switch self {
        case .carbohydrate: return .carb
        case .fat: return .fat
        case .protein: return .protein
        default: return nil
        }
    }
}

extension Macro {
    var attribute: Attribute {
        switch self {
        case .carb:
            return .carbohydrate
        case .fat:
            return .fat
        case .protein:
            return .protein
        }
    }
}
