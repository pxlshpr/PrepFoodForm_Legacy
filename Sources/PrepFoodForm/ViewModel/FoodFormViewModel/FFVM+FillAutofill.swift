import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepUnits

extension FoodFormViewModel {

    func fieldValueFromScanResults(for fieldValue: FieldValue) -> FieldValue? {
        switch fieldValue {
        case .energy:
            return fieldValueFromScanResults(for: .energy)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb:
                return fieldValueFromScanResults(for: .carbohydrate)
            case .fat:
                return fieldValueFromScanResults(for: .fat)
            case .protein:
                return fieldValueFromScanResults(for: .protein)
            }
        case .micro(let microValue):
            return fieldValueFromScanResults(for: microValue.nutrientType)
        default:
            return nil
        }
    }
    
    var scanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }

    func processScanResults() {
        extractEnergy()
        extractMacro(.carb)
        extractMacro(.protein)
        extractMacro(.fat)
        for nutrient in NutrientType.allCases {
            extractNutrient(nutrient)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for fieldValueViewModel in self.allFieldValueViewModels {
                fieldValueViewModel.isCroppingNextImage = true
                fieldValueViewModel.cropFilledImage()
            }
        }
    }
    
    func extractEnergy() {
        guard let fieldValue = fieldValueFromScanResults(for: .energy) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        energyViewModel = .init(fieldValue: fieldValue)
        autofillFieldValues.append(fieldValue)
    }
    
    func extractMacro(_ macro: Macro) {
        guard let fieldValue = fieldValueFromScanResults(for: macro.attribute) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        switch macro {
        case .carb:
            carbViewModel = .init(fieldValue: fieldValue)
        case .fat:
            fatViewModel = .init(fieldValue: fieldValue)
        case .protein:
            proteinViewModel = .init(fieldValue: fieldValue)
        }
        autofillFieldValues.append(fieldValue)
    }
    
    func extractNutrient(_ nutrientType: NutrientType) {
        guard let attribute = nutrientType.attribute,
              let fieldValue = fieldValueFromScanResults(for: nutrientType) else {
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
        micronutrients[indexes.groupIndex].fieldValueViewModels[indexes.fieldIndex] = .init(fieldValue: fieldValue)
        autofillFieldValues.append(fieldValue)
    }
    
    func micronutrientIndexes(for nutrientType: NutrientType) -> (groupIndex: Int, fieldIndex: Int)? {
        guard let groupIndex = micronutrients.firstIndex(where: { $0.group == nutrientType.group }) else {
            return nil
        }
        guard let fieldIndex = micronutrients[groupIndex].fieldValueViewModels.firstIndex(where: { $0.fieldValue.microValue.nutrientType == nutrientType }) else {
            return nil
        }
        return (groupIndex, fieldIndex)
    }

    func fieldValueFromScanResults(for attribute: Attribute? = nil) -> FieldValue? {
        fieldValueFromScanResults(for: attribute, orNutrientType: nil)
    }

    func fieldValueFromScanResults(for nutrientType: NutrientType? = nil) -> FieldValue? {
        fieldValueFromScanResults(for: nil, orNutrientType: nutrientType)
    }
    
    func fieldValueFromScanResults(for attribute: Attribute? = nil, orNutrientType nutrientType: NutrientType? = nil) -> FieldValue? {
        
        guard attribute != nil || nutrientType != nil else {
            return nil
        }
        
        var candidate: FieldValue? = nil
        var nutrientCountOfArrayContainingCandidate = 0
        for scanResult in scanResults {
            
            let fieldValue: FieldValue?
            if let attribute {
                fieldValue = scanResult.fieldValue(for: attribute)
            } else if let nutrientType {
                fieldValue = scanResult.microFieldValue(for: nutrientType)
            } else {
                fieldValue = nil
            }
            
            guard let fieldValue else {
                continue
            }
            
            /// Keep picking the candidate that comes from the scanResult with the largest set of nutrients in case of duplicates (for now)
            //TODO: Improve this
            if scanResult.nutrients.rows.count > nutrientCountOfArrayContainingCandidate {
                nutrientCountOfArrayContainingCandidate = scanResult.nutrients.rows.count
                candidate = fieldValue
            }
        }
        
        return candidate
    }
}

extension ScanResult {
    
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
        let fillType: FillType
        if valueText.text.id == defaultUUID {
            fillType = .calculated
        } else {
            fillType = .imageAutofill(valueText: valueText, scanResultId: self.id)
        }
        return FieldValue.energy(FieldValue.EnergyValue(
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.energyUnit ?? .kcal,
            fillType: fillType)
        )
    }
    
    func macroFieldValue(for attribute: Attribute) -> FieldValue? {
        guard let row = row(for: attribute),
              let valueText = row.valueText1,
              let value = row.value1,
              let macro = attribute.macro
        else {
            return nil
        }
        
        let fillType: FillType
        if valueText.text.id == defaultUUID {
            fillType = .calculated
        } else {
            fillType = .imageAutofill(valueText: valueText, scanResultId: self.id)
        }
        return FieldValue.macro(FieldValue.MacroValue(
            macro: macro,
            double: value.amount,
            string: value.amount.cleanAmount,
            fillType: fillType)
        )
    }

    func microFieldValue(for nutrientType: NutrientType) -> FieldValue? {
        guard let attribute = nutrientType.attribute,
              let row = row(for: attribute),
              let valueText = row.valueText1,
              let value = row.value1
        else {
            return nil
        }
        
        let fillType: FillType
        if valueText.text.id == defaultUUID {
            fillType = .calculated
        } else {
            fillType = .imageAutofill(valueText: valueText, scanResultId: self.id)
        }

        let unit = value.unit?.nutrientUnit(for: nutrientType) ?? nutrientType.defaultUnit
        
        return FieldValue.micro(FieldValue.MicroValue(
            nutrientType: nutrientType,
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: unit,
            fillType: fillType)
        )
    }

    
    func row(for attribute: Attribute) -> ScanResult.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}

extension FoodLabelUnit {
    func nutrientUnit(for nutrientType: NutrientType) -> NutrientUnit? {
        switch self {
        case .mcg:
            return .mcg
        case .mg:
            return .mg
        case .g:
            return .g
        case .p:
            return .p
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

let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
