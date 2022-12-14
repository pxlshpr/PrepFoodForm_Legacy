//import SwiftUI
//import PrepDataTypes
//import SwiftHaptics
//
//struct AmountForm: View {
//    
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    
//    @ObservedObject var existingFieldViewModel: Field
//    @StateObject var fieldViewModel: Field
//
//    @State var showingUnitPicker = false
//    @State var showingAddSizeForm = false
//
//    init(existingFieldViewModel: Field) {
//        self.existingFieldViewModel = existingFieldViewModel
//        
//        let fieldViewModel = existingFieldViewModel
//        _fieldViewModel = StateObject(wrappedValue: fieldViewModel)
//    }
//
//    
//    var body: some View {
//        FieldValueForm(
//            fieldViewModel: fieldViewModel,
//            existingFieldViewModel: existingFieldViewModel,
//            unitView: unitButton,
//            footerString: footerString,
//            titleString: headerString,
//            didSave: didSave,
//            tappedPrefillFieldValue: tappedPrefillFieldValue,
//            setNewValue: setNewValue
//        )
//        .sheet(isPresented: $showingUnitPicker) { unitPicker }
//    }
//    
//    var unitButton: some View {
//        Button {
//            showingUnitPicker = true
//        } label: {
//            HStack(spacing: 5) {
//                Text(fieldViewModel.value.doubleValue.unit.shortDescription)
//                Image(systemName: "chevron.up.chevron.down")
//                    .imageScale(.small)
//            }
//        }
//        .buttonStyle(.borderless)
//    }
//
//    var unitPicker: some View {
//        UnitPicker(
//            pickedUnit: fieldViewModel.value.doubleValue.unit
//        ) {
//            showingAddSizeForm = true
//        } didPickUnit: { unit in
//            setUnit(unit)
//        }
//        .environmentObject(viewModel)
//        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
//    }
//
//    var addSizeForm: some View {
//        SizeForm(includeServing: false, allowAddSize: false) { sizeViewModel in
//            guard let size = sizeViewModel.size else { return }
//            fieldViewModel.value.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                Haptics.feedback(style: .rigid)
//                showingUnitPicker = false
//            }
//        }
//        .environmentObject(viewModel)
//    }
//
//    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
//        switch fieldValue {
//        case .amount(let doubleValue):
//            guard let double = doubleValue.double else {
//                return
//            }
//            setAmount(double)
//            setUnit(doubleValue.unit)
//        default:
//            return
//        }
//    }
//
//    func setNewValue(_ value: FoodLabelValue) {
//        setAmount(value.amount)
//        setUnit(value.unit?.formUnit ?? .serving)
//    }
//    
//    func setAmount(_ amount: Double) {
//        fieldViewModel.value.doubleValue.double = amount
//    }
//    
//    func didSave() {
//        viewModel.amountChanged()
//    }
//    
//    func setUnit(_ unit: FormUnit) {
//        fieldViewModel.value.doubleValue.unit = unit
//    }
//    
//    var headerString: String {
//        switch fieldViewModel.value.doubleValue.unit {
//        case .serving:
//            return "Servings"
//        case .weight:
//            return "Weight"
//        case .volume:
//            return "Volume"
//        case .size:
//            return "Size"
//        }
//    }
//
//    var footerString: String {
//        "This is how much of this food the nutrition facts are for. You'll be able to log this food using the unit you choose."
//    }
//}
