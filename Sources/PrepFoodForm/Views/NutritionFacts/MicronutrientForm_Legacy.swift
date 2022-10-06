import SwiftUI
struct MicronutrientForm_Legacy: View {
    @Binding var fieldValueViewModel: FieldValueViewModel
    @State var isBeingEdited: Bool
    var didSubmit: ((FieldValue) -> ())
    
    init(fieldValueViewModel: Binding<FieldValueViewModel>, isBeingEdited: Bool = false, didSubmit: @escaping ((FieldValue) -> ())) {
        _fieldValueViewModel = fieldValueViewModel
        _isBeingEdited = State(initialValue: isBeingEdited)
        self.didSubmit = didSubmit
    }

    var body: some View {
        Color.blue
    }
}

//import SwiftUI
//import PrepUnits
//
//struct MicronutrientForm: View {
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    @Environment(\.dismiss) var dismiss
//    @FocusState var isFocused: Bool
//
//    @StateObject var fieldFormViewModel = FieldValueViewModel()
//    @Binding var fieldValue: FieldValue
//
//    @State var isBeingEdited: Bool
//    var didSubmit: ((FieldValue) -> ())
//
//    @State var fieldValueCopy: FieldValue
//
////    @State var string: String = ""
////    @State var nutrientUnit: NutrientUnit = .g
////    @State var fillType: FillType = .userInput
//
//    init(fieldValue: Binding<FieldValue>, isBeingEdited: Bool = false, didSubmit: @escaping ((FieldValue) -> ())) {
//        _fieldValue = fieldValue
//        _isBeingEdited = State(initialValue: isBeingEdited)
//        self.didSubmit = didSubmit
//        _fieldValueCopy = State(initialValue: fieldValue.wrappedValue)
//    }
//}
//
//extension MicronutrientForm {
//    var body: some View {
//        content
//            .scrollDismissesKeyboard(.never)
//            .navigationTitle(fieldValue.description)
//            .toolbar { keyboardToolbarContents }
//            .onAppear {
//                isFocused = true
//
//                fieldFormViewModel.ignoreNextChange = true
//                fieldValueCopy = fieldValue
////                string = fieldValue.microValue.string
////                nutrientUnit = fieldValue.microValue.unit
////                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
////                    self.fieldFormViewModel.ignoreNextChange = false
////                }
////                fillType = fieldValue.fillType
//
//                fieldFormViewModel.getCroppedImage(for: fieldValue.fillType)
//            }
//            .onChange(of: fieldValueCopy.fillType) { newValue in
//                fieldFormViewModel.getCroppedImage(for: newValue)
//            }
//            .sheet(isPresented: $fieldFormViewModel.showingImageTextPicker) {
//                imageTextPicker
//                    .presentationDetents([.medium, .large])
//                    .presentationDragIndicator(.hidden)
//            }
//            .onChange(of: fieldValueCopy) { newValue in
//                guard !fieldFormViewModel.ignoreNextChange else {
//                    fieldFormViewModel.ignoreNextChange = false
//                    return
//                }
//                withAnimation {
//                    fieldValue.fillType = .userInput
//                }
//            }
//    }
//
//    var content: some View {
//        ZStack {
//            form
//            VStack {
//                Spacer()
//                CroppedImageButton()
//                    .environmentObject(fieldFormViewModel)
//            }
//        }
//    }
//
//    var form: some View {
//        Form {
//            textFieldSection
//        }
//        .safeAreaInset(edge: .bottom) {
//            Spacer().frame(height: 50)
//        }
//    }
//
//    var textFieldSection: some View {
//        Section {
//            HStack {
//                textField
//                unitLabel
//            }
//        }
//    }
//
//    var textField: some View {
//        TextField("Optional", text: $fieldValueCopy.microValue.string)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//            .focused($isFocused)
//            .font(.largeTitle)
//    }
//
//    @ViewBuilder
//    var unitLabel: some View {
//        if units.count > 1 {
//            Picker("", selection: $fieldValueCopy.microValue.nutrientType) {
//                ForEach(units, id: \.self) { unit in
//                    Text(unit.shortDescription).tag(unit)
//                }
//            }
//            .pickerStyle(.segmented)
//        } else {
//            Text(fieldValueCopy.microValue.unitDescription)
//                .foregroundColor(.secondary)
//                .font(.title3)
//        }
//    }
//
//    var units: [NutrientUnit] {
//        fieldValue.microValue.supportedNutrientUnits
//    }
//
//    var keyboardToolbarContents: some ToolbarContent {
//        ToolbarItemGroup(placement: .keyboard) {
//            FillOptionsBar(fieldValue: $fieldValueCopy)
//                .environmentObject(fieldFormViewModel)
//                .environmentObject(viewModel)
//                .frame(maxWidth: .infinity)
//            Spacer()
//            Button(isBeingEdited ? "Save" : "Add") {
//                didSubmit(fieldValueCopy)
//                dismiss()
//            }
//        }
//    }
//
//    var imageTextPicker: some View {
//        ImageTextPicker(fillType: fieldValueCopy.fillType) { text, scanResultId in
//
//            fieldFormViewModel.showingImageTextPicker = false
//
//            var newFieldValue = fieldValue
//            newFieldValue.microValue.double = text.string.double
//            newFieldValue.fillType = .imageSelection(recognizedText: text, scanResultId: scanResultId)
//
//            fieldFormViewModel.ignoreNextChange = true
//            withAnimation {
//                fieldValueCopy = newFieldValue
//                fieldFormViewModel.ignoreNextChange = true
//            }
//        }
//        .environmentObject(viewModel)
//    }
//}
