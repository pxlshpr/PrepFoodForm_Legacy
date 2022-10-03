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
    
    func cropFilledImage() {
        guard fieldValue.fillType.usesImage else {
            withAnimation {
                imageToDisplay = nil
                shouldShowImage = false
            }
            return
        }
        Task {
            guard let croppedImage = await FoodFormViewModel.shared.croppedImage(for: fieldValue.fillType) else {
                print("⚠️ Couldn't get cropped image for: \(self.fieldValue.description)")
                return
            }

            await MainActor.run {
                withAnimation {
                    print("✂️ Got cropped image for: \(self.fieldValue.description)")
                    self.imageToDisplay = croppedImage
                    self.shouldShowImage = true
                }
            }
        }
    }
}

