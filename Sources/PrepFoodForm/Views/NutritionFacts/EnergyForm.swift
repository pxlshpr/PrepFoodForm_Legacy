import SwiftUI
import PrepUnits
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUISugar
import Introspect

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    @State var showingFilledText = false
    @State var showingTextPicker = false
    @State var doNotRegisterUserInput: Bool

    @State var uiTextField: UITextField? = nil
    @State var hasBecomeFirstResponder: Bool = false
    @State var resetIsFillingTask: Task<(), any Error>? = nil
    
    @State var shouldAnimateOptions = false
    
    init(fieldValueViewModel: FieldValueViewModel) {
        self.fieldValueViewModel = fieldValueViewModel
        _doNotRegisterUserInput = State(initialValue: !fieldValueViewModel.fieldValue.energyValue.string.isEmpty)
    }
}

//MARK: - Views
extension EnergyForm {
    var body: some View {
        NavigationView {
            content
                .navigationTitle(fieldValue.description)
//                .toolbar {
//                    ToolbarItemGroup(placement: .navigationBarTrailing) {
//                        Button("Done") {
//                            doNotRegisterUserInput = true
//                            dismiss()
//                        }
//                    }
//                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            doNotRegisterUserInput = true
                            dismiss()
                        }
                    }
                }
        }
//        .onChange(of: fieldValue.energyValue.string) { newValue in
//            guard !isFilling else { return }
//
//            withAnimation {
//                fieldValueViewModel.registerUserInput()
//            }
//        }
        //TODO: Use a custom binding for unit as well just like we are for textfield—also store the StackOverflow answer from where we're getting it and add it to KB in obsidian under obscure SwiftUI intricacy where .onChange might be called a bit after actually setting a value so this way is more accurate to register user input as it gets called immediately after the keystrokes and the value changes. https://stackoverflow.com/a/59040171
        
            .onChange(of: fieldValue.energyValue.unit) { newValue in
                guard !doNotRegisterUserInput, unitChangeShouldRegisterAsUserInput else { return }
                /// This will only trigger a change of the fillType to `.userInput`, if the `energyValue` of the text has an energy unit
                withAnimation {
//                    fieldValueViewModel.registerUserInput()
                }
            }
            .onAppear {
//                isFocused = true
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    print("🔥")
                    shouldAnimateOptions = true
                    doNotRegisterUserInput = false
                }
            }
            .sheet(isPresented: $showingTextPicker) {
                textPicker
            }
    }

    var scrollView: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                textField
                unitLabel
            }
        }
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    var form: some View {
        Form {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    var formStyledScrollView: some View {
        FormStyledScrollView {
            FormStyledSection(header: header) {
                HStack {
                    textField
                    unitLabel
                }
            }
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
    }
    var content: some View {
//        form
//        scrollView
        formStyledScrollView
    }
    
    var header: some View {
        let string: String
        if viewModel.shouldShowFillOptions(for: fieldValueViewModel.fieldValue) {
            string = "Enter or auto-fill a value"
        } else {
            string = ""
        }
        return Text(string)
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { self.fieldValue.energyValue.string },
            set: {
                self.fieldValueViewModel.fieldValue.energyValue.string = $0
                if !doNotRegisterUserInput && isFocused {
                    withAnimation {
                        fieldValueViewModel.registerUserInput()
                    }
                }
            }
        )

//        return TextField("Required", text: $fieldValueViewModel.fieldValue.energyValue.string)
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
//            .interactiveDismissDisabled()
            .font(fieldValueViewModel.fieldValue.energyValue.string.isEmpty ? .body : .largeTitle)
            .frame(minHeight: 50)
            .introspectTextField { textField in
                if self.uiTextField == nil, !hasBecomeFirstResponder {
                    self.uiTextField = uiTextField
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        textField.becomeFirstResponder()
                        /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
                        hasBecomeFirstResponder = true
                    }
                }
            }
    }
    
    var unitLabel: some View {
        Picker("", selection: $fieldValueViewModel.fieldValue.energyValue.unit) {
            ForEach(EnergyUnit.allCases, id: \.self) {
                unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)
        
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: viewModel.imageViewModels,
            selectedText: fieldValue.fillType.text,
            selectedImageIndex: selectedImageIndex,
            selectedBoundingBox: fieldValue.fillType.boundingBoxForImagePicker,
            onlyShowTextsWithValues: true
        ) { text, scanResultId in
            
            guard let value = text.string.values.first else {
                print("Couldn't get a double from the tapped string")
                return
            }
            let newFillType: FillType = .imageSelection(
                recognizedText: text,
                scanResultId: scanResultId
            )
            
            doNotRegisterUserInput = true
            withAnimation {
                setNew(amount: value.amount, unit: value.unit?.energyUnit ?? .kcal)
                fieldValueViewModel.fieldValue.fillType = newFillType
            }
            
            withAnimation {
                fieldValueViewModel.isCroppingNextImage = true
            }
        }
        .onDisappear {
            guard fieldValueViewModel.isCroppingNextImage else {
                return
            }
            fieldValueViewModel.cropFilledImage()
            doNotRegisterUserInput = false
        }
    }
}
 
