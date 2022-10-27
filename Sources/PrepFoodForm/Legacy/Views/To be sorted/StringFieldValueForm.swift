import SwiftUI
import VisionSugar

struct StringFieldValueForm: View {
    
    @ObservedObject var existingFieldViewModel: Field
    @StateObject var fieldViewModel: Field
    
    init(existingFieldViewModel: Field) {
        self.existingFieldViewModel = existingFieldViewModel
        
        let fieldViewModel = existingFieldViewModel
        _fieldViewModel = StateObject(wrappedValue: fieldViewModel)
    }
    
    var body: some View {
        FieldValueForm(
            fieldViewModel: fieldViewModel,
            existingFieldViewModel: existingFieldViewModel
        )
    }
}
