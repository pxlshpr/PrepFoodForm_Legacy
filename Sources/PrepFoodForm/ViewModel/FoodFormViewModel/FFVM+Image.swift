import SwiftUI
import PrepUnits
import NutritionLabelClassifier
import PhotosUI

extension FoodFormViewModel {
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        
        sourceType = .images
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item)
            imageViewModels.append(imageViewModel)
        }
    }

    func croppedImage(for fillType: FillType) async -> UIImage? {
        guard let outputId = fillType.outputId,
              let recognizedText = fillType.text,
              let image = image(for: outputId)
        else {
            return nil
        }
        
        return await recognizedText.croppedImage(from: image)
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
import VisionSugar

extension RecognizedText {

    func croppedImage(from image: UIImage) async -> UIImage? {
        let cropRect = boundingBox.rectForSize(image.size)
        let image = image.fixOrientationIfNeeded()
        return cropImage(imageToCrop: image, toRect: cropRect)
    }
    
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage? {
        guard let imageRef = imageToCrop.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
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
