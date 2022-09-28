import SwiftUI
import PhotosUI
import NutritionLabelClassifier

class ImageViewModel: ObservableObject {
    
    @Published var status: ImageStatus
    @Published var image: UIImage? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil
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
                
                Task {
                    await MainActor.run {
                        self.status = .classified
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

