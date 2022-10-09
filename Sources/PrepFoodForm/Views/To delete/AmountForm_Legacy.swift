//import SwiftUI
//import SwiftHaptics
//import SwiftUISugar
//import VisionSugar
//import FoodLabelScanner
//import PrepUnits
//
//public struct AmountForm_Legacy: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    
//    let existingAmountViewModel: FieldViewModel
//    
//    /// This stores a copy of the data from fieldViewModel until we're ready to persist the change
//    @StateObject var amountViewModel: FieldViewModel
//
//    @State var showingUnitPicker = false
//    @State var showingAddSizeForm = false
//    @State var showingTextPicker = false
//    @FocusState var isFocused
//    
//    @State var doNotRegisterUserInput: Bool
//    @State var hasBecomeFirstResponder: Bool = false
//    @State var refreshBool = false
//
//    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
//    @State var shouldAnimateOptions = false
//
//    init(amountViewModel: FieldViewModel) {
//        self.existingAmountViewModel = amountViewModel
//        _amountViewModel = StateObject(wrappedValue: amountViewModel.copy)
//        _doNotRegisterUserInput = State(initialValue: !amountViewModel.fieldValue.stringValue.isEmpty)
//    }
//}
//
//extension AmountForm_Legacy {
//    
//    public var body: some View {
//        NavigationView {
//            form
//            .navigationTitle("Amount Per")
//            .toolbar { keyboardToolbarContents }
//            .toolbar { navigationLeadingContent }
//            .toolbar { bottomBarContents }
//            .sheet(isPresented: $showingUnitPicker) { unitPicker }
//            .sheet(isPresented: $showingTextPicker) { textPicker }
//        }
////        .scrollDismissesKeyboard(.never)
//        .interactiveDismissDisabled(!haveValue)
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                shouldAnimateOptions = true
//            }
//        }
//    }
//    
//    var form: some View {
//        FormStyledScrollView {
//            FormStyledSection(header: header, footer: footer) {
//                HStack {
//                    textField
//                    unitButton
//                }
//            }
//            fillOptionsSections
//        }
//    }
//    
//    var bottomBarContents: some ToolbarContent {
//        ToolbarItemGroup(placement: .bottomBar) {
//            Spacer()
//            saveButton
//        }
//    }
//    
//    var textField: some View {
//        let binding = Binding<String>(
//            get: { amountViewModel.fieldValue.doubleValue.string },
//            set: {
//                amountViewModel.fieldValue.doubleValue.string = $0
//                if !doNotRegisterUserInput && isFocused {
//                    withAnimation {
//                        amountViewModel.registerUserInput()
//                    }
//                }
//            }
//        )
//
//        return TextField("Required", text: binding)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//            .focused($isFocused)
//            .introspectTextField(customize: introspectTextField)
//    }
//    
//    var unitButton: some View {
//        Button {
//            showingUnitPicker = true
//        } label: {
//            HStack(spacing: 5) {
//                Text(amountViewModel.fieldValue.doubleValue.unit.shortDescription)
//                Image(systemName: "chevron.up.chevron.down")
//                    .imageScale(.small)
//            }
//        }
//        .buttonStyle(.borderless)
//    }
//    
//    var fillOptionsSections: some View {
//        FillOptionsSections(
//            fieldViewModel: amountViewModel,
//            shouldAnimate: $shouldAnimateOptions,
//            didTapImage: {
//                showTextPicker()
//            }, didTapFillOption: { fillOption in
//                didTapFillOption(fillOption)
//            })
//        .environmentObject(viewModel)
//    }
//    
//    func showTextPicker() {
//        Haptics.feedback(style: .soft)
//        doNotRegisterUserInput = true
//        isFocused = false
//        showingTextPicker = true
//    }
//
//    func didTapFillOption(_ fillOption: FillOption) {
//        switch fillOption.type {
//        case .chooseText:
//            didTapChooseButton()
//        case .fill(let fill):
//            Haptics.feedback(style: .rigid)
//            changeFillType(to: fill)
////            saveAndDismiss()
//        }
//    }
//    
//    func changeFillType(to fill: FillType) {
//        
//        doNotRegisterUserInput = true
//        
//        switch fill {
//        case .imageSelection(let text, _, _, let value):
//            changeFillTypeToSelection(of: text, withAltValue: value)
//        case .imageAutofill(let valueText, _, value: let value):
//            changeFillTypeToAutofill(of: valueText, withAltValue: value)
//        default:
//            break
//        }
//        
//        let previousFillType = amountViewModel.fieldValue.fill
//        amountViewModel.fieldValue.fill = fill
//        if fill.text?.id != previousFillType.text?.id {
//            amountViewModel.isCroppingNextImage = true
//            amountViewModel.cropFilledImage()
//        }
//        
//        doNotRegisterUserInput = false
//    }
//
//    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: FoodLabelValue?) {
//        let value = altValue ?? valueText.value
//        amountViewModel.fieldValue.doubleValue.double = value.amount
//        amountViewModel.fieldValue.doubleValue.unit = value.unit?.formUnit ?? .serving
//    }
//    
//    func changeFillTypeToSelection(of text: RecognizedText, withAltValue altValue: FoodLabelValue?) {
//        guard let value = altValue ?? text.string.values.first else {
//            return
//        }
//        amountViewModel.fieldValue.doubleValue.double = value.amount
//        amountViewModel.fieldValue.doubleValue.unit = value.unit?.formUnit ?? .serving
//    }
//
//    func didTapChooseButton() {
//        showTextPicker()
//    }
//
//    var unitPicker: some View {
//        UnitPicker(
//            pickedUnit: amountViewModel.fieldValue.doubleValue.unit
//        ) {
//            showingAddSizeForm = true
//        } didPickUnit: { unit in
////            withAnimation {
//                amountViewModel.fieldValue.doubleValue.unit = unit
////            }
//        }
//        .environmentObject(viewModel)
//        .sheet(isPresented: $showingAddSizeForm) { addSizeForm }
//    }
//    
//    var textPicker: some View {
//        TextPicker(
//            imageViewModels: viewModel.imageViewModels,
//            selectedText: fill.text,
//            selectedAttributeText: fill.attributeText,
//            selectedImageIndex: selectedImageIndex,
//            onlyShowTextsWithValues: true
//        ) { text, scanResultId in
//            didTapText(text, onImageWithId: scanResultId)
//        }
//        .onDisappear {
//            guard amountViewModel.isCroppingNextImage else {
//                return
//            }
//            amountViewModel.cropFilledImage()
//            doNotRegisterUserInput = false
//            refreshBool.toggle()
//       }
//    }
//    
//    func didTapText(_ text: RecognizedText, onImageWithId imageId: UUID) {
//        
//        guard let value = text.firstFoodLabelValue else {
//            print("Couldn't get a double from the tapped string")
//            return
//        }
//        
//        let newFillType = fill(for: text, onImageWithId: imageId)
//        doNotRegisterUserInput = true
//        
//        amountViewModel.fieldValue.doubleValue.double = value.amount
//        amountViewModel.fieldValue.doubleValue.unit = value.unit?.formUnit ?? .serving
//        amountViewModel.fieldValue.fill = newFillType
//        amountViewModel.isCroppingNextImage = true
//    }
//    
//    func fill(for text: RecognizedText, onImageWithId imageId: UUID) -> FillType {
//        if let valueText = viewModel.autofillValueText(for: amountViewModel.fieldValue),
//            valueText.text == text
//        {
//            return .imageAutofill(valueText: valueText, scanResultId: imageId, value: nil)
//        } else {
//            return .imageSelection(recognizedText: text, scanResultId: imageId)
//        }
//    }
//
//    
//    var selectedImageIndex: Int? {
//        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fill.scanResultId })
//    }
//    
//    var fill: FillType {
//        amountViewModel.fieldValue.fill
//    }
//
//    var addSizeForm: some View {
//        SizeForm(includeServing: false, allowAddSize: false) { sizeViewModel in
//            guard let size = sizeViewModel.size else { return }
//            amountViewModel.fieldValue.doubleValue.unit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                Haptics.feedback(style: .rigid)
//                showingUnitPicker = false
//            }
//        }
//        .environmentObject(viewModel)
//
//    }
//
//    var header: some View {
//        var string: String {
//            switch amountViewModel.fieldValue.doubleValue.unit {
//            case .serving:
//                return "Servings"
//            case .weight:
//                return "Weight"
//            case .volume:
//                return "Volume"
//            case .size:
//                return "Size"
//            }
//        }
//
//        return Text(string)
//    }
//    
//    @ViewBuilder
//    var footer: some View {
//        Text("This is how much of this food the nutrition facts are for. You'll be able to log this food using the unit you choose.")
//            .foregroundColor(amountViewModel.fieldValue.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
//    }
//
//    var keyboardToolbarContents: some ToolbarContent {
//        ToolbarItemGroup(placement: .keyboard) {
//            Button("Units") {
//                showingUnitPicker = true
//            }
//            Spacer()
//            saveButton
//        }
//    }
//    
//    var navigationLeadingContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarLeading) {
//            Button("Cancel") {
//                dismiss()
//            }
//        }
//    }
//
//    var saveButton: some View {
//        Button("Save") {
//            viewModel.amountViewModel.copyData(from: amountViewModel)
//            dismiss()
//        }
//        .disabled(!haveValue || !isDirty)
//        .id(refreshBool)
//    }
//    
//    var isDirty: Bool {
//        amountViewModel.fieldValue != existingAmountViewModel.fieldValue
//    }
//    
//    var haveValue: Bool {
//        !amountViewModel.fieldValue.doubleValue.string.isEmpty
//    }
//    
//    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
//    func introspectTextField(_ uiTextField: UITextField) {
//        guard !hasBecomeFirstResponder else {
//            return
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//            uiTextField.becomeFirstResponder()
//            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
//            hasBecomeFirstResponder = true
//        }
//    }
//}
