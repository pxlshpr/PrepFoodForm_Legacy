import SwiftUI
import PrepUnits

struct MacronutrientForm: View {
    
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
    @StateObject var formViewModel: FieldValueViewModel
    
    init(fieldValueViewModel: FieldValueViewModel) {
        self.fieldValueViewModel = fieldValueViewModel
        
        let formViewModel = fieldValueViewModel.copy
        _formViewModel = StateObject(wrappedValue: formViewModel)
    }

    
    var body: some View {
        FieldValueForm(
            formViewModel: formViewModel,
            fieldValueViewModel: fieldValueViewModel,
            unitView: unit,
            setNewValue: setNewValue
        )
    }
    
    var unit: some View {
        Text(formViewModel.fieldValue.macroValue.unitDescription)
            .foregroundColor(.secondary)
            .font(.title3)
        
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        formViewModel.fieldValue.macroValue.string = value.amount.cleanAmount
    }
}
