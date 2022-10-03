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
    
    @Binding var fieldValueViewModel: FieldValueViewModel
//    @Binding var fieldValue: FieldValue
    
    @State var string: String
    @State var energyUnit: EnergyUnit

    @State var showingFilledText = false
    
    init(fieldValueViewModel: Binding<FieldValueViewModel>) {
        _fieldValueViewModel = fieldValueViewModel
//        _fieldValue = fieldValue
        _string = State(initialValue: fieldValueViewModel.wrappedValue.fieldValue.energyValue.string)
        _energyUnit = State(initialValue: fieldValueViewModel.wrappedValue.fieldValue.energyValue.unit)
    }
}

extension EnergyForm {
    
    var fieldValue: FieldValue {
        fieldValueViewModel.fieldValue
    }
    
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .onChange(of: string) { newValue in
                withAnimation {
                    fieldValueViewModel.fieldValue.energyValue.fillType = .userInput
                }
            }
        
//            .onChange(of: viewModel.energy.energyValue.double) { newValue in
//                string = newValue?.cleanAmount ?? ""
//            }

            .onChange(of: fieldValue.energyValue.unit) { newValue in
                withAnimation {
                    showingFilledText.toggle()

                }
            }
            .onAppear {
                isFocused = true
                fieldValueViewModel.getCroppedImage(for: fieldValue.fillType)
            }
            .onChange(of: fieldValue.fillType) { newValue in
                fieldValueViewModel.getCroppedImage(for: newValue)
            }
            .sheet(isPresented: $fieldValueViewModel.showingImageTextPicker) {
                imageTextPicker
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
            .onChange(of: fieldValue) { newValue in
                guard !fieldValueViewModel.ignoreNextChange else {
                    fieldValueViewModel.ignoreNextChange = false
                    return
                }
                withAnimation {
                    fieldValueViewModel.fieldValue.fillType = .userInput
                }
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
            FillOptionSections(fieldValue: $fieldValueViewModel.fieldValue)
                .environmentObject(viewModel)
        }
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
        ImageTextPicker(fillType: fieldValue.fillType) { text, scanResultId in
            
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
        EnergyForm(fieldValueViewModel: $viewModel.energyViewModel)
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

