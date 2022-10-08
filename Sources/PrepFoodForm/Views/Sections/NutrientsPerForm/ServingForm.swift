import SwiftUI
import PrepUnits
import SwiftHaptics

struct ServingForm: View {
    
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
            headerString: headerString,
            footerString: footerString,
            placeholderString: "Optional",
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
            if unit.isServingBased {
                modifyServingAmount(for: unit)
            }
            fieldViewModel.fieldValue.doubleValue.unit = unit
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
    }
    
    func modifyServingAmount(for unit: FormUnit) {
        guard fieldViewModel.fieldValue.doubleValue.unit.isServingBased,
              case .size(let size, _) = fieldViewModel.fieldValue.doubleValue.unit
        else {
            return
        }
        let newAmount: Double
        if let quantity = size.quantity,
           let servingAmount = fieldViewModel.fieldValue.doubleValue.double, servingAmount > 0
        {
            newAmount = quantity / servingAmount
        } else {
            newAmount = 0
        }
        
        //TODO-SIZE: We need to get access to it here—possibly need to add it to sizes to begin with so that we can modify it here
//        size.amountDouble = newAmount
//        updateSummary()
    }

    var addSizeForm: some View {
        SizeForm(includeServing: true, allowAddSize: false) { sizeViewModel in
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
        fieldViewModel.fieldValue.doubleValue.unit = value.unit?.formUnit ?? .weight(.g)
    }
    
    var headerString: String {
        switch fieldViewModel.fieldValue.doubleValue.unit {
        case .weight:
            return "Weight"
        case .volume:
            return "Volume"
        case .size:
            return "Size"
        default:
            return ""
        }
    }

    var footerString: String {
        switch fieldViewModel.fieldValue.doubleValue.unit {
        case .weight:
            return "This is the weight of 1 serving. Enter this to log this food using its weight in addition to servings."
        case .volume:
            return "This is the volume of 1 serving. Enter this to log this food using its volume in addition to servings."
        case .size(let size, _):
            return "This is how many \(size.prefixedName) is 1 serving."
        case .serving:
            return "Unsupported"
        }
        
    }
}
