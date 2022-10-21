import SwiftUI
import MFPScraper
import VisionSugar
import FoodLabelScanner
import PrepUnits
import PrepNetworkController

struct FoodImage: Codable {
    
    let id: UUID
    let scanResult: ScanResult?
    let barcodes: [RecognizedBarcode]
    
    init(_ imv: ImageViewModel) {
        self.id = imv.id
        self.scanResult = imv.scanResult
        self.barcodes = imv.recognizedBarcodes
    }
}

struct FoodFormData: Codable {

    let name: FieldValue?
    let emoji: FieldValue?
    let detail: FieldValue?
    let brand: FieldValue?
    
    let amount: FieldValue?
    let serving: FieldValue?
    let energy: FieldValue?
    let carb: FieldValue?
    let fat: FieldValue?
    let protein: FieldValue?
    let density: FieldValue?
    
    let sizes: [FieldValue]
    let barcodes: [FieldValue]
    let micronutrients: [FieldValue]
    
    let link: String?
    let prefilledFood: MFPProcessedFood?
    let images: [FoodImage]

    init(_ ffvm: FoodFormViewModel) {
        self.name = ffvm.nameViewModel.fieldValue
        self.emoji = ffvm.emojiViewModel.fieldValue
        self.detail = ffvm.detailViewModel.fieldValue
        self.brand = ffvm.brandViewModel.fieldValue
        self.amount = ffvm.amountViewModel.fieldValue
        self.serving = ffvm.servingViewModel.fieldValue
        self.energy = ffvm.energyViewModel.fieldValue
        self.carb = ffvm.carbViewModel.fieldValue
        self.fat = ffvm.fatViewModel.fieldValue
        self.protein = ffvm.proteinViewModel.fieldValue
        self.density = ffvm.densityViewModel.fieldValue
        
        self.sizes = ffvm.allSizeViewModels.map { $0.fieldValue }
        self.barcodes = ffvm.barcodeViewModels.map { $0.fieldValue }
        self.micronutrients = ffvm.allIncludedMicronutrientFieldViewModels.map { $0.fieldValue }
        
        self.link = ffvm.linkInfo?.urlString
        self.prefilledFood = ffvm.prefilledFood
        self.images = ffvm.imageViewModels.map { FoodImage($0) }
    }
    
    static func save(_ ffvm: FoodFormViewModel) {
//        persistOnDevice(ffvm)
        uploadToServer(ffvm)
    }
    
    static func uploadToServer(_ ffvm: FoodFormViewModel) {
        guard let serverFoodForm = ffvm.serverFoodForm,
              let request = NetworkController.server.postRequest(for: serverFoodForm)
        else {
            return
        }
        
        Task {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("🌐 Here's the response:")
            print("🌐 \(response)")
        }
    }
    
    static func persistOnDevice(_ ffvm: FoodFormViewModel) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        Task {
            let directoryUrl = documentsUrl.appending(component: ffvm.id.uuidString)
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false)
            
            for imv in ffvm.imageViewModels {
                try await imv.writeImage(to: directoryUrl)
            }

            let encoder = JSONEncoder()
            let data = try encoder.encode(FoodFormData(ffvm))

            let foodUrl = directoryUrl.appending(component: "FoodFormData.json")
            try data.write(to: foodUrl)
            print("📝 Wrote food to: \(directoryUrl)")
        }
    }
}

extension FieldViewModel {
    var string: String {
        fieldValue.string
    }
    
    var stringIfNotEmpty: String? {
        string.isEmpty ? nil : string
    }
}

import Vision

