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
    let titleString: String?
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
    
    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
    @State var shouldAnimateOptions = false

    /// Bring this back if we're having issues with tap targets on buttons, as mentioned here: https://developer.apple.com/forums/thread/131404?answerId=612395022#612395022
//    @Environment(\.presentationMode) var presentation
    
    let setNewValue: ((FoodLabelValue) -> ())?
    let tappedPrefillFieldValue: ((FieldValue) -> ())?
    let didSave: (() -> ())?

    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         unitView: UnitView,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = unitView
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }

}

extension FieldValueForm where UnitView == EmptyView {
    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         supplementaryView: SupplementaryView,
         supplementaryViewHeaderString: String?,
         supplementaryViewFooterString: String?,
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = nil
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = supplementaryView
        self.supplementaryViewHeaderString = supplementaryViewHeaderString
        self.supplementaryViewFooterString = supplementaryViewFooterString
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }
}

extension FieldValueForm where SupplementaryView == EmptyView {
    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         unitView: UnitView,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         didSelectImageTextsHandler: (([ImageText]) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = unitView
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }
}

extension FieldValueForm where UnitView == EmptyView, SupplementaryView == EmptyView {
    init(fieldViewModel: FieldViewModel,
         existingFieldViewModel: FieldViewModel,
         headerString: String? = nil,
         footerString: String? = nil,
         titleString: String? = nil,
         placeholderString: String = "Required",
         didSave: (() -> ())? = nil,
         tappedPrefillFieldValue: ((FieldValue) -> ())? = nil,
         didSelectImageTextsHandler: (([ImageText]) -> ())? = nil,
         setNewValue: ((FoodLabelValue) -> ())? = nil
    ) {
        _doNotRegisterUserInput = State(initialValue: !existingFieldViewModel.fieldValue.string.isEmpty)
        self.existingFieldViewModel = existingFieldViewModel
        self.fieldViewModel = fieldViewModel
        self.unitView = nil
        self.headerString = headerString
        self.footerString = footerString
        self.titleString = titleString
        self.placeholderString = placeholderString
        self.supplementaryView = nil
        self.supplementaryViewHeaderString = nil
        self.supplementaryViewFooterString = nil
        self.didSave = didSave
        self.tappedPrefillFieldValue = tappedPrefillFieldValue
        self.setNewValue = setNewValue
    }
}

//MARK: - Views
extension FieldValueForm {
    var body: some View {
        content
            .navigationTitle(titleString ?? fieldValue.description)
            .fullScreenCover(isPresented: $showingTextPicker) {
                textPicker
            }
        .onAppear {
            isFocused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shouldAnimateOptions = true
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                doNotRegisterUserInput = false
            }
        }
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
        var string: String {
            let autofillString = viewModel.shouldShowFillOptions(for: fieldViewModel.fieldValue) ? "or autofill " : ""
            return "Enter \(autofillString)a value"
        }

