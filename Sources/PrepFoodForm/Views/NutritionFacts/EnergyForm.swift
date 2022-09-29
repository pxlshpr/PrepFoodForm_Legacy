import SwiftUI
import PrepUnits
import SwiftHaptics
import NutritionLabelClassifier
import VisionSugar

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

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @StateObject var fieldFormViewModel = FieldFormViewModel()
    @Binding var fieldValue: FieldValue
}

extension String {
    var double: Double? {
        guard let doubleString = capturedGroups(using: #"(?:^|[ ]+)([0-9.,]+)"#, allowCapturingEntireString: true).last else {
            return nil
        }
        return Double(doubleString)
    }
}

extension EnergyForm {
    
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .toolbar { keyboardToolbarContents }
            .onAppear {
                isFocused = true
                fieldFormViewModel.getCroppedImage(for: fieldValue.fillType)
            }
            .onChange(of: fieldValue.fillType) { newValue in
                fieldFormViewModel.getCroppedImage(for: newValue)
            }
            .sheet(isPresented: $fieldFormViewModel.showingImageTextPicker) {
                ImageTextPicker(fillType: fieldValue.fillType) { text, outputId in
                    
                    fieldFormViewModel.showingImageTextPicker = false
                    
                    var newFieldValue = fieldValue
                    newFieldValue.energyValue.double = text.string.double
                    newFieldValue.fillType = .imageSelection(recognizedText: text, outputId: outputId)

                    fieldFormViewModel.ignoreNextChange = true
                    withAnimation {
                        fieldValue = newFieldValue
//                        fieldValue.fillType = .imageSelection(recognizedText: text, outputId: outputId)
                    }
                }
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
    }
    
    var content: some View {
        ZStack {
            form
            VStack {
                Spacer()
//                if fieldFormViewModel.shouldShowImage && !fieldFormViewModel.showingImageTextPicker {
                    FilledImageButton()
                        .environmentObject(fieldFormViewModel)
//                        .transition(.move(edge: .bottom))
//                        .animation(.default, value: fieldFormViewModel.showingImageTextPicker)
//                }
            }
        }
    }
    
    var form: some View {
        Form {
            textFieldSection
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 50)
        }
    }
    
    var textFieldSection: some View {
//        Section(fieldValue.fillType.sectionHeaderString) {
        Section {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    @ViewBuilder
    var optionalSelectSection: some View {
        if fieldValue.energyValue.fillType.isImageSelection {
            Section {
                Button {
                    Haptics.feedback(style: .soft)
                    fieldFormViewModel.showingImageTextPicker = true
                    //TODO: Communicate this
                    //                    showingImageTextPicker = true
                } label: {
                    Text("Select another text")
                }
                .buttonStyle(.borderless)
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
//        Text(fieldValue.unitString)
//            .foregroundColor(.secondary)
//            .font(.title3)
        Picker("", selection: $fieldValue.energyValue.unit) {
            ForEach(EnergyUnit.allCases, id: \.self) { unit in
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