//MARK: - Helpers

extension EnergyForm {
    var fieldValue: FieldValue {
        fieldValueViewModel.fieldValue
    }
    
    var unitChangeShouldRegisterAsUserInput: Bool {
        
        if let energyValue = fieldValue.fillType.energyValue {
            /// If it does not have an energy unit, then a unit change should not register as user input
            return energyValue.unit?.isEnergy == true
        }
        return true
    }
}

//MARK: - Actions

extension EnergyForm {
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .chooseText:
            didTapChooseButton()
        case .fillType(let fillType):
            Haptics.feedback(style: .rigid)
            didTapFillTypeButton(for: fillType)
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

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            doNotRegisterUserInput = false
//        }
        
//        resetIsFillingTask?.cancel()
//        resetIsFillingTask = getResetIsFillingTask
//        Task(priority: .medium) {
//            do {
//                let _ = try await resetIsFillingTask!.value
//            } catch {
//                print("🧵 Error in resetIsFillingTask: \(error)")
//            }
//        }
    }
    
    var getResetIsFillingTask: Task<(), Error> {
        Task(priority: .medium) {
            do {
                /// This delay is crucial—because otherwise `isFilling` gets set to `false` too soon (before the `onChange` triggers for `string` and `energyUnit` are called—thus registering them incorrectly as `.userInput` fillTypes
                print("🧵 Runing resetisFillingTask, sleeping...")
                try await sleepTask(2)
                print("🧵 Checking for cancellation")
                try Task.checkCancellation()
                print("🧵 Setting isFilling to false")
                doNotRegisterUserInput = false
            } catch {
                print("🧵 Error in getResetIsFillingTask task: \(error)")
            }
        }
    }
    
    func setNew(amount: Double, unit: EnergyUnit) {
        fieldValueViewModel.fieldValue.energyValue.string = amount.cleanAmount
//        fieldValueViewModel.fieldValue.double = amount
        fieldValueViewModel.fieldValue.energyValue.unit = unit
//        string = amount.cleanAmount
//        energyUnit = unit
    }
    
    func setNewValue(_ value: FoodLabelValue) {
        setNew(amount: value.amount, unit: value.unit?.energyUnit ?? .kcal)
        //        fieldValueViewModel.fieldValue.double = value.amount
        //        fieldValueViewModel.fieldValue.nutritionUnit = value.unit
        //        string = value.amount.cleanAmount
        //        energyUnit = value.unit?.energyUnit ?? .kcal
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
        /// No need to recrop images here because this only occurs when altValues of a selection value are tapped (new selections can only be made through the `TextPicker`, and the cropping is handled there)
//        fieldValueViewModel.isCroppingNextImage = true
//        fieldValueViewModel.cropFilledImage()
    }

    //MARK: TextPicker
    
    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == fieldValue.fillType.scanResultId })
    }
}

//MARK: - Preview

struct EnergyFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        EnergyForm(fieldValueViewModel: viewModel.energyViewModel)
            .environmentObject(viewModel)
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        EnergyFormPreview()
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
