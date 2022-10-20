import Foundation
import MFPScraper
import VisionSugar
import FoodLabelScanner

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

struct FoodViewModel: Codable {

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
    
    func writeToFile() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)

        if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url.appendPathComponent("foodViewModel.json")
            try data.write(to: url)
            print("📝 Wrote scanResult to: \(url)")
        }
    }
}

extension FoodFormViewModel {
    var foodViewModel: FoodViewModel {
        FoodViewModel(self)
    }
}
