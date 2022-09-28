import SwiftUI
import PrepUnits
import NutritionLabelClassifier

extension FoodFormViewModel {
    func croppedImage(for fillType: FillType) async -> UIImage? {
        guard let outputId = fillType.outputId, let valueText = fillType.valueText,
              let image = image(for: outputId)
        else {
            return nil
        }
        
        return await valueText.croppedImage(from: image)
    }
    
    func image(for outputId: UUID) -> UIImage? {
        for imageViewModel in imageViewModels {
            if imageViewModel.output?.id == outputId {
                return imageViewModel.image
            }
        }
        return nil
    }
}

extension ValueText {
    
    var boundingBoxForCrop: CGRect {
        text.boundingBox
//        text.boundingBox.zoomedOutBoundingBox
    }
    
    func croppedImage(from image: UIImage) async -> UIImage {
        let cropRect = boundingBoxForCrop.rectForSize(image.size)
        let image = image.fixOrientationIfNeeded()
        return cropImage(imageToCrop: image, toRect: cropRect)
    }
    
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage {
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
}

extension CGRect {
    var zoomedOutBoundingBox: CGRect {
        let d = min(height, width)
        let x = max(0, minX-d)
        let y = max(0, minY-d)
        let width = min((maxX) + d, 1) - x
        let height = min((maxY) + d, 1) - y
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
