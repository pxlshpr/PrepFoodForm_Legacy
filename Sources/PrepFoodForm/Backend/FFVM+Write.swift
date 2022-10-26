import SwiftUI
import MFPScraper
import VisionSugar
import FoodLabelScanner
import PrepDataTypes
import PrepNetworkController

extension FieldViewModel {
    var string: String {
        fieldValue.string
    }
    
    var stringIfNotEmpty: String? {
        string.isEmpty ? nil : string
    }
}
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
