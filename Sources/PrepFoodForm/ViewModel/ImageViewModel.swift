import SwiftUI
import PhotosUI
import FoodLabelScanner
import VisionSugar
import ZoomableScrollView
import PrepUnits

extension RecognizedText {
    
    /**
     Returns the first detected `FoodLabelValue` in the string and all its candidates, if present.
     */
    var firstFoodLabelValue: FoodLabelValue? {
        string.detectedValues.first ?? (candidates.first(where: { !$0.detectedValues.isEmpty }))?.detectedValues.first
    }
    
    /**
     Returns true if the string or any of the other candidates contains `FoodLabelValues` in them.
     */
    var hasFoodLabelValues: Bool {
        !string.detectedValues.isEmpty
        || candidates.contains(where: { !$0.detectedValues.isEmpty })
    }
}
class ImageViewModel: ObservableObject {
    
    @Published var status: ImageStatus
    @Published var image: UIImage? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil
    
    var scanResult: ScanResult? = nil
    var texts: [RecognizedText] = []
    var textsWithValues: [RecognizedText] = []

    init(_ image: UIImage) {
        self.image = image
        self.status = .notScanned
        self.startScanTask(with: image)
//        self.status = .scanned
    }

    init(photosPickerItem: PhotosPickerItem) {
        self.image = nil
        self.photosPickerItem = photosPickerItem
        self.status = .loading
        self.startLoadTask(with: photosPickerItem)
    }
    
    /// Used for testing purposes to manually create an `ImageViewModel` with a preloaded `UIImage` and `ScanResult`
    init(image: UIImage, scanResult: ScanResult) {
        self.image = image
        self.status = .scanned
        self.photosPickerItem = nil
        self.scanResult = scanResult
        self.texts = scanResult.texts
        self.textsWithValues = scanResult.texts.filter({ $0.hasFoodLabelValues })
    }
    
    func startScanTask(with image: UIImage) {
        self.status = .scanning
        Task(priority: .userInitiated) {
            
//            try await taskSleep(Double.random(in: 1...6))
//            await MainActor.run {
//                self.status = .scanned
//                FoodFormViewModel.shared.imageDidFinishScanning(self)
//            }
            
            
            Task {
                let result = try await FoodLabelScanner(image: image).scan()
                
                self.scanResult = result
                self.texts = result.texts
                self.textsWithValues = result.texts.filter({ !$0.string.detectedValues.isEmpty })
                
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

