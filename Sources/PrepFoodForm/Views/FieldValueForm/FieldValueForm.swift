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
    let headerString: String?
    let footerString: String?
    let placeholderString: String

    @EnvironmentObject var viewModel: FoodFormViewModel
    @ObservedObject var existingFieldViewModel: FieldViewModel
    
    /// This stores a copy of the data from fieldViewModel until we're ready to persist the change
    @ObservedObject var fieldViewModel: FieldViewModel
    
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
    let toggledFieldValue: ((FieldValue) -> ())?
    let tappedText: ((RecognizedText, UUID) -> ())?
    let didSave: (() -> ())?

    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         unitView: UnitView,
         headerString: String? = nil,
         footerString: String? = nil,
         placeholderString: String = "Required",
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         didSave: (() -> ())? = nil,
         toggledFieldValue: ((FieldValue) -> ())? = nil,
         tappedText: ((RecognizedText, UUID) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = unitView
        self.headerString = headerString
        self.footerString = footerString
        self.placeholderString = placeholderString
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.didSave = didSave
        self.toggledFieldValue = toggledFieldValue
        self.tappedText = tappedText
        self.setNewValue = setNewValue
    }

}

extension FieldValueForm where UnitView == EmptyView {
    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         headerString: String? = nil,
         footerString: String? = nil,
         placeholderString: String = "Required",
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         didSave: (() -> ())? = nil,
         toggledFieldValue: ((FieldValue) -> ())? = nil,
         tappedText: ((RecognizedText, UUID) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = nil
        self.headerString = headerString
        self.footerString = footerString
        self.placeholderString = placeholderString
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.didSave = didSave
        self.toggledFieldValue = toggledFieldValue
        self.tappedText = tappedText
        self.setNewValue = setNewValue
    }
}

extension FieldValueForm where SupplementaryView == EmptyView {
    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         unitView: UnitView,
         headerString: String? = nil,
         footerString: String? = nil,
         placeholderString: String = "Required",
         didSave: (() -> ())? = nil,
         toggledFieldValue: ((FieldValue) -> ())? = nil,
         tappedText: ((RecognizedText, UUID) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = unitView
        self.headerString = headerString
        self.footerString = footerString
        self.placeholderString = placeholderString
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.didSave = didSave
        self.toggledFieldValue = toggledFieldValue
        self.tappedText = tappedText
        self.setNewValue = setNewValue
    }
}

extension FieldValueForm where UnitView == EmptyView, SupplementaryView == EmptyView {
    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         headerString: String? = nil,
         footerString: String? = nil,
         placeholderString: String = "Required",
         didSave: (() -> ())? = nil,
         toggledFieldValue: ((FieldValue) -> ())? = nil,
         tappedText: ((RecognizedText, UUID) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = nil
        self.headerString = headerString
        self.footerString = footerString
        self.placeholderString = placeholderString
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.didSave = didSave
        self.toggledFieldValue = toggledFieldValue
        self.tappedText = tappedText
        self.setNewValue = setNewValue
    }
}

//MARK: - Views
extension FieldValueForm {
    var body: some View {
        NavigationView {
            content
                .navigationTitle(fieldValue.description)
                .toolbar { navigationLeadingContent }
                .toolbar { navigationTrailingContent }
                .sheet(isPresented: $showingTextPicker) {
                    textPicker
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                print("🔥")
                shouldAnimateOptions = true
                
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                doNotRegisterUserInput = false
            }
        }
        .interactiveDismissDisabled(isDirty)
    }
    
    /// Returns true if any of the fields have changed from what they initially were
    var isDirty: Bool {
        fieldViewModel.fieldValue != existingFieldViewModel.fieldValue
        || fieldViewModel.fill != existingFieldViewModel.fill
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
        @ViewBuilder
        var footer: some View {
            if let footerString {
                Text(footerString)
            } else {
                defaultFooter
            }
        }
        
        return Group {
            if let headerString {
                FormStyledSection(header: Text(headerString), footer: footer) {
                    HStack {
                        textField
                        unitView
                    }
                }
            } else {
                FormStyledSection(footer: footer) {
                    HStack {
                        textField
                        unitView
                    }
                }
            }
        }
    }

