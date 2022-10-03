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
    
    @StateObject var fieldFormViewModel = FieldFormViewModel()
    @Binding var fieldValue: FieldValue
    
    @State var string: String
    @State var energyUnit: EnergyUnit

    @State var showingFilledText = false
    
    init(fieldValue: Binding<FieldValue>) {
        _fieldValue = fieldValue
        _string = State(initialValue: fieldValue.wrappedValue.energyValue.string)
        _energyUnit = State(initialValue: fieldValue.wrappedValue.energyValue.unit)
    }
}

extension EnergyForm {
    
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .onChange(of: string) { newValue in
                withAnimation {
                    viewModel.energy.energyValue.fillType = .userInput
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
                fieldFormViewModel.getCroppedImage(for: fieldValue.fillType)
            }
            .onChange(of: fieldValue.fillType) { newValue in
                fieldFormViewModel.getCroppedImage(for: newValue)
            }
            .sheet(isPresented: $fieldFormViewModel.showingImageTextPicker) {
                imageTextPicker
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
            .onChange(of: fieldValue) { newValue in
                guard !fieldFormViewModel.ignoreNextChange else {
                    fieldFormViewModel.ignoreNextChange = false
                    return
                }
                withAnimation {
                    fieldValue.fillType = .userInput
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
            FillOptionSections(fieldValue: $viewModel.energy)
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
                .environmentObject(fieldFormViewModel)
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
                FillOptionsBar(fieldValue: $fieldValue)
                    .environmentObject(fieldFormViewModel)
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
            
            fieldFormViewModel.showingImageTextPicker = false
            
            var newFieldValue = fieldValue
            newFieldValue.energyValue.double = text.string.double
            newFieldValue.fillType = .imageSelection(recognizedText: text, scanResultId: scanResultId)

            fieldFormViewModel.ignoreNextChange = true
            withAnimation {
                fieldValue = newFieldValue
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
        EnergyForm(fieldValue: $viewModel.energy)
            .environmentObject(viewModel)
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        EnergyFormPreview()
    }
}

//MARK: - FieldFormViewModel

class FieldFormViewModel: ObservableObject {
    @Published var showingImageTextPicker: Bool = false
    @Published var ignoreNextChange: Bool = false
    @Published var imageToDisplay: UIImage? = nil
    @Published var shouldShowImage: Bool = false

    func getCroppedImage(for fillType: FillType) {
        guard fillType.usesImage else {
            withAnimation {
                imageToDisplay = nil
                shouldShowImage = false
            }
            return
        }
        Task {
            let croppedImage = await FoodFormViewModel.shared.croppedImage(for: fillType)

            await MainActor.run {
                withAnimation {
                    self.imageToDisplay = croppedImage
                    self.shouldShowImage = true
                }
            }
        }
    }
}

//MARK: - String + Double

extension String {
    var double: Double? {
        guard let doubleString = capturedGroups(using: #"(?:^|[ ]+)([0-9.,]+)"#, allowCapturingEntireString: true).last else {
            return nil
        }
        return Double(doubleString)
    }
}

