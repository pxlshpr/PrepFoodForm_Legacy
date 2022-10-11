import SwiftUI
import PrepUnits

struct MacroForm: View {
    
    @ObservedObject var existingFieldViewModel: FieldViewModel
    @StateObject var fieldViewModel: FieldViewModel
    
    init(existingFieldViewModel: FieldViewModel) {
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
        Text(fieldViewModel.fieldValue.macroValue.unitDescription)
            .foregroundColor(.secondary)
            .font(.title3)
        
    }
    
    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .macro(let macroValue) = fieldValue else {
            return
        }
        fieldViewModel.fieldValue.macroValue = macroValue
    }

    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.fieldValue.macroValue.string = value.amount.cleanAmount
    }
}