extension VNBarcodeSymbology {
    var serverInt: Int16 {
        switch self {
        case .aztec: return 1
        case .code39: return 2
        case .code39Checksum: return 3
        case .code39FullASCII: return 4
        case .code39FullASCIIChecksum: return 5
        case .code93: return 6
        case .code93i: return 7
        case .code128: return 8
        case .dataMatrix: return 9
        case .ean8: return 10
        case .ean13: return 11
        case .i2of5: return 12
        case .i2of5Checksum: return 13
        case .itf14: return 14
        case .pdf417: return 15
        case .qr: return 16
        case .upce: return 17
        case .codabar: return 18
        case .gs1DataBar: return 19
        case .gs1DataBarExpanded: return 20
        case .gs1DataBarLimited: return 21
        case .microPDF417: return 22
        case .microQR: return 23
        default: return 100
        }
    }
}

//extension VolumeUnit {
//    var serverInt: Int16? {
//        //TODO: Choose these based on user settings
//        switch self {
//        case .gallon:
//            return VolumeGallonUserUnit.gallonUSLiquid.rawValue
//        case .quart:
//            return VolumeQuartUserUnit.quartUSLiquid.rawValue
//        case .pint:
//            return VolumePintUserUnit.pintUSLiquid.rawValue
//        case .cup:
//            return VolumeCupUserUnit.cupUSLegal.rawValue
//        case .fluidOunce:
//            return VolumeFluidOunceUserUnit.fluidOunceUSNutritionLabeling.rawValue
//        case .tablespoon:
//            return VolumeTablespoonUserUnit.tablespoonUS.rawValue
//        case .teaspoon:
//            return VolumeTeaspoonUserUnit.teaspoonUS.rawValue
//        case .mL:
//            return VolumeMilliliterUserUnit.ml.rawValue
//        case .liter:
//            return VolumeLiterUserUnit.liter.rawValue
//        }
//    }
//}
//
//extension WeightUnit {
//    var serverInt: Int16 {
//        rawValue
//    }
//}
//
//extension FormUnit {
//    var sizeUnitId: UUID? {
//        guard case .size(let size, _) = self else { return nil }
//        return size.id
//    }
//    
//    var sizeUnitVolumePrefixUnitInt: Int16? {
//        guard case .size(_, let volumeUnit) = self else { return nil }
//        return volumeUnit?.serverInt
//    }
//    
//    var volumeUnitServerInt: Int16? {
//        guard case .volume(let volumeUnit) = self else { return nil }
//        return volumeUnit.serverInt
//    }
//
//    var weightUnitServerInt: Int16? {
//        guard case .weight(let weightUnit) = self else { return nil }
//        return weightUnit.serverInt
//    }
//    
//    var serverInt: Int16 {
//        switch self {
//        case .weight:   return 1
//        case .volume:   return 2
//        case .size:     return 3
//        case .serving:  return 4
//        }
//    }
//}

extension FieldViewModel {
    var serverBarcode: ServerBarcode? {
        guard let barcodeValue else { return nil }
        return ServerBarcode(payload: barcodeValue.payloadString, symbology: barcodeValue.symbology.serverInt)
    }
    
    var serverAmountWithUnit: ServerAmountWithUnit {
        let doubleValue = fieldValue.doubleValue
        let unit = doubleValue.unit
        return ServerAmountWithUnit(
            double: doubleValue.double ?? 0,
            unit: unit.serverInt,
            weightUnit: unit.weightUnitServerInt,
            volumeUnit: unit.volumeUnitServerInt,
            sizeUnitId: unit.sizeUnitId,
            sizeUnitVolumePrefixUnit: unit.sizeUnitVolumePrefixUnitInt)
    }
    
    var energyInKcal: Double {
        fieldValue.energyValue.inKcal
    }
    
    var serverMicronutrient: ServerMicronutrient? {
        let microValue = fieldValue.microValue
        
        return ServerMicronutrient(
            nutrientType: microValue.nutrientType.rawValue,
            amount: microValue.double ?? 0,
            unit: microValue.unit.rawValue
        )
    }
    
    var serverSize: ServerSize? {
        size?.serverSize
    }
}

