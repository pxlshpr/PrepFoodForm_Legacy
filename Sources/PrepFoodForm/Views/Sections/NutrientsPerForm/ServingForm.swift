import SwiftUI
import SwiftHaptics

struct ServingForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingUnitPicker = false
    @State var showingSizeForm = false
    @FocusState var isFocused
}

extension ServingForm {
    
    var body: some View {
        form
            .navigationTitle("Serving Size")
            .onAppear {
                isFocused = true
            }
            .toolbar { keyboardToolbarContents }
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("Units") {
                showingUnitPicker = true
            }
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
    }
    
    var form: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack(spacing: 0) {
                    textField
                    unitButton
                }
            }
        }
        .sheet(isPresented: $showingUnitPicker) {
            UnitPicker(
                pickedUnit: viewModel.servingViewModel.fieldValue.doubleValue.unit,
                includeServing: false)
            {
                showingSizeForm = true
            } didPickUnit: { unit in
                withAnimation {
                    if unit.isServingBased {
                        viewModel.modifyServingAmount(for: unit)
                    }
                    viewModel.servingViewModel.fieldValue.doubleValue.unit = unit
                }
            }
            .environmentObject(viewModel)
            .sheet(isPresented: $showingSizeForm) {
                SizeForm(includeServing: true, allowAddSize: false) { sizeViewModel in
                    guard let size = sizeViewModel.size else { return }
                    withAnimation {
                        viewModel.servingViewModel.fieldValue.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            Haptics.feedback(style: .rigid)
                            showingUnitPicker = false
                        }
                    }
                }
                .environmentObject(viewModel)
            }
        }
    }
    
    var textField: some View {
        TextField("", text: $viewModel.servingViewModel.fieldValue.doubleValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .placeholder(when: viewModel.servingViewModel.fieldValue.isEmpty) {
                Text("Optional").foregroundColor(Color(.quaternaryLabel))
            }
            .focused($isFocused)
    }
    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.servingUnitShortString)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var header: some View {
        Text(viewModel.servingFormHeaderString)
    }

    @ViewBuilder
    var footer: some View {
        Text(viewModel.servingSizeFooterString)
            .foregroundColor(viewModel.servingViewModel.fieldValue.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
}
