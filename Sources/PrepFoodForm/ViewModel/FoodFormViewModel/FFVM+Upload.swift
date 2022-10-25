import Foundation
import PrepDataTypes

extension FoodFormViewModel {

    var userFoodCreateForm: UserFoodCreateForm? {
        guard let amountFoodValue = FoodValue(fieldViewModel: amountViewModel),
              let foodNutrients
        else {
            return nil
        }
        return UserFoodCreateForm(
            name: nameViewModel.string,
            emoji: emojiViewModel.string,
            detail: detailViewModel.string,
            brand: brandViewModel.string,
            amount: amountFoodValue,
            serving: FoodValue(fieldViewModel: servingViewModel),
            nutrients: foodNutrients,
            sizes: foodSizes,
            density: foodDensity,
            linkUrl: linkInfo?.urlString,
            prefilledUrl: prefilledFood?.sourceUrl,
            imageIds: imageViewModels.map { $0.id },
            status: .notPublished,
            spawnedUserFoodId: nil,
            spawnedDatabaseFoodId: nil,
            userId: UUID(uuidString: "951917ab-594a-4424-88e5-012223e8dfaf")!,
            barcodes: foodBarcodes
        )
    }
    
    var foodBarcodes: [FoodBarcode] {
        barcodeViewModels.compactMap { $0.foodBarcode }
    }
    
    var foodDensity: FoodDensity? {
        densityViewModel.fieldValue.densityValue?.foodDensity
    }
    
    var foodSizes: [FoodSize] {
        allSizes.compactMap {
            guard let quantity = $0.quantity,
                  let value = $0.foodValue
            else {
                return nil
            }
            
            return FoodSize(
                name: $0.name,
                volumePrefixExplicitUnit: $0.volumePrefixUnit?.volumeUnit?.volumeExplicitUnit,
                quantity: quantity,
                value: value
            )
        }
    }
    
    var foodNutrients: FoodNutrients? {
        guard let energy = energyViewModel.energyInKcal,
              let carb = carbViewModel.macroDouble,
              let fat = fatViewModel.macroDouble,
              let protein = proteinViewModel.macroDouble
        else {
            return nil
        }
              
        return FoodNutrients(
            energyInKcal: energy,
            carb: carb,
            protein: protein,
            fat: fat,
            micros: foodNutrientsArray
        )
    }
    
    var foodNutrientsArray: [FoodNutrient] {
        allIncludedMicronutrientFieldViewModels.compactMap {
            let microValue = $0.fieldValue.microValue
            guard let value = microValue.double else {
                return nil
            }
            return FoodNutrient(
                nutrientType: microValue.nutrientType,
                value: value,
                nutrientUnit: microValue.unit
            )
        }
    }
}

extension FieldValue.DensityValue {
    var foodDensity: FoodDensity? {
        guard let weightAmount = weight.double,
              let volumeAmount = volume.double,
              let weightUnit = weight.unit.weightUnit,
              let volumeExplicitUnit = volume.unit.volumeUnit?.volumeExplicitUnit
        else {
            return nil
        }
        return FoodDensity(
            weightAmount: weightAmount,
            weightUnit: weightUnit,
            volumeAmount: volumeAmount,
            volumeExplicitUnit: volumeExplicitUnit
        )
    }
}

extension FormSize {
    
    var foodValue: FoodValue? {
        guard let amount else { return nil }
        return FoodValue(value: amount, formUnit: unit)
    }
}

extension FieldViewModel {
    var energyInKcal: Double? {
        guard let value = fieldValue.energyValue.double else { return nil }
        if fieldValue.energyValue.unit == .kcal {
            return value
        } else {
            return value * KcalsPerKilojule
        }
    }
    
    var macroDouble: Double? {
        fieldValue.macroValue.double
    }
    
    var foodBarcode: FoodBarcode? {
        guard let barcodeValue, let symbology = barcodeValue.barcodeSymbology else {
            return nil
        }
        return FoodBarcode(
            payload: barcodeValue.payloadString,
            symbology: symbology
        )
    }
}

