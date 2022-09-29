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
        case .micro(let microValue):
            return fieldValueFromOutputs(for: microValue.nutrientType)
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
        for nutrient in NutrientType.allCases {
            extractNutrient(nutrient)
        }
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
    
    func extractNutrient(_ nutrientType: NutrientType) {
        guard let attribute = nutrientType.attribute,
              let fieldValue = fieldValueFromOutputs(for: nutrientType) else {
            return
        }
        
        print("Let's add: \(nutrientType.description)")
        setMicronutrient(nutrientType, with: fieldValue)
    }
    
    func setMicronutrient(_ nutrientType: NutrientType, with fieldValue: FieldValue) {
        guard let indexes = micronutrientIndexes(for: nutrientType) else {
            print("Couldn't find indexes for nutrientType: \(nutrientType) in micronutrients array")
            return
        }
        micronutrients[indexes.groupIndex].fieldValues[indexes.fieldIndex] = fieldValue
    }
    
    func micronutrientIndexes(for nutrientType: NutrientType) -> (groupIndex: Int, fieldIndex: Int)? {
        guard let groupIndex = micronutrients.firstIndex(where: { $0.group == nutrientType.group }) else {
            return nil
        }
        guard let fieldIndex = micronutrients[groupIndex].fieldValues.firstIndex(where: { $0.microValue.nutrientType == nutrientType }) else {
            return nil
        }
        return (groupIndex, fieldIndex)
    }

    func fieldValueFromOutputs(for attribute: Attribute? = nil) -> FieldValue? {
        fieldValueFromOutputs(for: attribute, orNutrientType: nil)
    }

    func fieldValueFromOutputs(for nutrientType: NutrientType? = nil) -> FieldValue? {
        fieldValueFromOutputs(for: nil, orNutrientType: nutrientType)
    }
    
    func fieldValueFromOutputs(for attribute: Attribute? = nil, orNutrientType nutrientType: NutrientType? = nil) -> FieldValue? {
        
        guard attribute != nil || nutrientType != nil else {
            return nil
        }
        
        var candidate: FieldValue? = nil
        var nutrientCountOfArrayContainingCandidate = 0
        for output in outputs {
            
            let fieldValue: FieldValue?
            if let attribute {
                fieldValue = output.fieldValue(for: attribute)
            } else if let nutrientType {
                fieldValue = output.microFieldValue(for: nutrientType)
            } else {
                fieldValue = nil
            }
            
            guard let fieldValue else {
                continue
            }
            
            /// Keep picking the candidate that comes from the output with the largest set of nutrients in case of duplicates (for now)
            //TODO: Improve this
            if output.nutrients.rows.count > nutrientCountOfArrayContainingCandidate {
                nutrientCountOfArrayContainingCandidate = output.nutrients.rows.count
                candidate = fieldValue
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

    func microFieldValue(for nutrientType: NutrientType) -> FieldValue? {
        guard let attribute = nutrientType.attribute,
              let row = row(for: attribute),
              let valueText = row.valueText1,
              let value = row.value1
        else {
            return nil
        }
        return FieldValue.micro(FieldValue.MicroValue(
            nutrientType: nutrientType,
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.nutrientUnit ?? attribute.defaultUnit?.nutrientUnit ?? .g,
            fillType: .imageAutofill(valueText: valueText, outputId: self.id))
        )
    }

    
    func row(for attribute: Attribute) -> Output.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}

extension NutritionUnit {
    var nutrientUnit: NutrientUnit? {
        switch self {
        case .mcg:
            return .mcg
        case .mg:
            return .mg
        case .g:
            return .g
        default:
            return nil
        }
    }
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

extension NutrientType {
    var attribute: Attribute? {
        switch self {
        case .saturatedFat:
            return .saturatedFat
        case .monounsaturatedFat:
            return .monounsaturatedFat
        case .polyunsaturatedFat:
            return .polyunsaturatedFat
        case .transFat:
            return .transFat
        case .cholesterol:
            return .cholesterol
        case .dietaryFiber:
            return .dietaryFibre
        case .solubleFiber:
            return .solubleFibre
        case .insolubleFiber:
            return .insolubleFibre
        case .sugars:
            return .sugar
        case .addedSugars:
            return .addedSugar
        case .calcium:
            return .calcium
        case .chromium:
            return .chromium
        case .iodine:
            return .iodine
        case .iron:
            return .iron
        case .magnesium:
            return .magnesium
        case .manganese:
            return .manganese
        case .potassium:
            return .potassium
        case .selenium:
            return .selenium
        case .sodium:
            return .sodium
        case .zinc:
            return .zinc
        case .vitaminA:
            return .vitaminA
        case .vitaminB6:
            return .vitaminB6
        case .vitaminB12:
            return .vitaminB12
        case .vitaminC:
            return .vitaminC
        case .vitaminD:
            return .vitaminD
        case .vitaminE:
            return .vitaminE
        case .vitaminK:
            return .vitaminK
        case .biotin:
            return .biotin
        case .folate:
            return .folate
        case .niacin:
            return .niacin
        case .pantothenicAcid:
            return .pantothenicAcid
        case .riboflavin:
            return .riboflavin
        case .thiamin:
            return .thiamin
        case .vitaminB2:
            return .vitaminB2
        case .cobalamin:
            return .cobalamin
        case .folicAcid:
            return .folicAcid
        case .vitaminB1:
            return .vitaminB1
        case .vitaminB3:
            return .vitaminB3
        case .vitaminK2:
            return .vitaminK2
        case .caffeine:
            return .caffeine
        case .taurine:
            return .taurine
        case .polyols:
            return .polyols
        case .gluten:
            return .gluten
        case .starch:
            return .starch
        case .salt:
            return .salt
            
        //TODO: Add support for these
        case .sugarAlcohols, .chloride, .copper, .molybdenum, .phosphorus, .choline, .ethanol:
            return nil
        }
    }
}
