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

extension FoodFormRawData {

    var createForm: UserFoodCreateForm? {
        guard let info = userFoodInfo else {
            return nil
        }
        return UserFoodCreateForm(
            name: name.string,
            emoji: emoji.string,
            detail: detail?.string,
            brand: brand?.string,
            status: .notPublished,
            info: info
        )
    }
    
    var userFoodInfo: UserFoodInfo? {
        guard let amountFoodValue = FoodValue(fieldValue: amount),
              let foodNutrients
        else {
            return nil
        }
        let servingFoodValue: FoodValue?
        if let serving {
            servingFoodValue = FoodValue(fieldValue: serving)
        } else {
            servingFoodValue = nil
        }
        return UserFoodInfo(
            amount: amountFoodValue,
            serving: servingFoodValue,
            nutrients: foodNutrients,
            sizes: foodSizes,
            density: foodDensity,
            linkUrl: link,
            prefilledUrl: prefilledFood?.sourceUrl,
            imageIds: images.map { $0.id },
            barcodes: foodBarcodes,
            spawnedUserFoodId: nil,
            spawnedDatabaseFoodId: nil,
            userId: UUID(uuidString: "951917ab-594a-4424-88e5-012223e8dfaf")!
        )
    }
    
    var foodBarcodes: [FoodBarcode] {
        barcodes.compactMap { $0.foodBarcode }
    }
    
    var foodDensity: FoodDensity? {
        density?.densityValue?.foodDensity
    }
    
    var foodSizes: [FoodSize] {
        sizes.compactMap({ $0.size }).compactMap {
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
        guard let energy = energy.energyInKcal,
              let carb = carb.macroDouble,
              let fat = fat.macroDouble,
              let protein = protein.macroDouble
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
        micronutrients.compactMap {
            let microValue = $0.microValue
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
