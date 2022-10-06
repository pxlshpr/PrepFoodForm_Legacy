import SwiftUI
import PrepUnits

struct EnergyForm: View {
    
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
    
    var unitPicker: some View {
        Picker("", selection: $formViewModel.fieldValue.energyValue.unit) {
            ForEach(EnergyUnit.allCases, id: \.self) {
                unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)
        
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        formViewModel.fieldValue.energyValue.string = value.amount.cleanAmount
        formViewModel.fieldValue.energyValue.unit = value.unit?.energyUnit ?? .kcal
    }
}

//MARK: - Preview

struct EnergyFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        EnergyForm(fieldValueViewModel: viewModel.energyViewModel)
            .environmentObject(viewModel)
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        EnergyFormPreview()
    }
}
