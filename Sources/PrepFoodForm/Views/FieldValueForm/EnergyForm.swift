import SwiftUI
import PrepUnits

struct EnergyForm: View {
    
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
            unitView: unitPicker,
            setNewValue: setNewValue
        )
    }
    
    var unitPicker: some View {
        Picker("", selection: $fieldViewModel.fieldValue.energyValue.unit) {
            ForEach(EnergyUnit.allCases, id: \.self) {
                unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)
        
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.fieldValue.energyValue.string = value.amount.cleanAmount
        if let unit = value.unit, unit.isEnergy {
            fieldViewModel.fieldValue.energyValue.unit = unit.energyUnit
        } else {
            fieldViewModel.fieldValue.energyValue.unit = .kcal
        }
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
        EnergyForm(existingFieldViewModel: viewModel.energyViewModel)
            .environmentObject(viewModel)
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        EnergyFormPreview()
    }
}
