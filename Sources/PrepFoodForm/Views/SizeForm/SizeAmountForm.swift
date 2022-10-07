import SwiftUI
import SwiftHaptics

struct SizeAmountForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var formViewModel: SizeFormViewModel
    @ObservedObject var sizeViewModel: FieldValueViewModel
    
    @Environment(\.dismiss) var dismiss
    @State var showingUnitPicker = false
    @State var showingSizeForm = false
    @FocusState var isFocused: Bool
}

extension SizeAmountForm {
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
            pickedUnit: sizeViewModel.sizeAmountUnit,
            includeServing: formViewModel.includeServing,
            servingDescription: viewModel.servingDescription,
            allowAddSize: formViewModel.allowAddSize)
        {
            showingSizeForm = true
        } didPickUnit: { unit in
            sizeViewModel.sizeAmountUnit = unit
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showingSizeForm) {
            Color.red
            SizeForm(includeServing: viewModel.hasServing, allowAddSize: false) { sizeViewModel in
                guard let size = sizeViewModel.size else { return }
                withAnimation {
                    self.sizeViewModel.sizeAmountUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
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
    
    var textField: some View {
        TextField("Required", text: $sizeViewModel.sizeAmountString)
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
                Text(sizeViewModel.sizeAmountUnitString)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var header: some View {
        Text(sizeViewModel.sizeAmountUnit.unitType.description.lowercased())
    }
    
    @ViewBuilder
    var footer: some View {
        Text("\(sizeViewModel.sizeAmountIsValid ? "This is" : "Enter") \(description).")
            .foregroundColor(!sizeViewModel.sizeAmountIsValid ? FormFooterEmptyColor : FormFooterFilledColor)
    }
    
    //MARK: - Helpers
    
    var quantiativeName: String {
        "\(sizeViewModel.sizeQuantityString) \(sizeViewModel.sizeNameString.isEmpty ? "of this size" : sizeViewModel.sizeNameString.lowercased())"
    }
    
    var description: String {
        switch sizeViewModel.sizeAmountUnit {
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