extension FieldValue.BarcodeValue {
    var barcodeSymbology: PrepDataTypes.BarcodeSymbology? {
        switch symbology {
        case .aztec:
            return .aztec
        case .code39:
            return .code39
        case .code39Checksum:
            return .code39Checksum
        case .code39FullASCII:
            return .code39FullASCII
        case .code39FullASCIIChecksum:
            return .code39FullASCIIChecksum
        case .code93:
            return .code93
        case .code93i:
            return .code93i
        case .code128:
            return .code128
        case .dataMatrix:
            return .dataMatrix
        case .ean8:
            return .ean8
        case .ean13:
            return .ean13
        case .i2of5:
            return .i2of5
        case .i2of5Checksum:
            return .i2of5Checksum
        case .itf14:
            return .itf14
        case .pdf417:
            return .pdf417
        case .qr:
            return .qr
        case .upce:
            return .upce
        case .codabar:
            return .codabar
        case .gs1DataBar:
            return .gs1DataBar
        case .gs1DataBarExpanded:
            return .gs1DataBarExpanded
        case .gs1DataBarLimited:
            return .gs1DataBarLimited
        case .microPDF417:
            return .microPDF417
        case .microQR:
            return .microQR
        default:
            return nil
        }
    }
}

extension FoodValue {
    
    init?(fieldViewModel: FieldViewModel) {
        let doubleValue = fieldViewModel.fieldValue.doubleValue
        let unit = doubleValue.unit
        guard let value = doubleValue.double else {
            return nil
        }
        self.init(value: value, formUnit: unit)
    }
    
    init(value: Double, formUnit: FormUnit) {
        let unitType = formUnit.unitType
        let weightUnit = formUnit.weightUnit
        let volumeExplicitUnit = formUnit.volumeUnit?.volumeExplicitUnit
        let sizeUnitId = formUnit.formSize?.id
        let sizeUnitVolumePrefixExplicitUnit = formUnit.sizeUnitVolumePrefixUnit?.volumeExplicitUnit
        
        self.init(
            value: value,
            unitType: unitType,
            weightUnit: weightUnit,
            volumeExplicitUnit: volumeExplicitUnit,
            sizeUnitId: sizeUnitId,
            sizeUnitVolumePrefixExplicitUnit: sizeUnitVolumePrefixExplicitUnit
        )
    }
}

extension VolumeUnit {
    var volumeExplicitUnit: VolumeExplicitUnit {
        //TODO: Choose these based on user settings
        switch self {
        case .gallon:
            return VolumeExplicitUnit.gallonUSLiquid
        case .quart:
            return VolumeExplicitUnit.quartUSLiquid
        case .pint:
            return VolumeExplicitUnit.pintUSLiquid
        case .cup:
            return VolumeExplicitUnit.cupUSLegal
        case .fluidOunce:
            return VolumeExplicitUnit.fluidOunceUSNutritionLabeling
        case .tablespoon:
            return VolumeExplicitUnit.tablespoonUS
        case .teaspoon:
            return VolumeExplicitUnit.teaspoonUS
        case .mL:
            return VolumeExplicitUnit.ml
        case .liter:
            return VolumeExplicitUnit.liter
        }
    }
}

