import SwiftUI
import SwiftHaptics
import SwiftUISugar

public struct AmountForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    let existingAmountViewModel: FieldValueViewModel
    
    /// This stores a copy of the data from fieldValueViewModel until we're ready to persist the change
    @StateObject var amountViewModel: FieldValueViewModel

    @State var showingUnitPicker = false
    @State var showingAddSizeForm = false
    @FocusState var isFocused
    
    @State var doNotRegisterUserInput: Bool
    @State var hasBecomeFirstResponder: Bool = false
    @State var refreshBool = false

    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
    @State var shouldAnimateOptions = false

    init(amountViewModel: FieldValueViewModel) {
        self.existingAmountViewModel = amountViewModel
        _amountViewModel = StateObject(wrappedValue: amountViewModel.copy)
        _doNotRegisterUserInput = State(initialValue: !amountViewModel.fieldValue.stringValue.isEmpty)
    }
}

extension AmountForm {
    
    public var body: some View {
        NavigationView {
            form
            .navigationTitle("Amount Per")
            .toolbar { keyboardToolbarContents }
            .toolbar { bottomToolbarContent }
            .toolbar { navigationLeadingContent }
            .sheet(isPresented: $showingUnitPicker) { unitPicker }
        }
        .scrollDismissesKeyboard(.never)
        .interactiveDismissDisabled(!haveValue)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shouldAnimateOptions = true
            }
        }
    }
    
    var form: some View {
        FormStyledScrollView {
            FormStyledSection(header: header, footer: footer) {
                HStack {
                    textField
                    unitButton
                }
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $amountViewModel.fieldValue.doubleValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .introspectTextField(customize: introspectTextField)
    }
    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(amountViewModel.fieldValue.doubleValue.unit.shortDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var unitPicker: some View {
        UnitPicker(
            pickedUnit: amountViewModel.fieldValue.doubleValue.unit
        ) {
            showingAddSizeForm = true
        } didPickUnit: { unit in
//            withAnimation {
                amountViewModel.fieldValue.doubleValue.unit = unit
//            }
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
    }
    
    var addSizeForm: some View {
        SizeForm(includeServing: false, allowAddSize: false) { sizeViewModel in
            guard let size = sizeViewModel.size else { return }
            amountViewModel.fieldValue.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Haptics.feedback(style: .rigid)
                showingUnitPicker = false
            }
        }
        .environmentObject(viewModel)

    }

    var header: some View {
        Text(viewModel.amountFormHeaderString)
    }
    
    @ViewBuilder
    var footer: some View {
        Text("This is how much of this food the nutrition facts are for. You'll be able to log this food using the unit you choose.")
            .foregroundColor(viewModel.amountViewModel.fieldValue.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
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
            .disabled(!haveValue)
        }
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }

    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Button("Save") {
//                if let didAddSizeViewModel = didAddSizeViewModel {
//                    didAddSizeViewModel(sizeViewModel)
//                }
//                if let existingSizeViewModel {
//                    viewModel.edit(existingSizeViewModel, with: sizeViewModel)
//                } else {
//                    viewModel.add(sizeViewModel: sizeViewModel)
//                }
//                dismiss()
            }
//            .disabled(!sizeViewModel.isValid || !isDirty)
            .id(refreshBool)
        }
    }
    
    var haveValue: Bool {
        !viewModel.amountViewModel.fieldValue.doubleValue.string.isEmpty
    }
    
    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
    func introspectTextField(_ uiTextField: UITextField) {
        guard !hasBecomeFirstResponder else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
        }
    }
}

//struct AmountFormPreview: View {
//
//    @StateObject var viewModel = FoodFormViewModel()
//
//    var body: some View {
//        AmountForm()
//            .environmentObject(viewModel)
//    }
//}
//
//struct AmountForm_Previews: PreviewProvider {
//
//    static var previews: some View {
//        AmountFormPreview()
//    }
//}
