import SwiftUI

class FieldValueViewModel: ObservableObject {
    @Published var showingImageTextPicker: Bool = false
    @Published var ignoreNextChange: Bool = false
    @Published var imageToDisplay: UIImage? = nil
    @Published var shouldShowImage: Bool = false

    @Published var fieldValue: FieldValue
    
    init(fieldValue: FieldValue) {
        self.fieldValue = fieldValue
    }
    
    func getCroppedImage(for fillType: FillType) {
        guard fillType.usesImage else {
            withAnimation {
                imageToDisplay = nil
                shouldShowImage = false
            }
            return
        }
        Task {
            let croppedImage = await FoodFormViewModel.shared.croppedImage(for: fillType)

            await MainActor.run {
                withAnimation {
                    self.imageToDisplay = croppedImage
                    self.shouldShowImage = true
                }
            }
        }
    }
}

