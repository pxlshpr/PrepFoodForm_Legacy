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
