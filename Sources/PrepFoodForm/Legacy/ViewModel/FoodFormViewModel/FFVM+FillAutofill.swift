import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepDataTypes

extension FoodFormViewModel {

    var scanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
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

//extension NutrientType {
//    var attribute: Attribute? {
//        switch self {
//        case .saturatedFat:
//            return .saturatedFat
//        case .monounsaturatedFat:
//            return .monounsaturatedFat
//        case .polyunsaturatedFat:
//            return .polyunsaturatedFat
//        case .transFat:
//            return .transFat
//        case .cholesterol:
//            return .cholesterol
//        case .dietaryFiber:
//            return .dietaryFibre
//        case .solubleFiber:
//            return .solubleFibre
//        case .insolubleFiber:
//            return .insolubleFibre
//        case .sugars:
//            return .sugar
//        case .addedSugars:
//            return .addedSugar
//        case .calcium:
//            return .calcium
//        case .chromium:
//            return .chromium
//        case .iodine:
//            return .iodine
//        case .iron:
//            return .iron
//        case .magnesium:
//            return .magnesium
//        case .manganese:
//            return .manganese
//        case .potassium:
//            return .potassium
//        case .selenium:
//            return .selenium
//        case .sodium:
//            return .sodium
//        case .zinc:
//            return .zinc
//        case .vitaminA:
//            return .vitaminA
//        case .vitaminB6:
//            return .vitaminB6
//        case .vitaminB12:
//            return .vitaminB12
//        case .vitaminC:
//            return .vitaminC
//        case .vitaminD:
//            return .vitaminD
//        case .vitaminE:
//            return .vitaminE
//        case .vitaminK:
//            return .vitaminK
//        case .biotin:
//            return .biotin
//        case .folate:
//            return .folate
//        case .niacin:
//            return .niacin
//        case .pantothenicAcid:
//            return .pantothenicAcid
//        case .riboflavin:
//            return .riboflavin
//        case .thiamin:
//            return .thiamin
//        case .vitaminB2:
//            return .vitaminB2
//        case .cobalamin:
//            return .cobalamin
//        case .folicAcid:
//            return .folicAcid
//        case .vitaminB1:
//            return .vitaminB1
//        case .vitaminB3:
//            return .vitaminB3
//        case .vitaminK2:
//            return .vitaminK2
//        case .caffeine:
//            return .caffeine
//        case .taurine:
//            return .taurine
//        case .polyols:
//            return .polyols
//        case .gluten:
//            return .gluten
//        case .starch:
//            return .starch
//        case .salt:
//            return .salt
//            
//        default:
//            return nil
//        }
//    }
//}

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
