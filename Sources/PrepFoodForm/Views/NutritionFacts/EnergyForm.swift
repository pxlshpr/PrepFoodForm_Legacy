import SwiftUI
import PrepUnits
import SwiftHaptics
import FoodLabelScanner
import VisionSugar

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @StateObject var fieldFormViewModel = FieldFormViewModel()
    @Binding var fieldValue: FieldValue
    
    @State var showingFilledText = false
}

extension EnergyForm {
    
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
//            .toolbar { keyboardToolbarContents }
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
    
    var content: some View {
        ZStack {
            form
//            VStack {
//                Spacer()
//                FilledImageButton()
//                    .environmentObject(fieldFormViewModel)
//            }
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
            FillOptionsGrid()
            if showingFilledText {
                Text("Hello")
            }
        }
    }
    
    var filledImageSection: some View {
        Section("Filled Text") {
            FilledImageButton()
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
        TextField("Required", text: $fieldValue.energyValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
            .font(.largeTitle)
    }
    
    var unitLabel: some View {
        Picker("", selection: $fieldValue.energyValue.unit) {
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

struct EnergyFormPreview: View {
    
    @State var fieldValue = FieldValue.energy(FieldValue.EnergyValue(double: 105, string: "105", unit: .kcal, fillType: .thirdPartyFoodPrefill))
    
    @StateObject var viewModel = FoodFormViewModel()
    var body: some View {
        EnergyForm(fieldValue: $fieldValue)
            .environmentObject(viewModel)
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        EnergyFormPreview()
    }
}


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

extension String {
    var double: Double? {
        guard let doubleString = capturedGroups(using: #"(?:^|[ ]+)([0-9.,]+)"#, allowCapturingEntireString: true).last else {
            return nil
        }
        return Double(doubleString)
    }
}

