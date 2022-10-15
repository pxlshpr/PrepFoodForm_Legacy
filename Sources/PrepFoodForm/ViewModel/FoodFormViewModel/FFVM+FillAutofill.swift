import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepUnits

extension FoodFormViewModel {

//    func fieldValueFromScanResults(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
//        switch fieldValue {
//        case .energy:
//            return fieldValueFromScanResults(for: .energy, at: column)
//        case .macro(let macroValue):
//            switch macroValue.macro {
//            case .carb:
//                return fieldValueFromScanResults(for: .carbohydrate, at: column)
//            case .fat:
//                return fieldValueFromScanResults(for: .fat, at: column)
//            case .protein:
//                return fieldValueFromScanResults(for: .protein, at: column)
//            }
//        case .micro(let microValue):
//            return fieldValueFromScanResults(for: microValue.nutrientType, at: column)
//        default:
//            return nil
//        }
//    }
    
    var scanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }
    
//    func extractBarcode(from scanResult: ScanResult) {
//        guard let first = scanResult.barcodes.first else {
//            return
//        }
//        print("🍄 Setting barcode to be: \(first.string)")
//        self.barcodeViewModel.fieldValue.string = first.string
//    }
//    
//    func extractSizes(from scanResult: ScanResult) {
//        for sizeViewModel in scanResult.allSizeViewModels {
//            /// If we were able to add this size view model (if it wasn't a duplicate) ...
//            guard add(sizeViewModel: sizeViewModel) else {
//                continue
//            }
//            /// ... then go ahead and add it to the `scannedFieldValues` array as well
//            scannedFieldValues.append(sizeViewModel.fieldValue)
//        }
//    }

//    func extractEnergy_legacy(from scanResult: ScanResult, at column: Int) {
//        guard let fieldValue = scanResult.energyFieldValue(at: column) else { return }
//
//        switch energyViewModel.fill {
//        case .userInput:
//            if energyViewModel.fieldValue.isEmpty {
//                print("👑 It's empty — filling it")
//                energyViewModel = .init(fieldValue: fieldValue)
//                addSubscription(for: energyViewModel)
//            } else {
//                print("👑 We have user input: \(energyViewModel.fieldValue.string)")
//            }
//        case .selection:
//            print("👑 We have a user-selected value, don't replace it")
//        case .scanned(let info):
//            //TODO: overwrite this if from a better scanResult
//            // We could do this from the processResults() func and pick the best scanResult and only extract that
//            // but that will ignore the scanResults that aren't the best that might have missing values
//            //ALSO—revisit calling the entire processResults() each time an image is added
//            //Maybe we should add them as they come in (not re-extracting previous ones)
//            //  But we don't want to keep extracting as images are extracted because the food label will keep changing
//            //  so if we're doing that—grab all the scanresults while we wait for all images to finish and then do it at the end
//            print("👑 We have a scanned value")
//        case .prefill(let info):
//            //TODO: What do we do when have a prefilled value? Maybe overwrite it
//            print("👑 We have a prefilled value")
//        default:
//            print("👑 We have an unhandle fill type")
//        }
//        //TODO: We keep duplicating values here—check for dupes each time
//        scannedFieldValues.append(fieldValue)
//    }
//
//    func extractMacro(_ macro: Macro, from scanResult: ScanResult, at column: Int) {
//        guard let fieldValue = scanResult.macroFieldValue(for: macro, at: column) else {
//            return
//        }
//        //TODO: Only do this if user hasn't already got a value in there
//        switch macro {
//        case .carb:
//            carbViewModel = .init(fieldValue: fieldValue)
//        case .fat:
//            fatViewModel = .init(fieldValue: fieldValue)
//        case .protein:
//            proteinViewModel = .init(fieldValue: fieldValue)
//        }
//        scannedFieldValues.append(fieldValue)
//    }
//
//    func extractNutrient(_ nutrientType: NutrientType, from scanResult: ScanResult, at column: Int) {
//        guard let fieldValue = scanResult.microFieldValue(for: nutrientType, at: column) else {
//            return
//        }
//
//        print("Let's add: \(nutrientType.description)")
//        setMicronutrient(nutrientType, with: fieldValue)
//    }
    
//    func extractServing(from scanResult: ScanResult, for column: Int) {
//        guard let fieldValue = scanResult.servingFieldValue(for: column) else {
//            return
//        }
//        //TODO: Only do this if user hasn't already got a value in there
//        servingViewModel = .init(fieldValue: fieldValue)
//        scannedFieldValues.append(fieldValue)
//    }

//    func extractAmount(from scanResult: ScanResult, for column: Int) {
//        guard let fieldValue = scanResult.amountFieldValue(for: column) else {
//            return
//        }
//        //TODO: Only do this if user hasn't already got a value in there
//        //TODO: Also consider if we're doing this with a new image with possibly better results
//        amountViewModel = .init(fieldValue: fieldValue)
//        scannedFieldValues.append(fieldValue)
//    }
    
//    func extractDensity(from scanResult: ScanResult) {
//        guard let fieldValue = scanResult.densityFieldValue else {
//            return
//        }
//        densityViewModel = .init(fieldValue: fieldValue)
//        scannedFieldValues.append(fieldValue)
//    }
}

extension FoodFormViewModel {
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
            texts: [],
            barcodes: []
        )
    }
}
