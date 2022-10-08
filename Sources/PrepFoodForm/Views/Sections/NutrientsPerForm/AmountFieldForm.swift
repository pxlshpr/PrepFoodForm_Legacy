import SwiftUI
import PrepUnits
import SwiftHaptics

struct AmountFieldForm: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @ObservedObject var existingFieldViewModel: FieldViewModel
    @StateObject var fieldViewModel: FieldViewModel

    @State var showingUnitPicker = false
    @State var showingAddSizeForm = false

    init(existingFieldViewModel: FieldViewModel) {
        self.existingFieldViewModel = existingFieldViewModel
        
        let fieldViewModel = existingFieldViewModel.copy
        _fieldViewModel = StateObject(wrappedValue: fieldViewModel)
    }

    
    var body: some View {
        FieldValueForm(
            fieldViewModel: fieldViewModel,
            existingFieldViewModel: existingFieldViewModel,
            unitView: unitButton,
            setNewValue: setNewValue
        )
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
    }
    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(fieldViewModel.fieldValue.doubleValue.unit.shortDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var unitPicker: some View {
        UnitPicker(
            pickedUnit: fieldViewModel.fieldValue.doubleValue.unit
        ) {
            showingAddSizeForm = true
        } didPickUnit: { unit in
            fieldViewModel.fieldValue.doubleValue.unit = unit
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
    }

    var addSizeForm: some View {
        SizeForm(includeServing: false, allowAddSize: false) { sizeViewModel in
            guard let size = sizeViewModel.size else { return }
            fieldViewModel.fieldValue.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Haptics.feedback(style: .rigid)
                showingUnitPicker = false
            }
        }
        .environmentObject(viewModel)
    }

    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.fieldValue.doubleValue.double = value.amount
        fieldViewModel.fieldValue.doubleValue.unit = value.unit?.formUnit ?? .serving
    }
}
