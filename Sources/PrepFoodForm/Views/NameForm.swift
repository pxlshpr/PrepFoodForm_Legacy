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
            tappedText: tappedText
        )
    }
    
    func tappedText(_ text: RecognizedText, imageId: UUID) {
        fieldViewModel.fieldValue.stringValue.fillType.appendSelectedText(text)
    }
    
    func didSave() {
        
    }
}

extension Fill {
    mutating func appendSelectedText(_ text: RecognizedText) {
        let newSupplementaryTexts: [RecognizedText]
        if case .imageSelection(let recognizedText, let scanResultId, let supplementaryTexts, let value) = self {
            newSupplementaryTexts = supplementaryTexts + [text]
        } else {
            newSupplementaryTexts = [text]
        }
        
        self = .imageSelection(
            recognizedText: text,
            scanResultId: defaultUUID,
            supplementaryTexts: newSupplementaryTexts,
            value: value)
    }
}

extension Array where Element == RecognizedText {
    var concatenatedString: String {
        map{ $0.string.capitalized }.joined(separator: " ")
    }
}
