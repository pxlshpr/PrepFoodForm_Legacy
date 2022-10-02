import SwiftUI
import PhotosUI
import FoodLabelScanner
import VisionSugar

class ImageViewModel: ObservableObject {
    
    @Published var status: ImageStatus
    @Published var image: UIImage? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil
    @Published var textsWithNumbers: [RecognizedText] = []
    var scanResult: ScanResult? = nil
    
    init(_ image: UIImage) {
        self.image = image
        self.status = .notClassified
        self.startClassifyTask(with: image)
//        self.status = .classified
    }

    init(photosPickerItem: PhotosPickerItem) {
        self.image = nil
        self.photosPickerItem = photosPickerItem
        self.status = .loading
        self.startLoadingTask(with: photosPickerItem)
    }
    
    /// Used for testing purposes to manually create an `ImageViewModel` with a preloaded `UIImage` and `ScanResult`
    init(image: UIImage, scanResult: ScanResult) {
        self.image = image
        self.status = .classified
        self.photosPickerItem = nil
        self.scanResult = scanResult
        
        let textsWithNumbers = scanResult.texts.filter { text in
            text.string.matchesRegex(#"(^|[ ]+)[0-9]+"#)
        }

        self.textsWithNumbers = textsWithNumbers
    }
    
    func startClassifyTask(with image: UIImage) {
        self.status = .classifying
        Task(priority: .userInitiated) {
            
//            try await taskSleep(Double.random(in: 1...6))
//            await MainActor.run {
//                self.status = .classified
//                FoodFormViewModel.shared.imageDidFinishClassifying(self)
//            }
            
            
            Task {
                let results = try await FoodLabelScanner(image: image).scan()
                
                self.scanResult = results
                
                //TODO: Move this to FoodLabelScanner
                let textsWithNumbers = scanResult?.texts.filter { text in
                    text.string.matchesRegex(#"(^|[ ]+)[0-9]+"#)
                } ?? []
                
                await MainActor.run {
                    self.status = .classified
                    self.textsWithNumbers = textsWithNumbers
                }
                FoodFormViewModel.shared.imageDidFinishClassifying(self)
            }
        }
    }
    
    func startLoadingTask(with item: PhotosPickerItem) {
        Task(priority: .userInitiated) {
            guard let image = try await loadImage(pickerItem: item) else {
                return
            }
            
            await MainActor.run {
                self.image = image
                self.status = .notClassified
                self.startClassifyTask(with: image)
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

