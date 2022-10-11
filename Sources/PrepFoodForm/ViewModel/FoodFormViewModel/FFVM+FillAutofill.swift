import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepUnits

extension Array where Element == ScanResult {
    var bestColumn: Int {
        1
    }
}
extension FoodFormViewModel {

    func fieldValueFromScanResults(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
        switch fieldValue {
        case .energy:
            return fieldValueFromScanResults(for: .energy, at: column)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb:
                return fieldValueFromScanResults(for: .carbohydrate, at: column)
            case .fat:
                return fieldValueFromScanResults(for: .fat, at: column)
            case .protein:
                return fieldValueFromScanResults(for: .protein, at: column)
            }
        case .micro(let microValue):
            return fieldValueFromScanResults(for: microValue.nutrientType, at: column)
        default:
            return nil
        }
    }
    
    var scanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }

    func processScanResults(column: Int? = nil) {
        let column = column ?? scanResults.bestColumn
        extractEnergy(at: column)
        extractMacro(.carb, at: column)
        extractMacro(.protein, at: column)
        extractMacro(.fat, at: column)
        for nutrient in NutrientType.allCases {
            extractNutrient(nutrient, at: column)
        }
        
        extractSizes()
        
        extractServing(for: column)
        extractAmount(for: column)
        extractDensity()
        
        updateShouldShowDensitiesSection()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for fieldViewModel in self.allFieldViewModels {
                fieldViewModel.isCroppingNextImage = true
                fieldViewModel.cropFilledImage()
            }
        }
    }
    
    func extractSizes() {
        for scanResult in scanResults {
            for sizeViewModel in scanResult.allSizeViewModels {
                /// If we were able to add this size view model (if it wasn't a duplicate) ...
                guard add(sizeViewModel: sizeViewModel) else {
                    continue
                }
                /// ... then go ahead and add it to the `scannedFieldValues` array as well
                scannedFieldValues.append(sizeViewModel.fieldValue)
            }
        }
    }
    
    func extractEnergy(at column: Int) {
        guard let fieldValue = fieldValueFromScanResults(for: .energy, at: column) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        energyViewModel = .init(fieldValue: fieldValue)
        scannedFieldValues.append(fieldValue)
    }
    
    func extractMacro(_ macro: Macro, at column: Int) {
        guard let fieldValue = fieldValueFromScanResults(for: macro.attribute, at: column) else {
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
        scannedFieldValues.append(fieldValue)
    }
    
    func extractNutrient(_ nutrientType: NutrientType, at column: Int) {
        guard let fieldValue = fieldValueFromScanResults(for: nutrientType, at: column) else {
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
        micronutrients[indexes.groupIndex].fieldViewModels[indexes.fieldIndex] = .init(fieldValue: fieldValue)
        scannedFieldValues.append(fieldValue)
    }
    
    func micronutrientIndexes(for nutrientType: NutrientType) -> (groupIndex: Int, fieldIndex: Int)? {
        guard let groupIndex = micronutrients.firstIndex(where: { $0.group == nutrientType.group }) else {
            return nil
        }
        guard let fieldIndex = micronutrients[groupIndex].fieldViewModels.firstIndex(where: { $0.fieldValue.microValue.nutrientType == nutrientType }) else {
            return nil
        }
        return (groupIndex, fieldIndex)
    }

    func fieldValueFromScanResults(for attribute: Attribute? = nil, at column: Int) -> FieldValue? {
        fieldValueFromScanResults(for: attribute, orNutrientType: nil, at: column)
    }

    func fieldValueFromScanResults(for nutrientType: NutrientType? = nil, at column: Int) -> FieldValue? {
        fieldValueFromScanResults(for: nil, orNutrientType: nutrientType, at: column)
    }
    
    func extractServing(for column: Int) {
        guard let fieldValue = fieldValueFromScanResultsForServing(for: column) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        servingViewModel = .init(fieldValue: fieldValue)
        scannedFieldValues.append(fieldValue)
    }

    func extractAmount(for column: Int) {
        guard let fieldValue = fieldValueFromScanResultsForAmount(for: column) else {
            return
        }
        //TODO: Only do this if user hasn't already got a value in there
        amountViewModel = .init(fieldValue: fieldValue)
        scannedFieldValues.append(fieldValue)
    }
    
    func extractDensity() {
        guard let fieldValue = fieldValueFromScanResultsForDensity() else {
            return
        }
        densityViewModel = .init(fieldValue: fieldValue)
        scannedFieldValues.append(fieldValue)
    }

    func fieldValueFromScanResultsForServing(for column: Int) -> FieldValue? {
        /// **We're current returning the first one we find amongst the images**
        for scanResult in scanResults {
            if let fieldValue = scanResult.servingFieldValue(for: column) {
                return fieldValue
            }
        }
        return nil
    }
    
    func fieldValueFromScanResultsForAmount(for column: Int) -> FieldValue? {
        /// **We're current returning the first one we find amongst the images**
        for scanResult in scanResults {

            if let fieldValue = scanResult.amountFieldValue(for: column) {
                //TODO: Revisit this if need be
                //TODO: Make sure these are added
//                let sizeViewModels = scanResult.amountSizeViewModels
//                for sizeViewModel in sizeViewModels {
//                    add(sizeViewModel: sizeViewModel)
//                }
                return fieldValue
            }
        }
        return nil
    }
    
    func fieldValueFromScanResultsForDensity() -> FieldValue? {
        for scanResult in scanResults {
            if let fieldValue = scanResult.densityFieldValue {
                return fieldValue
            }
        }
        return nil
    }
    
    func fieldValueFromScanResults(for attribute: Attribute? = nil, orNutrientType nutrientType: NutrientType? = nil, at column: Int) -> FieldValue? {
        
        guard attribute != nil || nutrientType != nil else {
            return nil
        }
        
        var candidate: FieldValue? = nil
        var nutrientCountOfArrayContainingCandidate = 0
        for scanResult in scanResults {
            
            let fieldValue: FieldValue?
            if let attribute {
                fieldValue = scanResult.fieldValue(for: attribute, at: column)
            } else if let nutrientType {
                fieldValue = scanResult.microFieldValue(for: nutrientType, at: column)
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

extension FoodLabelUnit {
    var formUnit: FormUnit? {
        switch self {
        case .cup:
            return .volume(.cup)
        case .mg:
            return .weight(.mg)
        case .kj:
            return .weight(.kg)
        case .g:
            return .weight(.g)
        case .oz:
            return .weight(.oz)
        case .ml:
            return .volume(.mL)
        case .tbsp:
            return .volume(.tablespoon)
        default:
            return nil
        }
    }
}

extension ScanResult {
    
    func fieldValue(for attribute: Attribute, at column: Int) -> FieldValue? {
        switch attribute {
        case .energy:
            return energyFieldValue(at: column)
        case .carbohydrate, .protein, .fat:
            return macroFieldValue(for: attribute, at: column)
        default:
            return nil
        }
    }
    
    func energyFieldValue(at column: Int) -> FieldValue? {
        guard let row = row(for: .energy),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column)
        else {
            return nil
        }
        let fill: Fill
        if valueText.text.id == defaultUUID {
            fill = .calculated
        } else {
            fill = .scanned(.init(valueText: valueText, imageId: id))
        }
        return FieldValue.energy(FieldValue.EnergyValue(
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.energyUnit ?? .kcal,
            fill: fill)
        )
    }
    
    func macroFieldValue(for attribute: Attribute, at column: Int) -> FieldValue? {
        guard let row = row(for: attribute),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column),
              let macro = attribute.macro
        else {
            return nil
        }
        
        let fill: Fill
        if valueText.text.id == defaultUUID {
            fill = .calculated
        } else {
            fill = .scanned(.init(valueText: valueText, imageId: id))
        }
        return FieldValue.macro(FieldValue.MacroValue(
            macro: macro,
            double: value.amount,
            string: value.amount.cleanAmount,
            fill: fill)
        )
    }

    func microFieldValue(for nutrientType: NutrientType, at column: Int) -> FieldValue? {
        guard let attribute = nutrientType.attribute,
              let row = row(for: attribute),
              let valueText = row.valueText(at: column),
              let value = row.value(at: column)
        else {
            return nil
        }
        
        let fill: Fill
        if valueText.text.id == defaultUUID {
            fill = .calculated
        } else {
            fill = .scanned(.init(valueText: valueText, imageId: id))
        }

        let unit = value.unit?.nutrientUnit(for: nutrientType) ?? nutrientType.defaultUnit
        
        return FieldValue.micro(FieldValue.MicroValue(
            nutrientType: nutrientType,
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: unit,
            fill: fill)
        )
    }

    
    func row(for attribute: Attribute) -> ScanResult.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}

extension ScanResult.Nutrients.Row {
    func valueText(at column: Int) -> ValueText? {
        column == 1 ? valueText1 : valueText2
    }
    
    func value(at column: Int) -> FoodLabelValue? {
        column == 1 ? value1 : value2
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
//        case .iu:
//            return .IU
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

import VisionSugar

let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
let defaulText = RecognizedText(id: defaultUUID, rectString: "", boundingBoxString: nil, candidates: [])

extension ScanResult {
    static var mockServing: ScanResult {
        
        let serving = ScanResult.Serving(
            amountText: DoubleText(double: 1,
                                   text: defaulText, attributeText: defaulText),
            unitText: nil,
            unitNameText: StringText(string: "pack",
                                     text: defaulText, attributeText: defaulText),
            equivalentSize: Serving.EquivalentSize(
                amountText: DoubleText(
                    double: 3,
                    text: defaulText, attributeText: defaulText),
                unitText: nil,
                unitNameText: StringText(
                    string: "pieces",
                    text: defaulText, attributeText: defaulText)
            ),
            perContainer: nil
        )
        
        return ScanResult(
            serving: serving,
            headers: nil,
            nutrients: Nutrients(rows: []),
            texts: [])
    }
}