extension FieldValue.DensityValue {
    var serverDensity: ServerDensity {
        ServerDensity(
            weightDouble: weight.double ?? 0,
            weightUnit: weight.unit.serverInt,
            volumeDouble: volume.double ?? 0,
            volumeUnit: volume.unit.serverInt
        )
    }
}

extension FormSize {
    var serverSize: ServerSize {
        ServerSize(
            name: name,
            volumePrefixUnit: volumePrefixUnit?.volumeUnitServerInt,
            quantity: quantity ?? 1,
            amount: amount ?? 0,
            unit: unit.serverInt,
            weightUnit: unit.weightUnitServerInt,
            volumeUnit: unit.volumeUnitServerInt,
            sizeUnitId: unit.sizeUnitId,
            sizeUnitVolumePrefixUnit: unit.sizeUnitVolumePrefixUnitInt
        )
    }
}

extension FoodFormViewModel {
    
    var serverBarcodes: [ServerBarcode] {
        barcodeViewModels.compactMap { $0.serverBarcode }
    }
    
    var serverAmount: ServerAmountWithUnit {
        amountViewModel.serverAmountWithUnit
    }
    
    var serverServing: ServerAmountWithUnit {
        servingViewModel.serverAmountWithUnit
    }
    
    var serverMicronutrients: [ServerMicronutrient] {
        allIncludedMicronutrientFieldViewModels.compactMap {
            $0.serverMicronutrient
        }
    }
    
    var serverNutrients: ServerNutrients {
        ServerNutrients(
            energyInKcal: energyViewModel.energyInKcal,
            carb: carbAmount,
            protein: proteinAmount,
            fat: fatAmount,
            micronutrients: serverMicronutrients
        )
    }
    
    var serverDensity: ServerDensity? {
        densityViewModel.fieldValue.densityValue?.serverDensity
    }

    var serverSizes: [ServerSize] {
        allSizeViewModels.compactMap {
            $0.serverSize
        }
    }
    
    var imageIds: [UUID] {
        imageViewModels.map { $0.id }
    }
    
    var foodType: FoodType {
        FoodType.userPublic(.verified)
    }
    
    var serverFood: ServerFood? {
        ServerFood(
            id: id,
            name: nameViewModel.string,
            emoji: emojiViewModel.string,
            detail: detailViewModel.stringIfNotEmpty,
            brand: brandViewModel.stringIfNotEmpty,
            amount: serverAmount,
            serving: serverServing,
            nutrients: serverNutrients,
            sizes: serverSizes,
            density: serverDensity,
            linkUrl: linkInfo?.urlString,
            prefilledUrl: prefilledFood?.sourceUrl,
            imageIds: imageIds,
            
            /// Hardcoded for now
            type: foodType.serverInt,
            verificationStatus: foodType.verificationStatusServerInt,
            database: foodType.verificationStatusServerInt
        )
    }
    
    var serverFoodForm: ServerFoodForm? {
        guard let serverFood else { return nil }
        return ServerFoodForm(
            food: serverFood,
            barcodes: serverBarcodes
        )
    }
}

extension ImageViewModel {
    
    func writeImage(to directoryUrl: URL) async throws {
        guard let imageData else { return }
        let imageUrl = directoryUrl.appending(component: "\(id).jpg")
        try imageData.write(to: imageUrl)
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
   
   let widthRatio  = targetSize.width  / size.width
   let heightRatio = targetSize.height / size.height
   
   // Figure out what our orientation is, and use that to form the rectangle
   var newSize: CGSize
   if(widthRatio > heightRatio) {
       newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
   } else {
       newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
   }
   
   // This is the rect that we've calculated out and this is what is actually used below
   let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
   
   // Actually do the resizing to the rect using the ImageContext stuff
   UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
   image.draw(in: rect)
   let newImage = UIGraphicsGetImageFromCurrentImageContext()
   UIGraphicsEndImageContext()
   
   return newImage!
}
