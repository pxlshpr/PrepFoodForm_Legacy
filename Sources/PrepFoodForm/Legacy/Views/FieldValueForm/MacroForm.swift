import SwiftUI
import PrepDataTypes

struct MacroForm: View {
    
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
            existingFieldViewModel: existingFieldViewModel,
            unitView: unit,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
    }
    
    var unit: some View {
        Text(fieldViewModel.value.macroValue.unitDescription)
            .foregroundColor(.secondary)
            .font(.title3)
        
    }
    
    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .macro(let macroValue) = fieldValue else {
            return
        }
        fieldViewModel.value.macroValue = macroValue
    }

    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.value.macroValue.string = value.amount.cleanAmount
    }
}
