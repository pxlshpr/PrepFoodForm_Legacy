import SwiftUI
import SwiftHaptics

extension FoodForm.NutrientsPerForm {
    struct ServingForm: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var viewModel: FoodFormViewModel
        @State var showingUnitPicker = false
        @State var showingSizeForm = false
        @FocusState var isFocused
    }
}

extension FoodForm.NutrientsPerForm.ServingForm {
    
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
                pickedUnit: viewModel.serving.unit,
                includeServing: false)
            {
                showingSizeForm = true
            } didPickUnit: { unit in
                withAnimation {
                    if unit.isServingBased {
                        viewModel.modifyServingAmount(for: unit)
                    }
                    viewModel.serving.unit = unit
                }
            }
            .environmentObject(viewModel)
            .sheet(isPresented: $showingSizeForm) {
                SizeForm(includeServing: true, allowAddSize: false) { size in
                    withAnimation {
                        viewModel.serving.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            Haptics.feedback(style: .rigid)
                            showingUnitPicker = false
                        }
                    }
                }
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
        }
    }
    
    var textField: some View {
        TextField("", text: $viewModel.serving.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .placeholder(when: viewModel.serving.isEmpty) {
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
            .foregroundColor(viewModel.serving.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
}
