import SwiftUI
import PrepUnits

struct MicronutrientForm: View {
    
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
            unitView: unitPicker,
            setNewValue: setNewValue
        )
    }
    
    @ViewBuilder
    var unitPicker: some View {
        if supportedUnits.count > 1 {
            Picker("", selection: $formViewModel.fieldValue.microValue.nutrientType) {
                ForEach(supportedUnits, id: \.self) { unit in
                    Text(unit.shortDescription).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        } else {
            Text(formViewModel.fieldValue.microValue.unitDescription)
                .foregroundColor(.secondary)
                .font(.title3)
        }
    }

    func setNewValue(_ value: FoodLabelValue) {
        formViewModel.fieldValue.microValue.string = value.amount.cleanAmount
        if let unit = value.unit?.nutrientUnit, supportedUnits.contains(unit) {
            formViewModel.fieldValue.microValue.unit = unit
        } else {
            formViewModel.fieldValue.microValue.unit = defaultUnit
        }
    }

    var supportedUnits: [NutrientUnit] {
        fieldValueViewModel.fieldValue.microValue.supportedNutrientUnits
    }
    
    var defaultUnit: NutrientUnit {
        supportedUnits.first ?? .g
    }
}
