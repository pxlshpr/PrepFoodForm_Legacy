import SwiftUI
import PrepUnits
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUISugar
import Introspect

struct FieldValueForm<UnitView: View, SupplementaryView: View>: View {
    var unitView: UnitView?
    var supplementaryView: SupplementaryView?
    var supplementaryViewFooterString: String?
    var supplementaryViewHeaderString: String?

    @EnvironmentObject var viewModel: FoodFormViewModel
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
    
    /// This stores a copy of the data from fieldValueViewModel until we're ready to persist the change
    @ObservedObject var formViewModel: FieldValueViewModel
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    @State var showingTextPicker = false
    @State var doNotRegisterUserInput: Bool
    @State var uiTextField: UITextField? = nil
    @State var hasBecomeFirstResponder: Bool = false
    @State var refreshBool = false
    
    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
    @State var shouldAnimateOptions = false

    /// Bring this back if we're having issues with tap targets on buttons, as mentioned here: https://developer.apple.com/forums/thread/131404?answerId=612395022#612395022
//    @Environment(\.presentationMode) var presentation
    
    let setNewValue: ((FoodLabelValue) -> ())?
    
    init(formViewModel: FieldValueViewModel,
         fieldValueViewModel: FieldValueViewModel,
         unitView: UnitView,
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !fieldValueViewModel.fieldValue.string.isEmpty)
        
        self.fieldValueViewModel = fieldValueViewModel
        self.formViewModel = formViewModel
        self.unitView = unitView
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.setNewValue = setNewValue
    }

}

extension FieldValueForm where UnitView == EmptyView {
    init(formViewModel: FieldValueViewModel,
         fieldValueViewModel: FieldValueViewModel,
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !fieldValueViewModel.fieldValue.string.isEmpty)
        
        self.fieldValueViewModel = fieldValueViewModel
        self.formViewModel = formViewModel
        self.unitView = nil
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.setNewValue = setNewValue
    }
}

extension FieldValueForm where SupplementaryView == EmptyView {
    init(formViewModel: FieldValueViewModel,
         fieldValueViewModel: FieldValueViewModel,
         unitView: UnitView,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !fieldValueViewModel.fieldValue.string.isEmpty)
        
        self.fieldValueViewModel = fieldValueViewModel
        self.formViewModel = formViewModel
        self.unitView = unitView
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.setNewValue = setNewValue
    }
}

extension FieldValueForm where UnitView == EmptyView, SupplementaryView == EmptyView {
    init(formViewModel: FieldValueViewModel,
         fieldValueViewModel: FieldValueViewModel,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !fieldValueViewModel.fieldValue.string.isEmpty)
        
        self.fieldValueViewModel = fieldValueViewModel
        self.formViewModel = formViewModel
        self.unitView = nil
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.setNewValue = setNewValue
    }
}

//MARK: - Views
extension FieldValueForm {
    var body: some View {
        NavigationView {
            content
                .navigationTitle(fieldValue.description)
                .toolbar { keyboardToolbarContent }
                .toolbar { bottomToolbarContent }
                .toolbar { navigationLeadingContent }
                .toolbar { navigationTrailingContent }
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
        .interactiveDismissDisabled(isDirty)
    }
    
    /// Returns true if any of the fields have changed from what they initially were
    var isDirty: Bool {
        formViewModel.fieldValue != fieldValueViewModel.fieldValue
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
            supplementaryViewSection
            fillOptionsSections
        }
    }
    
    var supplementaryViewSection: some View {
        
        @ViewBuilder
        var footer: some View {
            if supplementaryView != nil, let supplementaryViewFooterString {
                Text(supplementaryViewFooterString)
            }
        }

        @ViewBuilder
        var header: some View {
            if supplementaryView != nil, let supplementaryViewHeaderString {
                Text(supplementaryViewHeaderString)
            }
        }

        return Group {
            if let supplementaryView {
                FormStyledSection(header: header, footer: footer) {
                    supplementaryView
                }
            }
        }
    }

    var textFieldSection: some View {
        FormStyledSection(footer: header) {
            HStack {
                textField
                unitView
            }
        }
    }

