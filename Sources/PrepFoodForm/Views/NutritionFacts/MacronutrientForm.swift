import SwiftUI
import PrepUnits
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUISugar
import Introspect

struct MacronutrientForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    @State var showingTextPicker = false
    @State var doNotRegisterUserInput: Bool
    @State var uiTextField: UITextField? = nil
    @State var hasBecomeFirstResponder: Bool = false
    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
    @State var shouldAnimateOptions = false
    
    init(fieldValueViewModel: FieldValueViewModel) {
        self.fieldValueViewModel = fieldValueViewModel
        _doNotRegisterUserInput = State(initialValue: !fieldValueViewModel.fieldValue.macroValue.string.isEmpty)
    }
}

//MARK: - Views
extension MacronutrientForm {
    var body: some View {
        NavigationView {
            content
                .navigationTitle(fieldValue.description)
                .toolbar { keyboardToolbarContent }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                print("🔥")
                shouldAnimateOptions = true
                
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                doNotRegisterUserInput = false
            }
        }
        .sheet(isPresented: $showingTextPicker) {
            textPicker
        }
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
            fillOptionsSections
        }
    }

    var textFieldSection: some View {
        FormStyledSection(footer: header) {
            HStack {
                textField
                Text(fieldValue.macroValue.unitDescription)
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
        }
    }

    var fillOptionsSections: some View {
        FillOptionsSections(
            fieldValueViewModel: fieldValueViewModel,
            shouldAnimate: $shouldAnimateOptions,
            didTapImage: {
                showingTextPicker = true
            }, didTapFillOption: { fillOption in
                didTapFillOption(fillOption)
            })
        .environmentObject(viewModel)
    }

    var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                doNotRegisterUserInput = true
                dismiss()
            }
        }
    }
    
    var header: some View {
        let string: String
        let autofillString = viewModel.shouldShowFillOptions(for: fieldValueViewModel.fieldValue) ? "or autofill " : ""
        if !fieldValue.stringValue.isEmpty {
            string = "Enter \(autofillString)a value"
        } else {
            string = ""
        }
        return Text(string)
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { self.fieldValue.macroValue.string },
            set: {
                self.fieldValueViewModel.fieldValue.macroValue.string = $0
                if !doNotRegisterUserInput && isFocused {
                    withAnimation {
                        fieldValueViewModel.registerUserInput()
                    }
                }
            }
        )
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .font(fieldValueViewModel.fieldValue.macroValue.string.isEmpty ? .body : .largeTitle)
            .frame(minHeight: 50)
            .introspectTextField(customize: introspectTextField)
    }
    
    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
    func introspectTextField(_ uiTextField: UITextField) {
        guard self.uiTextField == nil, !hasBecomeFirstResponder else {
            return
        }
        
        self.uiTextField = uiTextField
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
        }
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: viewModel.imageViewModels,
            selectedText: fieldValue.fillType.text,
            selectedImageIndex: selectedImageIndex,
            selectedBoundingBox: fieldValue.fillType.boundingBoxForImagePicker,
            onlyShowTextsWithValues: true
        ) { text, scanResultId in
            didTapText(text, onImageWithId: scanResultId)
        }
        .onDisappear {
            guard fieldValueViewModel.isCroppingNextImage else {
                return
            }
            fieldValueViewModel.cropFilledImage()
            doNotRegisterUserInput = false
        }
    }

    //MARK: - Actions
    
    func didTapText(_ text: RecognizedText, onImageWithId imageId: UUID) {
        guard let value = text.string.values.first else {
            print("Couldn't get a double from the tapped string")
            return
        }
        
        let newFillType: FillType
        if let autofillValueText = viewModel.autofillValueText(for: fieldValue),
           autofillValueText.text == text
        {
            newFillType = .imageAutofill(
                valueText: autofillValueText, scanResultId: imageId, value: nil
            )
        } else {
            newFillType = .imageSelection(
                recognizedText: text,
                scanResultId: imageId
            )
        }
        
        doNotRegisterUserInput = true
        withAnimation {
            setNew(amount: value.amount)
            fieldValueViewModel.fieldValue.fillType = newFillType
        }
        
        withAnimation {
            fieldValueViewModel.isCroppingNextImage = true
        }
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .chooseText:
            didTapChooseButton()
        case .fillType(let fillType):
            didTapFillTypeButton(for: fillType)
            doNotRegisterUserInput = true
            dismiss()
        }
    }
    
    func didTapChooseButton() {
        Haptics.feedback(style: .soft)
        showingTextPicker = true
    }
    
    func didTapFillTypeButton(for fillType: FillType) {
        Haptics.feedback(style: .rigid)
        withAnimation {
            changeFillType(to: fillType)
        }
    }
    
    func changeFillType(to fillType: FillType) {
        
        doNotRegisterUserInput = true
        
        switch fillType {
        case .imageSelection(let text, _, _, let value):
            changeFillTypeToSelection(of: text, withAltValue: value)
        case .imageAutofill(let valueText, _, value: let value):
            changeFillTypeToAutofill(of: valueText, withAltValue: value)
        default:
            break
        }
        
        let previousFillType = fieldValue.fillType
        fieldValueViewModel.fieldValue.fillType = fillType
        if fillType.text?.id != previousFillType.text?.id {
            fieldValueViewModel.isCroppingNextImage = true
            fieldValueViewModel.cropFilledImage()
        }
        
        doNotRegisterUserInput = false
    }
    
    func setNew(amount: Double) {
        fieldValueViewModel.fieldValue.macroValue.string = amount.cleanAmount
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        setNew(amount: value.amount)
    }
    
    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: FoodLabelValue?) {
        let value = altValue ?? valueText.value
        setNewValue(value)
    }
    
    func changeFillTypeToSelection(of text: RecognizedText, withAltValue altValue: FoodLabelValue?) {
        guard let value = altValue ?? text.string.values.first else {
            return
        }
        setNewValue(value)
    }
    
    //MARK: - Helpers
    
    var fieldValue: FieldValue {
        fieldValueViewModel.fieldValue
    }

    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fieldValue.fillType.scanResultId })
    }
}
