//import SwiftUI
//import PrepDataTypes
//import SwiftHaptics
//import FoodLabelScanner
//import VisionSugar
//import SwiftUISugar
//import Introspect
//
//struct MacronutrientForm_Legacy2: View {
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    @ObservedObject var fieldViewModel: FieldViewModel
//
//    @Environment(\.presentationMode) var presentation
//    @Environment(\.dismiss) var dismiss
//    @FocusState var isFocused: Bool
//    @State var showingTextPicker = false
//    @State var doNotRegisterUserInput: Bool
//    @State var uiTextField: UITextField? = nil
//    @State var hasBecomeFirstResponder: Bool = false
//    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
//    @State var shouldAnimateOptions = false
//
//    init(fieldViewModel: FieldViewModel) {
//        self.fieldViewModel = fieldViewModel
//        _doNotRegisterUserInput = State(initialValue: !fieldViewModel.fieldValue.macroValue.string.isEmpty)
//    }
//}
//
////MARK: - Views
//extension MacronutrientForm_Legacy2 {
//    var body: some View {
//        NavigationView {
//            content
//                .navigationTitle(fieldValue.description)
//                .toolbar { keyboardToolbarContent }
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
//                Text(fieldValue.macroValue.unitDescription)
//                    .foregroundColor(.secondary)
//                    .font(.title3)
//            }
//        }
//    }
//
//    var fillOptionsSections: some View {
//        FillOptionsSections(
//            fieldViewModel: fieldViewModel,
//            shouldAnimate: $shouldAnimateOptions,
//            didTapImage: {
//                showingTextPicker = true
//            }, didTapFillOption: { fillOption in
//                didTapFillOption(fillOption)
//            })
//        .environmentObject(viewModel)
//    }
//
//    var keyboardToolbarContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .keyboard) {
//            Spacer()
//            Button("Done") {
//                doNotRegisterUserInput = true
//                dismiss()
//            }
//        }
//    }
//
//    var header: some View {
//        let autofillString = viewModel.shouldShowFillOptions(for: fieldViewModel.fieldValue) ? "or autofill " : ""
//        let string = "Enter \(autofillString)a value"
//        return Text(string)
////            .opacity(fieldValue.macroValue.string.isEmpty ? 1 : 0)
//    }
//
//    var textField: some View {
//        let binding = Binding<String>(
//            get: { self.fieldValue.macroValue.string },
//            set: {
//                self.fieldViewModel.fieldValue.macroValue.string = $0
//                if !doNotRegisterUserInput && isFocused {
//                    withAnimation {
//                        fieldViewModel.registerUserInput()
//                    }
//                }
//            }
//        )
//
//        return TextField("Required", text: binding)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//            .focused($isFocused)
//            .font(fieldViewModel.fieldValue.macroValue.string.isEmpty ? .body : .largeTitle)
//            .frame(minHeight: 50)
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
//            guard fieldViewModel.isCroppingNextImage else {
//                return
//            }
//            fieldViewModel.cropFilledImage()
//            doNotRegisterUserInput = false
//        }
//    }
//
//    //MARK: - Actions
//
//    func didTapText(_ text: RecognizedText, onImageWithId imageId: UUID) {
//        guard let value = text.firstFoodLabelValue else {
//            print("Couldn't get a foodLabelValue from the tapped string")
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
//            newFillType = .selection(
//                recognizedText: text,
//                scanResultId: imageId
//            )
//        }
//
//        doNotRegisterUserInput = true
//        withAnimation {
//            setNew(amount: value.amount)
//            fieldViewModel.fieldValue.fill = newFillType
//        }
//
//        withAnimation {
//            fieldViewModel.isCroppingNextImage = true
//        }
//    }
//
//    func didTapFillOption(_ fillOption: FillOption) {
//        switch fillOption.type {
//        case .select:
//            didTapSelect()
//        case .fill(let fill):
//            didTapFillTypeButton(for: fill)
//            doNotRegisterUserInput = true
//            dismiss()
//        }
//    }
//
//    func didTapSelect() {
//        Haptics.feedback(style: .soft)
//        showingTextPicker = true
//    }
//
//    func didTapFillTypeButton(for fill: FillType) {
//        Haptics.feedback(style: .rigid)
//        withAnimation {
//            changeFillType(to: fill)
//        }
//    }
//
//    func changeFillType(to fill: FillType) {
//
//        doNotRegisterUserInput = true
//
//        switch fill {
//        case .selection(let text, _, _, let value):
//            changeFillTypeToSelection(of: text, withAltValue: value)
//        case .scanResult(let valueText, _, value: let value):
//            changeFillTypeToAutofill(of: valueText, withAltValue: value)
//        default:
//            break
//        }
//
//        let previousFillType = fieldValue.fill
//        fieldViewModel.fieldValue.fill = fill
//        if fill.text?.id != previousFillType.text?.id {
//            fieldViewModel.isCroppingNextImage = true
//            fieldViewModel.cropFilledImage()
//        }
//
//        doNotRegisterUserInput = false
//    }
//
//    func setNew(amount: Double) {
//        fieldViewModel.fieldValue.macroValue.string = amount.cleanAmount
//    }
//
//    func setNewValue(_ value: FoodLabelValue) {
//        setNew(amount: value.amount)
//    }
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
//        fieldViewModel.fieldValue
//    }
//
//    var selectedImageIndex: Int? {
//        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fieldValue.fill.scanResultId })
//    }
//}
