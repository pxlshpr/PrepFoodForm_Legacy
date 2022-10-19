import SwiftUI
import PhotosUI
import FoodLabelScanner
import VisionSugar
import ZoomableScrollView
import PrepUnits

class ImageViewModel: ObservableObject, Identifiable {
    
    @Published var status: ImageStatus
    @Published var image: UIImage? = nil
    
    @Published var mediumThumbnail: UIImage? = nil
    @Published var smallThumbnail: UIImage? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil
    
    var isProcessed: Bool = false
    var scanResult: ScanResult? = nil
    
    var texts: [RecognizedText] = []
    var textsWithFoodLabelValues: [RecognizedText] = []
    var textsWithoutFoodLabelValues: [RecognizedText] = []
    var textsWithDensities: [RecognizedText] = []

    var barcodeTexts: [RecognizedBarcode] = []

    @Published var id: UUID
    
//    extension ImageViewModel: Identifiable {
//        var id: UUID {
//            scanResult?.id ?? UUID()
//        }
//    }

    init(_ image: UIImage) {
        self.image = image
        self.status = .notScanned
        self.id = UUID()
        self.startScanTask(with: image)
        self.prepareThumbnails()
//        self.status = .scanned
    }

    init(photosPickerItem: PhotosPickerItem) {
        self.image = nil
        self.photosPickerItem = photosPickerItem
        self.status = .loading
        self.id = UUID()
        self.startLoadTask(with: photosPickerItem)
    }
    
    /// Create this with a preset `ScanResult` to skip the scanning process entirely
    init(image: UIImage, scanResult: ScanResult) {
        self.image = image
        self.status = .scanned
        self.photosPickerItem = nil
        self.scanResult = scanResult
        
        self.id = scanResult.id
        
        self.texts = scanResult.texts
        self.textsWithFoodLabelValues = scanResult.textsWithFoodLabelValues
        self.textsWithoutFoodLabelValues = scanResult.textsWithoutFoodLabelValues
        self.textsWithDensities = scanResult.textsWithDensities
        self.barcodeTexts = scanResult.barcodes

        self.prepareThumbnails()
    }
    
    func prepareThumbnails() {
        guard let image = image else { return }
        Task {
            let smallThumbnail = image.preparingThumbnail(of: CGSize(width: 165, height: 165))
            let mediumThumbnail = image.preparingThumbnail(of: CGSize(width: 360, height: 360))

            await MainActor.run {
                self.smallThumbnail = smallThumbnail
                self.mediumThumbnail = mediumThumbnail
            }
        }
    }

    func texts(for filter: TextPickerFilter) -> [RecognizedText] {
        switch filter {
        case .allTextsAndBarcodes, .allTexts:
            return texts
        case .textsWithDensities:
            return textsWithDensities
        case .textsWithFoodLabelValues:
            return textsWithFoodLabelValues
        case .textsWithoutFoodLabelValues:
            return textsWithoutFoodLabelValues
        case .textsInColumn1:
            //TODO: Extract column 1
            return texts
        case .textsInColumn2:
            //TODO: Extract column 2
            return texts
        }
    }
    
    func startScanTask(with image: UIImage) {
        self.status = .scanning
        Task(priority: .userInitiated) {
            
//            try await taskSleep(Double.random(in: 1...6))
//            await MainActor.run {
//                self.status = .scanned
//                FoodFormViewModel.shared.imageDidFinishScanning(self)
//            }
            
            //TODO: Why is this a task within a task?
            
            Task {
                let result = try await FoodLabelScanner(image: image).scan()
                
                self.scanResult = result
                self.id = result.id
                
                self.texts = result.texts
                self.textsWithFoodLabelValues = result.textsWithFoodLabelValues
                self.textsWithoutFoodLabelValues = result.textsWithoutFoodLabelValues
                self.textsWithDensities = result.textsWithDensities
                self.barcodeTexts = result.barcodes

                await MainActor.run {
                    self.status = .scanned
                }
                FoodFormViewModel.shared.imageDidFinishScanning(self)
            }
        }
    }
    
    func startLoadTask(with item: PhotosPickerItem) {
        Task(priority: .userInitiated) {
            guard let image = try await loadImage(pickerItem: item) else {
                return
            }
            
            await MainActor.run {
                self.image = image
                self.prepareThumbnails()
                self.status = .notScanned
                self.startScanTask(with: image)
                FoodFormViewModel.shared.imageDidFinishLoading(self)
            }
        }
    }
    
    func loadImage(pickerItem: PhotosPickerItem) async throws -> UIImage? {
        guard let data = try await pickerItem.loadTransferable(type: Data.self) else {
            return nil
//            throw PhotoPickerError.load
        }
        guard let image = UIImage(data: data) else {
            return nil
//            throw PhotoPickerError.image
        }
        return image
    }
    
    var relevantBoundingBox: CGRect {
        scanResult?.boundingBox ?? .zero
    }
}

extension ScanResult {
    var boundingBox: CGRect? {
        if let labelBoundingBox {
//            if let barcodesBoundingBox {
//                return labelBoundingBox.union(barcodesBoundingBox)
//            } else {
                return labelBoundingBox
//            }
        } else if let barcodesBoundingBox {
            return barcodesBoundingBox
        } else {
            return nil
        }
    }
    
    var labelBoundingBox: CGRect? {
        let allTexts = allTexts
        guard !allTexts.isEmpty else { return nil }
        return allTexts.boundingBox
    }
    
    var barcodesBoundingBox: CGRect? {
        guard !barcodes.isEmpty else { return nil }
        return barcodes
            .map { $0.boundingBox }
            .union
    }
}

extension ImageViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
//        hasher.combine(status)
        hasher.combine(photosPickerItem)
    }
}

extension ImageViewModel: Equatable {
    static func ==(lhs: ImageViewModel, rhs: ImageViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

func taskSleep(_ seconds: Double, tolerance: Int = 1) async throws {
    try await Task.sleep(
        until: .now + .seconds(seconds),
        tolerance: .seconds(tolerance),
        clock: .suspending
    )
}

