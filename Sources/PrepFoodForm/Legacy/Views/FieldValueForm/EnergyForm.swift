import SwiftUI
import PrepDataTypes

struct EnergyForm: View {
    
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
            unitView: unitPicker,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
    }
    
    var unitPicker: some View {
        return Picker("", selection: $fieldViewModel.value.energyValue.unit) {
            ForEach(EnergyUnit.allCases, id: \.self) {
                unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)
        
    }
    
    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .energy(let energyValue) = fieldValue else {
            return
        }
        fieldViewModel.value.energyValue = energyValue
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.value.energyValue.string = value.amount.cleanAmount
        if let unit = value.unit, unit.isEnergy {
            fieldViewModel.value.energyValue.unit = unit.energyUnit
        } else {
            fieldViewModel.value.energyValue.unit = .kcal
        }
    }
}
