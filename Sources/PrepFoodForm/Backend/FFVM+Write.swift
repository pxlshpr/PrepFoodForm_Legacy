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

extension ImageViewModel {
    func writeImage(to directoryUrl: URL) async throws {
        guard let image else { return }
        let imageUrl = directoryUrl.appending(component: "\(id).jpg")
        
        let resized = resizeImage(image: image, targetSize: CGSize(width: 2048, height: 2048))
        guard let data = resized.jpegData(compressionQuality: 0.8) else { return }
        try data.write(to: imageUrl)
    }
}

import UIKit

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
