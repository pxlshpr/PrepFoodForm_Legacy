import SwiftUI
import PrepUnits
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUISugar

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
//    @Binding var fieldValue: FieldValue
    
    @State var string: String
    @State var energyUnit: EnergyUnit

    @State var showingFilledText = false
    @State var showingTextPicker = false
    
    init(fieldValueViewModel: FieldValueViewModel) {
        self.fieldValueViewModel = fieldValueViewModel
//        _fieldValue = fieldValue
        _string = State(initialValue: fieldValueViewModel.fieldValue.energyValue.string)
        _energyUnit = State(initialValue: fieldValueViewModel.fieldValue.energyValue.unit)
    }
    
    var fieldValue: FieldValue {
        fieldValueViewModel.fieldValue
    }
    
    @State var isFilling: Bool = false
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .onChange(of: string) { newValue in
                guard !isFilling else {
                    print("🔘 isFilling so not registering this 'string' change as .userInput")
                    return
                }
                print("🔘 !isFilling so registering this 'string' change as .userInput")
                withAnimation {
                    fieldValueViewModel.fieldValue.energyValue.fillType = .userInput
                }
            }
            .onChange(of: energyUnit) { newValue in
                guard !isFilling else {
                    print("🔘 isFilling so not registering this 'energyUnit' change as .userInput")
                    return
                }
                print("🔘 !isFilling so registering this 'energyUnit' change as .userInput")
                withAnimation {
                    fieldValueViewModel.fieldValue.energyValue.fillType = .userInput
                }
            }
            .onAppear {
                isFocused = true
            }
            .sheet(isPresented: $showingTextPicker) {
                imageTextPicker
            }
    }

    var header: some View {
        Text("Enter or auto-fill a value")
    }
    
    var content: some View {
        FormStyledScrollView {
            FormStyledSection(header: header) {
                HStack {
                    textField
                    unitLabel
                }
            }
            FillOptionSections(fieldValueViewModel: fieldValueViewModel) { fillOption in
                didTapFillOption(fillOption)
            }
                .environmentObject(viewModel)
        }
    }
    
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
        isFilling = true
        fieldValueViewModel.fieldValue.fillType = fillType
        switch fillType {
        case .imageSelection(let text, let scanResultId, let supplementaryTexts, let value):
            break
        case .imageAutofill(let valueText, scanResultId: _, value: let value):
            changeFillTypeToAutofill(of: valueText, withAltValue: value)
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFilling = false
        }
    }
    
    func setNewValue(_ value: Value) {
        fieldValueViewModel.fieldValue.double = value.amount
        fieldValueViewModel.fieldValue.nutritionUnit = value.unit
        string = value.amount.cleanAmount
        energyUnit = value.unit?.energyUnit ?? .kcal
    }
    
    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: Value?) {
        guard let altValue else {
            setNewValue(valueText.value)
            return
        }
        setNewValue(altValue)
    }

    var form: some View {
        Form {
            textFieldSection
//            filledImageSection
            fillOptionsSection
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 50)
        }
    }
    
    var fillOptionsSection: some View {
        Section {
//            FillOptionsGrid()
            if showingFilledText {
                Text("Hello")
            }
        }
    }
    
    var filledImageSection: some View {
        Section("Filled Text") {
            CroppedImageButton()
                .environmentObject(fieldValueViewModel)
        }
    }
    
    var textFieldSection: some View {
        Section {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
            .font(.largeTitle)
    }
    
    var unitLabel: some View {
        Picker("", selection: $energyUnit) {
            ForEach(EnergyUnit.allCases, id: \.self) { 
                unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)

    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack(spacing: 0) {
                FillOptionsBar(fieldValue: $fieldValueViewModel.fieldValue)
                    .environmentObject(fieldValueViewModel)
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    var imageTextPicker: some View {
        TextPicker(
            texts: viewModel.texts(for: fieldValueViewModel.fieldValue),
            selectedText: fieldValue.fillType.text
        ) { text, scanResultId in
            
            fieldValueViewModel.showingImageTextPicker = false
            
            var newFieldValue = fieldValue
            newFieldValue.energyValue.double = text.string.double
            newFieldValue.fillType = .imageSelection(recognizedText: text, scanResultId: scanResultId)

            fieldValueViewModel.ignoreNextChange = true
            withAnimation {
                fieldValueViewModel.fieldValue = newFieldValue
            }
        }
        .environmentObject(viewModel)
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

//MARK: - FieldFormViewModel

//MARK: - String + Double

extension String {
    var double: Double? {
        guard let doubleString = capturedGroups(using: #"(?:^|[ ]+)([0-9.,]+)"#, allowCapturingEntireString: true).last else {
            return nil
        }
        return Double(doubleString)
    }
}

