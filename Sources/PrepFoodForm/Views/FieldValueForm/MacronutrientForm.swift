import SwiftUI
import PrepUnits

struct MacronutrientForm: View {
    
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
            unitView: unit,
            setNewValue: setNewValue
        )
    }
    
    var unit: some View {
        Text(fieldViewModel.fieldValue.macroValue.unitDescription)
            .foregroundColor(.secondary)
            .font(.title3)
        
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.fieldValue.macroValue.string = value.amount.cleanAmount
    }
}
