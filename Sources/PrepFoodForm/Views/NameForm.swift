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
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            didSelectImageTextsHandler: didSelectImageTextsHandler
        )
    }
    
    func didSelectImageTextsHandler(_ imageTexts: [ImageText]) {
        for imageText in imageTexts {
            fieldViewModel.fieldValue.stringValue.fill.appendImageText(imageText)
        }
    }
    
    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .name(let stringValue) = fieldValue,
              let fieldString = fieldValue.singlePrefillFieldString
        else {
            return
        }
        fieldViewModel.fieldValue.stringValue.fill.appendPrefillFieldString(fieldString)
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
    
    mutating func appendImageText(_ imageText: ImageText) {
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

extension Fill {
    mutating func appendPrefillFieldString(_ fieldString: PrefillFieldString) {
        let fieldStrings: [PrefillFieldString]
        if case .prefill(let info) = self {
            fieldStrings = info.fieldStrings + [fieldString]
        } else {
            /// ** Note: ** This is now converting a possible `.scanned` Fill into a `.selection` one
            fieldStrings = [fieldString]
        }
        
        self = .prefill(.init(fieldStrings: fieldStrings))
    }
    
    mutating func removePrefillFieldString(_ fieldString: PrefillFieldString) {
        guard case .prefill(let info) = self else {
            return
        }
        var newInfo = info
        newInfo.fieldStrings.removeAll(where: { $0 == fieldString })
        self = .prefill(newInfo)
    }
}
