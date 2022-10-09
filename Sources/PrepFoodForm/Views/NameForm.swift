import SwiftUI
import VisionSugar

struct NameForm: View {
    
    @ObservedObject var existingFieldViewModel: FieldViewModel
    @StateObject var fieldViewModel: FieldViewModel
    
    init(existingFieldViewModel: FieldViewModel) {
        self.existingFieldViewModel = existingFieldViewModel
        
        let fieldViewModel = existingFieldViewModel.copy
        _fieldViewModel = StateObject(wrappedValue: fieldViewModel)
    }
    
    var body: some View {
        FieldValueForm(
            fieldViewModel: fieldViewModel,
            existingFieldViewModel: existingFieldViewModel,
            didSave: didSave,
            didSelectImageTextsHandler: didSelectImageTextsHandler
        )
    }
    
    func didSelectImageTextsHandler(_ imageTexts: [ImageText]) {
        for imageText in imageTexts {
            fieldViewModel.fieldValue.stringValue.fill.appendSelectedText(imageText.text, on: imageText.imageId)
        }
    }
    
    func didSave() {
        
    }
}

extension Fill {
    mutating func removeImageText(_ imageText: ImageText) {
        guard case .selection(let info) = self else {
            return
        }
        var newInfo = info
        newInfo.imageTexts.removeAll(where: { $0 == imageText })
        self = .selection(newInfo)
    }
    
    mutating func appendSelectedText(_ text: RecognizedText, on imageId: UUID) {
        let imageText = ImageText(text: text, imageId: imageId)
        let imageTexts: [ImageText]
        if case .selection(let info) = self {
            imageTexts = info.imageTexts + [imageText]
        } else {
            /// ** Note: ** This is now converting a possible `.scanned` Fill into a `.selection` one
            imageTexts = [imageText]
        }
        
        self = .selection(.init(imageTexts: imageTexts))
    }
}