    var fillOptionsSections: some View {
        FillOptionsSections(
            fieldViewModel: fieldViewModel,
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
                /// Do nothing to revert the values as the original `FieldViewModel` is still untouched
                doNotRegisterUserInput = true
                dismiss()
            }
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    
    var defaultFooter: some View {
        let autofillString = viewModel.shouldShowFillOptions(for: fieldViewModel.fieldValue) ? "or autofill " : ""
        let string = "Enter \(autofillString)a value"
        return Text(string)
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { self.fieldValue.string },
            set: {
                self.fieldViewModel.fieldValue.string = $0
                if !doNotRegisterUserInput && isFocused {
                    withAnimation {
                        fieldViewModel.registerUserInput()
                    }
                }
            }
        )
        
        return TextField(placeholderString, text: binding)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .font(textFieldFont)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
            .introspectTextField(customize: introspectTextField)
    }
    
    var textFieldFont: Font {
        fieldViewModel.fieldValue.string.isEmpty ? .body : .largeTitle
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
            selectedText: fieldValue.fill.text,
            selectedAttributeText: fieldValue.fill.attributeText,
            selectedImageIndex: selectedImageIndex,
            onlyShowTextsWithValues: fieldValue.usesValueBasedTexts
        ) { text, scanResultId in
            didTapText(text, onImageWithId: scanResultId)
        }
        .onDisappear {
            guard fieldViewModel.isCroppingNextImage else {
                return
            }
            fieldViewModel.cropFilledImage()
            doNotRegisterUserInput = false
            refreshBool.toggle()
       }
    }

    //MARK: - Actions
    
    func saveAndDismiss() {
        doNotRegisterUserInput = true
        /// Copy the data across from the transient `FieldViewModel` we were using here to persist the data
        existingFieldViewModel.copyData(from: fieldViewModel)
        if let didSave {
            didSave()
        }
        dismiss()
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .chooseText:
            didTapChooseButton()
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            guard case .fill(let fill) = fillOption.type else {
                return
            }

            doNotRegisterUserInput = true
            
            //TODO: Support 'deselecting' fill options for multiples like name
            switch fill {
            case .selection(let text, _, _, let value):
                changeFillTypeToSelection(of: text, withAltValue: value)
            case .scanned(let info):
                changeFillTypeToAutofill(info)
            case .prefill:
                /// Tapped a prefill or calculated value
                guard let fieldValue = viewModel.prefillOptionFieldValues(for: fieldValue).first else {
                    return
                }
                if let toggledFieldValue {
                    toggledFieldValue(fieldValue)
                }
            default:
                break
            }

            let previousFillType = fieldValue.fill
            fieldViewModel.fieldValue.fill = fill
            
            //TODO: Write a more succinct helper for this
            if fill.text?.id != previousFillType.text?.id {
                fieldViewModel.isCroppingNextImage = true
                fieldViewModel.cropFilledImage()
            }
            
            doNotRegisterUserInput = false
            
            //TODO: Don't save and dismiss if we expect multiples
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
    
    func fill(for text: RecognizedText, onImageWithId imageId: UUID) -> Fill {
        if let fill = viewModel.scannedFill(for: fieldValue, with: text) {
            return fill
        } else {
            return .selection(recognizedText: text, scanResultId: imageId)
        }
    }
    
    func didTapText(_ text: RecognizedText, onImageWithId imageId: UUID) {
        
        /// If we have a custom handler—use that
        if let tappedText {
            tappedText(text, imageId)
            return
        }
        
        //TODO: Handle serving and amount
        
        /// This is the generic handler which works for single pick fields such as energy, macro, micro
        guard let value = text.firstFoodLabelValue else {
            print("Couldn't get a double from the tapped string")
            return
        }
        
        let newFillType = fill(for: text, onImageWithId: imageId)
        doNotRegisterUserInput = true
        
        if let setNewValue {
            setNewValue(value)
            fieldViewModel.fieldValue.fill = newFillType
            fieldViewModel.isCroppingNextImage = true
        }
    }
    
    func changeFillTypeToAutofill(_ info: ScannedFillInfo) {
        if let value = info.value, let setNewValue {
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
        fieldViewModel.fieldValue
    }
    
    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fieldValue.fill.resultId })
    }
}