//import SwiftUI
//import MFPScraper
//import VisionSugar
//import FoodLabelScanner
//import PrepDataTypes
//import PrepNetworkController
//
//extension FieldViewModel {
//    var serverBarcode: ServerBarcode? {
//        guard let barcodeValue else { return nil }
//        return ServerBarcode(payload: barcodeValue.payloadString, symbology: barcodeValue.symbology.serverInt)
//    }
//
//    var serverAmountWithUnit: ServerAmountWithUnit {
//        let doubleValue = fieldValue.doubleValue
//        let unit = doubleValue.unit
//        return ServerAmountWithUnit(
//            double: doubleValue.double ?? 0,
//            unit: unit.serverInt,
//            weightUnit: unit.weightUnitServerInt,
//            volumeUnit: unit.volumeUnitServerInt,
//            sizeUnitId: unit.sizeUnitId,
//            sizeUnitVolumePrefixUnit: unit.sizeUnitVolumePrefixUnitInt)
//    }
//
//    var energyInKcal: Double {
//        fieldValue.energyValue.inKcal
//    }
//
//    var serverMicronutrient: ServerMicronutrient? {
//        let microValue = fieldValue.microValue
//
//        return ServerMicronutrient(
//            nutrientType: microValue.nutrientType.rawValue,
//            amount: microValue.double ?? 0,
//            unit: microValue.unit.rawValue
//        )
//    }
//
//    var serverSize: ServerSize? {
//        size?.serverSize
//    }
//}
//
//extension FieldValue.DensityValue {
//    var serverDensity: ServerDensity {
//        ServerDensity(
//            weightDouble: weight.double ?? 0,
//            weightUnit: weight.unit.serverInt,
//            volumeDouble: volume.double ?? 0,
//            volumeUnit: volume.unit.serverInt
//        )
//    }
//}
//
//extension FormSize {
//    var serverSize: ServerSize {
//        ServerSize(
//            name: name,
//            volumePrefixUnit: volumePrefixUnit?.volumeUnitServerInt,
//            quantity: quantity ?? 1,
//            amount: amount ?? 0,
//            unit: unit.serverInt,
//            weightUnit: unit.weightUnitServerInt,
//            volumeUnit: unit.volumeUnitServerInt,
//            sizeUnitId: unit.sizeUnitId,
//            sizeUnitVolumePrefixUnit: unit.sizeUnitVolumePrefixUnitInt
//        )
//    }
//}
//
//extension FoodFormViewModel {
//
//    var serverBarcodes: [ServerBarcode] {
//        barcodeViewModels.compactMap { $0.serverBarcode }
//    }
//
//    var serverAmount: ServerAmountWithUnit {
//        amountViewModel.serverAmountWithUnit
//    }
//
//    var serverServing: ServerAmountWithUnit {
//        servingViewModel.serverAmountWithUnit
//    }
//
//    var serverMicronutrients: [ServerMicronutrient] {
//        allIncludedMicronutrientFieldViewModels.compactMap {
//            $0.serverMicronutrient
//        }
//    }
//
//    var serverNutrients: ServerNutrients {
//        ServerNutrients(
//            energyInKcal: energyViewModel.energyInKcal,
//            carb: carbAmount,
//            protein: proteinAmount,
//            fat: fatAmount,
//            micronutrients: serverMicronutrients
//        )
//    }
//
//    var serverDensity: ServerDensity? {
//        densityViewModel.fieldValue.densityValue?.serverDensity
//    }
//
//    var serverSizes: [ServerSize] {
//        allSizeViewModels.compactMap {
//            $0.serverSize
//        }
//    }
//
//    var imageIds: [UUID] {
//        imageViewModels.map { $0.id }
//    }
//
//    var foodType: FoodType {
//        FoodType.userPublic(.verified)
//    }
//
//    var serverFood: ServerFood? {
//        ServerFood(
//            id: id,
//            name: nameViewModel.string,
//            emoji: emojiViewModel.string,
//            detail: detailViewModel.stringIfNotEmpty,
//            brand: brandViewModel.stringIfNotEmpty,
//            amount: serverAmount,
//            serving: serverServing,
//            nutrients: serverNutrients,
//            sizes: serverSizes,
//            density: serverDensity,
//            linkUrl: linkInfo?.urlString,
//            prefilledUrl: prefilledFood?.sourceUrl,
//            imageIds: imageIds,
//
//            /// Hardcoded for now
//            type: foodType.serverInt,
//            verificationStatus: foodType.verificationStatusServerInt,
//            database: foodType.verificationStatusServerInt
//        )
//    }
//
//    var serverFoodForm: ServerFoodForm? {
//        guard let serverFood else { return nil }
//        return ServerFoodForm(
//            food: serverFood,
//            barcodes: serverBarcodes
//        )
//    }
//}
