import SwiftUI
import SwiftHaptics

extension SizeField {
    struct AmountForm: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var viewModel: FoodFormViewModel
        @EnvironmentObject var sizeFormViewModel: SizeFormViewModel
        @State var showingUnitPicker = false
        @State var showingSizeForm = false
        @FocusState var isFocused: Bool
    }
}

extension SizeField.AmountForm {
    var body: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack {
                    textField
                    unitButton
                }
            }
        }
        .navigationTitle("Amount")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingUnitPicker) {
            unitPickerForAmount
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            isFocused = true
        }
        .toolbar { keyboardToolbarContents }
    }
    
    //MARK: - Components
    
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

    var unitPickerForAmount: some View {
        UnitPicker(
            pickedUnit: sizeFormViewModel.amountUnit,
            includeServing: sizeFormViewModel.includeServing,
            servingDescription: viewModel.servingDescription,
            allowAddSize: sizeFormViewModel.allowAddSize)
        {
            showingSizeForm = true
        } didPickUnit: { unit in
            sizeFormViewModel.amountUnit = unit
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showingSizeForm) {
            SizeForm(includeServing: viewModel.hasServing, allowAddSize: false) { size in
                withAnimation {
                    sizeFormViewModel.amountUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        Haptics.feedback(style: .rigid)
                        showingUnitPicker = false
                    }
                }
            }
            .environmentObject(sizeFormViewModel)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
    
    var textField: some View {
        TextField("Required", text: $sizeFormViewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
    }
    
    var unitButton: some View {
        Button {
//            sizeFormViewModel.path.append(.amountUnit)
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(sizeFormViewModel.amountUnit.shortDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var header: some View {
        Text(sizeFormViewModel.amountUnit.unitType.description.lowercased())
    }
    
    @ViewBuilder
    var footer: some View {
        Text("\(sizeFormViewModel.amountIsValid ? "This is" : "Enter") \(description).")
            .foregroundColor(!sizeFormViewModel.amountIsValid ? FormFooterEmptyColor : FormFooterFilledColor)
    }
    
    //MARK: - Helpers
    
    var quantiativeName: String {
        "\(sizeFormViewModel.quantityString) \(sizeFormViewModel.name.isEmpty ? "of this size" : sizeFormViewModel.name.lowercased())"
    }
    
    var description: String {
        switch sizeFormViewModel.amountUnit {
        case .volume:
            return "the volume of \(quantiativeName)"
        case .weight:
            return "how much \(quantiativeName) weighs"
        case .serving:
            return "how many servings \(quantiativeName) equals"
        case .size(let size, _):
            //TODO: prefix name here with volumePrefixUnit
            return "how many \(size.prefixedName) \(quantiativeName) equals"
        }
    }
}
