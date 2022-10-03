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
                guard !isFilling else { return }
                withAnimation {
                    fieldValueViewModel.fieldValue.energyValue.fillType = .userInput
                }
            }
            .onChange(of: energyUnit) { newValue in
                guard !isFilling, unitChangeShouldRegisterAsUserInput else { return }
                /// This will only trigger a change of the fillType to `.userInput`, if the `energyValue` of the text has an energy unit
                withAnimation {
                    fieldValueViewModel.registerUserInput()
                }
            }
            .onAppear {
                isFocused = true
            }
            .sheet(isPresented: $showingTextPicker) {
                textPicker
            }
    }
    
    var unitChangeShouldRegisterAsUserInput: Bool {
        if case .imageSelection(let text, _, _, let altValue) = fieldValue.fillType,
           let value = altValue ?? text.string.energyValue /// Look at either the altValue or the value extracted from the text to determine if there is a unit
        {
            
            if value.unit?.isEnergy == true {
                return true
            } else {
                /// If it does not have an energy unit, then a unit change should not register as user input
                return false
            }
        }
        return true
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
            FillOptionSections(fieldValueViewModel: fieldValueViewModel, didTapImage: {
                showingTextPicker = true
            }, didTapFillOption: { fillOption in
                didTapFillOption(fillOption)
            })
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
            changeFillTypeToSelection(of: text, withAltValue: value)
        case .imageAutofill(let valueText, scanResultId: _, value: let value):
            changeFillTypeToAutofill(of: valueText, withAltValue: value)
        default:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFilling = false
        }
    }
    
    func setNew(amount: Double, unit: EnergyUnit) {
        fieldValueViewModel.fieldValue.double = amount
        fieldValueViewModel.fieldValue.energyValue.unit = unit
        string = amount.cleanAmount
        energyUnit = unit
    }
    
    func setNewValue(_ value: Value) {
        setNew(amount: value.amount, unit: value.unit?.energyUnit ?? .kcal)
        //        fieldValueViewModel.fieldValue.double = value.amount
        //        fieldValueViewModel.fieldValue.nutritionUnit = value.unit
        //        string = value.amount.cleanAmount
        //        energyUnit = value.unit?.energyUnit ?? .kcal
    }
    
    func changeFillTypeToAutofill(of valueText: ValueText, withAltValue altValue: Value?) {
        let value = altValue ?? valueText.value
        setNewValue(value)
    }

    func changeFillTypeToSelection(of text: RecognizedText, withAltValue altValue: Value?) {
        guard let value = altValue ?? text.string.values.first else {
            return
        }
        setNewValue(value)
    }

    var form: some View {
        Form {
            textFieldSection
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
    
    //MARK: TextPicker
    
    var textPicker: some View {
        TextPicker(
            texts: viewModel.texts(for: fieldValueViewModel.fieldValue),
            selectedText: fieldValue.fillType.text,
            selectedBoundingBox: fieldValue.fillType.boundingBoxForImagePicker
            
        ) { text, scanResultId in
            
            guard let value = text.string.values.first else {
                print("Couldn't get a double from the tapped string")
                return
            }
            let newFillType: FillType = .imageSelection(
                recognizedText: text,
                scanResultId: scanResultId
            )
            
            isFilling = true
            withAnimation {
                setNew(amount: value.amount, unit: value.unit?.energyUnit ?? .kcal)
                fieldValueViewModel.fieldValue.fillType = newFillType
            }
            
            withAnimation {
                fieldValueViewModel.cropImageOnTextPickerDismissal = true
            }
        }
        .environmentObject(viewModel)
        .onDisappear {
            guard fieldValueViewModel.cropImageOnTextPickerDismissal else {
                return
            }
            fieldValueViewModel.cropFilledImage()
            isFilling = false
//            fieldValueViewModel.cropImageOnTextPickerDismissal = false
        }
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
    
    var values: [Value] {
        Value.detect(in: self)
    }
}

