import SwiftUI
import PhotosUI
import FoodLabelScanner
import VisionSugar
import ZoomableScrollView
import PrepUnits
import PrepNetworkController

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

    var recognizedBarcodes: [RecognizedBarcode] = []

    var id: UUID
    
    var uploadStatus: UploadStatus = .notUploaded

    init(_ image: UIImage) {
        self.image = image
        self.status = .notScanned
        self.id = UUID()
        self.startScanTask(with: image)
        
        self.prepareThumbnails()
        self.startUploadTask()
    }

    init(barcodeImage image: UIImage, recognizedBarcodes: [RecognizedBarcode]) {
        self.image = image
        self.status = .scanned
        self.id = UUID()
        self.recognizedBarcodes = recognizedBarcodes
        
        self.prepareThumbnails()
        self.startUploadTask()
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
        self.recognizedBarcodes = scanResult.barcodes

        self.prepareThumbnails()
        self.startUploadTask()
    }
    
    var dataPointsCount: Int {
        scanResult?.dataPointsCount ?? recognizedBarcodes.count
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
    
    func startUploadTask() {
        Task {
            uploadStatus = .uploading
            guard let imageData,
                  let request = NetworkController.shared.postRequest(forImageData: imageData, imageId: id)
            else {
                print("🌐 Couldn't get request")
                return
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            print("🌐 Here's the response:")
            print("🌐 \(response)")
        }
    }

    var imageData: Data? {
        guard let image else { return nil }
        let resized = resizeImage(image: image, targetSize: CGSize(width: 2048, height: 2048))
        return resized.jpegData(compressionQuality: 0.8)
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
                self.recognizedBarcodes = result.barcodes

                await MainActor.run {
                    self.status = .scanned
                }
                FoodFormViewModel.shared.imageDidFinishScanning(self)
            }
        }
    }
    
    var statusSystemImage: String? {
        guard status == .scanned else { return nil }
        return scanResult != nil ? "text.viewfinder" : "barcode.viewfinder"
    }
    
    func startLoadTask(with item: PhotosPickerItem) {
        Task(priority: .userInitiated) {
            guard let image = try await loadImage(pickerItem: item) else {
                return
            }
            
            await MainActor.run {
                self.image = image
                
                self.prepareThumbnails()
                self.startUploadTask()
                
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