        return Group {
            if !isForDecimalValue {
                EmptyView()
            } else {
                Text(string)
            }
        }
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { self.fieldValue.string },
            set: {
                if !doNotRegisterUserInput, isFocused, $0 != self.fieldViewModel.fieldValue.string {
                    withAnimation {
                        fieldViewModel.registerUserInput()
                    }
                }
                self.fieldViewModel.fieldValue.string = $0
            }
        )
        
        return TextField(placeholderString, text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(textFieldFont)
            .if(isForDecimalValue) { view in
                view
                    .keyboardType(.decimalPad)
                    .frame(minHeight: 50)
            }
            .if(!isForDecimalValue) { view in
                view
                    .lineLimit(1...3)
            }
            .scrollDismissesKeyboard(.interactively)
//            .introspectTextField(customize: { textField in
//                print("WE HERE")
//            })
//            .introspectTextField(customize: introspectTextField)
    }
    
    var isForDecimalValue: Bool {
        fieldValue.usesValueBasedTexts
    }
    
    var textFieldFont: Font {
        guard isForDecimalValue else {
            return .body
        }
        return fieldViewModel.fieldValue.string.isEmpty ? .body : .largeTitle
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
    
    var textPickerMode: TextPickerMode {
        if isForDecimalValue {
            return .multiSelection(
                filter: .allTexts,
                selectedImageTexts: fieldValue.fill.imageTexts) { imageTexts in
                    didSelectImageTexts(imageTexts)
                }
        } else {
            return .singleSelection(
                filter: .textsWithFoodLabelValues,
                selectedImageText: fieldValue.fill.imageText) { imageText in
                    didSelectImageTexts([imageText])
                }
        }
//        TextPickerViewModel(
//            imageViewModels: viewModel.imageViewModels,
//            filter: fieldValue.usesValueBasedTexts ? .textsWithFoodLabelValues : .allTexts,
//            selectedImageTexts: fieldValue.fill.imageTexts,
//            allowsMultipleSelection: !isForDecimalValue,
//            didSelectImageTexts: { imageTexts in
//                didSelectImageTexts(imageTexts)
//            }
//        )
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: viewModel.imageViewModels,
            mode: textPickerMode
        )
        .onDisappear {
            guard fieldViewModel.isCroppingNextImage else {
                return
            }
            fieldViewModel.cropFilledImage()
            doNotRegisterUserInput = false
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
        case .select:
            didTapSelect()
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            
            switch fill {
            case .selection(let info):
                tappedSelectionFill(info)
            case .scanned(let info):
                tappedScannedFill(info)
            case .prefill(let info):
                tappedPrefill(info)
            default:
                break
            }

            if fieldValue.usesValueBasedTexts {
                fieldViewModel.assignNewScannedFill(fill)
                doNotRegisterUserInput = false
                saveAndDismiss()
            }
        }
    }
    
    func tappedScannedFill(_ info: ScannedFillInfo) {
        if let value = info.altValue ?? info.value, let setNewValue {
            setNewValue(value)
        }
    }
    
    func tappedSelectionFill(_ info: SelectionFillInfo) {
        if fieldValue.usesValueBasedTexts {
            guard let imageText = info.imageText, let value = info.altValue ?? imageText.text.string.detectedValues.first else {
                return
            }
            if let setNewValue {
                setNewValue(value)
            }
        } else {
            guard let componentText = info.componentTexts?.first else {
                doNotRegisterUserInput = false
                return
            }
            
            withAnimation {
                fieldViewModel.toggleComponentText(componentText)
            }
            doNotRegisterUserInput = false
        }
    }
    
    func tappedPrefill(_ info: PrefillFillInfo) {
        if let tappedPrefillFieldValue {
            /// Tapped a prefill or calculated value
            guard let prefillFieldValue = viewModel.prefillOptionFieldValues(for: fieldValue).first else {
                return
            }
            
            tappedPrefillFieldValue(prefillFieldValue)
        } else {
            if !fieldValue.usesValueBasedTexts, let fieldString = info.fieldStrings.first {
                withAnimation {
                    fieldViewModel.toggle(fieldString)
                }
            }
        }
    }
    
    func didTapSelect() {
        showTextPicker()
    }
    
    func showTextPicker() {
        Haptics.feedback(style: .soft)
        doNotRegisterUserInput = true
        isFocused = false
        showingTextPicker = true
    }
    
    func fill(for text: RecognizedText, onImageWithId imageId: UUID) -> Fill {
        if let fill = viewModel.firstScannedFill(for: fieldValue, with: text) {
            return fill
        } else {
            return .selection(.init(imageText: ImageText(text: text, imageId: imageId)))
        }
    }
    
    func didSelectImageTexts(_ imageTexts: [ImageText]) {
        
        guard fieldValue.usesValueBasedTexts else {
            for imageText in imageTexts {
                fieldViewModel.appendComponentTexts(for: imageText)
            }
            return
        }
        
        //TODO: Handle serving and amount
        
        /// This is the generic handler which works for single pick fields such as energy, macro, micro
        guard let imageText = imageTexts.first, let value = imageText.text.firstFoodLabelValue else {
            return
        }
        
        let newFillType = fill(for: imageText.text, onImageWithId: imageText.imageId)
        doNotRegisterUserInput = true
        
        if let setNewValue {
            setNewValue(value)
            fieldViewModel.fieldValue.fill = newFillType
            fieldViewModel.isCroppingNextImage = true
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
