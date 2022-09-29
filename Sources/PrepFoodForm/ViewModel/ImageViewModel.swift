import SwiftUI
import PhotosUI
import NutritionLabelClassifier
import VisionSugar

class ImageViewModel: ObservableObject {
    
    @Published var status: ImageStatus
    @Published var image: UIImage? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil
    @Published var textsWithNumbers: [RecognizedText] = []
    var output: Output? = nil
    
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
    
    /// Used for testing purposes to manually create an `ImageViewModel` with a preloaded `UIImage` and `Output`
    init(image: UIImage, output: Output) {
        self.image = image
        self.status = .classified
        self.photosPickerItem = nil
        self.output = output
        
        let textsWithNumbers = output.texts.accurate.filter { text in
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
            
            NutritionLabelClassifier(image: image, contentSize: image.size).classify { output in
                self.output = output
                
                let textsWithNumbers = output?.texts.accurate.filter { text in
                    text.string.matchesRegex(#"(^|[ ]+)[0-9]+"#)
                } ?? []
                
                Task {
                    await MainActor.run {
                        self.status = .classified
                        self.textsWithNumbers = textsWithNumbers
                        FoodFormViewModel.shared.imageDidFinishClassifying(self)
                    }
                }
            }
        }
    }
    
    func startLoadingTask(with item: PhotosPickerItem) {
        //TODO: Load the image here too once picked from photo picker
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

