//import SwiftUI
//import PrepUnits
//import SwiftHaptics
//import FoodLabelScanner
//import VisionSugar
//import SwiftUISugar
//import Introspect
//
//struct EnergyForm_Legacy: View {
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    @ObservedObject var fieldViewModel: FieldViewModel
//
//    /// This stores a copy of the data from fieldViewModel until we're ready to persist the change
//    @StateObject var formViewModel: FieldViewModel
//
//    @Environment(\.dismiss) var dismiss
//    @FocusState var isFocused: Bool
//    @State var showingTextPicker = false
//    @State var doNotRegisterUserInput: Bool
//    @State var uiTextField: UITextField? = nil
//    @State var hasBecomeFirstResponder: Bool = false
//
//    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
//    @State var shouldAnimateOptions = false
//
//    /// Bring this back if we're having issues with tap targets on buttons, as mentioned here: https://developer.apple.com/forums/thread/131404?answerId=612395022#612395022
////    @Environment(\.presentationMode) var presentation
//
//    init(fieldViewModel: FieldViewModel) {
//        _doNotRegisterUserInput = State(initialValue: !fieldViewModel.fieldValue.string.isEmpty)
//
//        self.fieldViewModel = fieldViewModel
//        let formViewModel = fieldViewModel.copy
//        _formViewModel = StateObject(wrappedValue: formViewModel)
//    }
//}
//
////MARK: - Views
//extension EnergyForm_Legacy {
//    var body: some View {
//        NavigationView {
//            content
//                .navigationTitle(fieldValue.description)
//                .toolbar { keyboardToolbarContent }
//                .toolbar { bottomToolbarContent }
//                .toolbar { navigationLeadingContent }
//                .toolbar { navigationTrailingContent }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                print("🔥")
//                shouldAnimateOptions = true
//
//                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
//                doNotRegisterUserInput = false
//            }
//        }
//        .sheet(isPresented: $showingTextPicker) {
//            textPicker
//        }
//        .interactiveDismissDisabled(isDirty)
//    }
//
//    /// Returns true if any of the fields have changed from what they initially were
//    var isDirty: Bool {
//        formViewModel.fieldValue != fieldViewModel.fieldValue
//    }
//
//    var content: some View {
//        FormStyledScrollView {
//            textFieldSection
//            fillOptionsSections
//        }
//    }
//
//    var textFieldSection: some View {
//        FormStyledSection(footer: header) {
//            HStack {
//                textField
//                energyUnitPicker
//            }
//        }
//    }
//
//    var fillOptionsSections: some View {
//        FillOptionsSections(
//            fieldViewModel: formViewModel,
//            shouldAnimate: $shouldAnimateOptions,
//            didTapImage: {
//                showTextPicker()
//            }, didTapFillOption: { fillOption in
//                didTapFillOption(fillOption)
//            })
//        .environmentObject(viewModel)
//    }
//
//    @ViewBuilder
//    var saveButton: some View {
//        Button("Save") {
//            saveAndDismiss()
//        }
//        .disabled(!isDirty)
//    }
//
//    var navigationLeadingContent: some ToolbarContent {
//        ToolbarItem(placement: .navigationBarLeading) {
//            Button("Cancel") {
//                /// Do nothing to revert the values as the original `FieldViewModel` is still untouched
//                doNotRegisterUserInput = true
//                dismiss()
//            }
//        }
//    }
//
//    var navigationTrailingContent: some ToolbarContent {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            Button {
//
//            } label: {
//                Image(systemName: "info.circle")
//            }
//        }
//    }
//    var bottomToolbarContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .bottomBar) {
//            Spacer()
//            saveButton
//        }
//    }
//
//    var keyboardToolbarContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .keyboard) {
//            Spacer()
//            saveButton
//        }
//    }
//
//    var header: some View {
//        let autofillString = viewModel.shouldShowFillOptions(for: formViewModel.fieldValue) ? "or autofill " : ""
//        let string = "Enter \(autofillString)a value"
//        return Text(string)
//    }
//
//    var textField: some View {
//        let binding = Binding<String>(
//            get: { self.fieldValue.string },
//            set: {
//                self.formViewModel.fieldValue.string = $0
//                if !doNotRegisterUserInput && isFocused {
//                    withAnimation {
//                        formViewModel.registerUserInput()
//                    }
//                }
//            }
//        )
//
//        return TextField("Required", text: binding)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//            .focused($isFocused)
//            .font(formViewModel.fieldValue.string.isEmpty ? .body : .largeTitle)
//            .frame(minHeight: 50)
//            .scrollDismissesKeyboard(.interactively)
//            .introspectTextField(customize: introspectTextField)
//    }
//
//    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
//    func introspectTextField(_ uiTextField: UITextField) {
//        guard self.uiTextField == nil, !hasBecomeFirstResponder else {
//            return
//        }
//
//        self.uiTextField = uiTextField
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//            uiTextField.becomeFirstResponder()
//            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
//            hasBecomeFirstResponder = true
//        }
//    }
//
//    var energyUnitPicker: some View {
//        Picker("", selection: $formViewModel.fieldValue.energyValue.unit) {
//            ForEach(EnergyUnit.allCases, id: \.self) {
//                unit in
//                Text(unit.shortDescription).tag(unit)
//            }
//        }
//        .pickerStyle(.segmented)
//
//    }
//
//    var textPicker: some View {
//        TextPicker(
//            imageViewModels: viewModel.imageViewModels,
//            selectedText: fieldValue.fill.text,
//            selectedAttributeText: fieldValue.fill.attributeText,
//            selectedImageIndex: selectedImageIndex,
//            onlyShowTextsWithValues: true
//        ) { text, scanResultId in
//            didTapText(text, onImageWithId: scanResultId)
//        }
//        .onDisappear {
//            guard formViewModel.isCroppingNextImage else {
//                return
//            }
//            formViewModel.cropFilledImage()
//            doNotRegisterUserInput = false
//       }
//    }
//
//    //MARK: - Actions
//
//    func saveAndDismiss() {
//        doNotRegisterUserInput = true
//        /// Copy the data across from the transient `FieldViewModel` we were using here to persist the data
//        fieldViewModel.copyData(from: formViewModel)
//        dismiss()
//    }
//
//    func didTapText(_ text: RecognizedText, onImageWithId imageId: UUID) {
//
//        guard let value = text.firstFoodLabelValue else {
//            print("Couldn't get a double from the tapped string")
//            return
//        }
//
//        let newFillType: FillType
//        if let autofillValueText = viewModel.autofillValueText(for: fieldValue),
//           autofillValueText.text == text
//        {
//            newFillType = .scanResult(
//                valueText: autofillValueText, scanResultId: imageId, value: nil
//            )
//        } else {
//            newFillType = .scanManual(
//                recognizedText: text,
//                scanResultId: imageId
//            )
//        }
//
//        doNotRegisterUserInput = true
//        setNewValue(value)
//        formViewModel.fieldValue.fill = newFillType
//        formViewModel.isCroppingNextImage = true
//    }
//
//    func didTapFillOption(_ fillOption: FillOption) {
//        switch fillOption.type {
//        case .chooseText:
//            didTapChooseButton()
//        case .fill(let fill):
//            Haptics.feedback(style: .rigid)
//            changeFillType(to: fill)
//            saveAndDismiss()
//        }
//    }
//
//    func didTapChooseButton() {
//        showTextPicker()
//    }
//
//    func showTextPicker() {
//        Haptics.feedback(style: .soft)
//        doNotRegisterUserInput = true
//        isFocused = false
//        showingTextPicker = true
//    }
//
//    func changeFillType(to fill: FillType) {
//
//        doNotRegisterUserInput = true
//
//        switch fill {
//        case .scanManual(let text, _, _, let value):
//            changeFillTypeToSelection(of: text, withAltValue: value)
//        case .scanResult(let valueText, _, value: let value):
//            changeFillTypeToAutofill(of: valueText, withAltValue: value)
//        default:
//            break
//        }
//
//        let previousFillType = fieldValue.fill
//        formViewModel.fieldValue.fill = fill
//        if fill.text?.id != previousFillType.text?.id {
//            formViewModel.isCroppingNextImage = true
//            formViewModel.cropFilledImage()
//        }
//
//        doNotRegisterUserInput = false
//    }
//
//
//    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: FoodLabelValue?) {
//        let value = altValue ?? valueText.value
//        setNewValue(value)
//    }
//
//    func changeFillTypeToSelection(of text: RecognizedText, withAltValue altValue: FoodLabelValue?) {
//        guard let value = altValue ?? text.string.values.first else {
//            return
//        }
//        setNewValue(value)
//    }
//
//    //MARK: - Helpers
//
//    var fieldValue: FieldValue {
//        formViewModel.fieldValue
//    }
//
//    var selectedImageIndex: Int? {
//        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fieldValue.fill.scanResultId })
//    }
//
//    //MARK: - Energy based
//    func setNewValue(_ value: FoodLabelValue) {
//        formViewModel.fieldValue.energyValue.string = value.amount.cleanAmount
//        formViewModel.fieldValue.energyValue.unit = value.unit?.energyUnit ?? .kcal
//    }
//}
//
////MARK: - Preview
//
////struct EnergyFormPreview: View {
////
////    @StateObject var viewModel = FoodFormViewModel()
////
////    public init() {
////        let viewModel = FoodFormViewModel.mock
////        _viewModel = StateObject(wrappedValue: viewModel)
////    }
////
////    var body: some View {
////        EnergyForm(fieldViewModel: viewModel.energyViewModel)
////            .environmentObject(viewModel)
////    }
////}
////
////struct EnergyForm_Previews: PreviewProvider {
////    static var previews: some View {
////        EnergyFormPreview()
////    }
////}