    var fillOptionsSections: some View {
        FillOptionsSections(
            fieldValueViewModel: formViewModel,
            shouldAnimate: $shouldAnimateOptions,
            didTapImage: {
                showTextPicker()
            }, didTapFillOption: { fillOption in
                didTapFillOption(fillOption)
            })
        .environmentObject(viewModel)
    }

    @ViewBuilder
    var saveButton: some View {
        Button("Save") {
            saveAndDismiss()
        }
        .disabled(!isDirty)
        .id(refreshBool)
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                /// Do nothing to revert the values as the original `FieldValueViewModel` is still untouched
                doNotRegisterUserInput = true
                dismiss()
            }
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "info.circle")
            }
        }
    }
    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            saveButton
        }
    }
    
    var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            saveButton
        }
    }
    
    var header: some View {
        let autofillString = viewModel.shouldShowFillOptions(for: formViewModel.fieldValue) ? "or autofill " : ""
        let string = "Enter \(autofillString)a value"
        return Text(string)
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { self.fieldValue.string },
            set: {
                self.formViewModel.fieldValue.string = $0
                if !doNotRegisterUserInput && isFocused {
                    withAnimation {
                        formViewModel.registerUserInput()
                    }
                }
            }
        )
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .font(formViewModel.fieldValue.string.isEmpty ? .body : .largeTitle)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
            .introspectTextField(customize: introspectTextField)
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
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: viewModel.imageViewModels,
            selectedText: fieldValue.fillType.text,
            selectedAttributeText: fieldValue.fillType.attributeText,
            selectedImageIndex: selectedImageIndex,
            onlyShowTextsWithValues: true
        ) { text, scanResultId in
            didTapText(text, onImageWithId: scanResultId)
        }
        .onDisappear {
            guard formViewModel.isCroppingNextImage else {
                return
            }
            formViewModel.cropFilledImage()
            doNotRegisterUserInput = false
            refreshBool.toggle()
       }
    }

    //MARK: - Actions
    
    func saveAndDismiss() {
        doNotRegisterUserInput = true
        /// Copy the data across from the transient `FieldValueViewModel` we were using here to persist the data
        fieldValueViewModel.copyData(from: formViewModel)
        dismiss()
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .chooseText:
            didTapChooseButton()
        case .fillType(let fillType):
            Haptics.feedback(style: .rigid)
            changeFillType(to: fillType)
            saveAndDismiss()
        }
    }
    
    func didTapChooseButton() {
        showTextPicker()
    }
    
    func showTextPicker() {
        Haptics.feedback(style: .soft)
        doNotRegisterUserInput = true
        isFocused = false
        showingTextPicker = true
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
        formViewModel.fieldValue.fillType = fillType
        if fillType.text?.id != previousFillType.text?.id {
            formViewModel.isCroppingNextImage = true
            formViewModel.cropFilledImage()
        }
        
        doNotRegisterUserInput = false
    }
    
    func fillType(for text: RecognizedText, onImageWithId imageId: UUID) -> FillType {
        if let valueText = viewModel.autofillValueText(for: fieldValue), valueText.text == text {
            return .imageAutofill(valueText: valueText, scanResultId: imageId, value: nil)
        } else {
            return .imageSelection(recognizedText: text, scanResultId: imageId)
        }
    }
    
    func didTapText(_ text: RecognizedText, onImageWithId imageId: UUID) {
        
        guard let value = text.firstFoodLabelValue else {
            print("Couldn't get a double from the tapped string")
            return
        }
        
        let newFillType = fillType(for: text, onImageWithId: imageId)
        doNotRegisterUserInput = true
        
        if let setNewValue {
            setNewValue(value)
            formViewModel.fieldValue.fillType = newFillType
            formViewModel.isCroppingNextImage = true
        }
    }
    
    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: FoodLabelValue?) {
        let value = altValue ?? valueText.value
        if let setNewValue {
            setNewValue(value)
        }
    }
    
    func changeFillTypeToSelection(of text: RecognizedText, withAltValue altValue: FoodLabelValue?) {
        guard let value = altValue ?? text.string.values.first else {
            return
        }
        if let setNewValue {
            setNewValue(value)
        }
    }

    //MARK: - Helpers
    
    var fieldValue: FieldValue {
        formViewModel.fieldValue
    }

    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fieldValue.fillType.scanResultId })
    }
}
