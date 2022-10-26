import Foundation
import MFPScraper
import PrepDataTypes

struct FoodFormRawData: Codable {

    let name: FieldValue
    let emoji: FieldValue
    let detail: FieldValue?
    let brand: FieldValue?
    
    let amount: FieldValue
    let serving: FieldValue?
    let energy: FieldValue
    let carb: FieldValue
    let fat: FieldValue
    let protein: FieldValue
    let density: FieldValue?
    
    let sizes: [FieldValue]
    let barcodes: [FieldValue]
    let micronutrients: [FieldValue]
    
    let link: String?
    let prefilledFood: MFPProcessedFood?
    let images: [FoodImage]

    init?(_ ffvm: FoodFormViewModel) {
        guard ffvm.isValid else { return nil }
        
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
//        uploadToServer(ffvm)
    }
    
    static func uploadToServer(_ ffvm: FoodFormViewModel) {
        //TODO: Bring this back
//        guard let serverFoodForm = ffvm.serverFoodForm,
//              let request = NetworkController.server.postRequest(for: serverFoodForm)
//        else {
//            return
//        }
//
//        Task {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            print("🌐 Here's the response:")
//            print("🌐 \(response)")
//        }
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
            let data = try encoder.encode(FoodFormRawData(ffvm))

            let foodUrl = directoryUrl.appending(component: "FoodFormRawData.json")
            try data.write(to: foodUrl)
            print("📝 Wrote food to: \(directoryUrl)")
        }
    }
}

//extension FoodFormInfo {
//
//    var userFoodCreateForm: UserFoodCreateForm? {
//        guard let info = userFoodInfo,
//              let name = name?.string
//            
//        else {
//            return nil
//        }
//        return UserFoodCreateForm(
//            name: name?.string,
//            emoji: emojiViewModel.string,
//            detail: detailViewModel.string,
//            brand: brandViewModel.string,
//            status: .notPublished,
//            info: info
//        )
//    }
//    
//    var userFoodInfo: UserFoodInfo? {
//        guard let amountFoodValue = FoodValue(fieldViewModel: amountViewModel),
//              let foodNutrients
//        else {
//            return nil
//        }
//        return UserFoodInfo(
//            amount: amountFoodValue,
//            serving: FoodValue(fieldViewModel: servingViewModel),
//            nutrients: foodNutrients,
//            sizes: foodSizes,
//            density: foodDensity,
//            linkUrl: linkInfo?.urlString,
//            prefilledUrl: prefilledFood?.sourceUrl,
//            imageIds: imageViewModels.map { $0.id },
//            barcodes: foodBarcodes,
//            spawnedUserFoodId: nil,
//            spawnedDatabaseFoodId: nil,
//            userId: UUID(uuidString: "951917ab-594a-4424-88e5-012223e8dfaf")!
//        )
//    }
//    
//    var foodBarcodes: [FoodBarcode] {
//        barcodeViewModels.compactMap { $0.foodBarcode }
//    }
//    
//    var foodDensity: FoodDensity? {
//        densityViewModel.fieldValue.densityValue?.foodDensity
//    }
//    
//    var foodSizes: [FoodSize] {
//        allSizes.compactMap {
//            guard let quantity = $0.quantity,
//                  let value = $0.foodValue
//            else {
//                return nil
//            }
//            
//            return FoodSize(
//                name: $0.name,
//                volumePrefixExplicitUnit: $0.volumePrefixUnit?.volumeUnit?.volumeExplicitUnit,
//                quantity: quantity,
//                value: value
//            )
//        }
//    }
//    
//    var foodNutrients: FoodNutrients? {
//        guard let energy = energyViewModel.energyInKcal,
//              let carb = carbViewModel.macroDouble,
//              let fat = fatViewModel.macroDouble,
//              let protein = proteinViewModel.macroDouble
//        else {
//            return nil
//        }
//              
//        return FoodNutrients(
//            energyInKcal: energy,
//            carb: carb,
//            protein: protein,
//            fat: fat,
//            micros: foodNutrientsArray
//        )
//    }
//    
//    var foodNutrientsArray: [FoodNutrient] {
//        allIncludedMicronutrientFieldViewModels.compactMap {
//            let microValue = $0.fieldValue.microValue
//            guard let value = microValue.double else {
//                return nil
//            }
//            return FoodNutrient(
//                nutrientType: microValue.nutrientType,
//                value: value,
//                nutrientUnit: microValue.unit
//            )
//        }
//    }
//}
