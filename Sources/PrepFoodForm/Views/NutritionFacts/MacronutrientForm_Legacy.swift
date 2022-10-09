import SwiftUI
struct MacronutrientForm_Legacy: View {
    @Binding var fieldViewModel: FieldViewModel
    var body: some View {
        Color.blue
    }
}

//import SwiftUI
//import PrepUnits
//import SwiftHaptics
//
//struct MacronutrientForm: View {
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    @Environment(\.dismiss) var dismiss
//    @FocusState var isFocused: Bool
//
//    @StateObject var fieldFormViewModel = FieldViewModel()
//    @Binding var fieldValue: FieldValue
//}
//
//extension MacronutrientForm {
//    var body: some View {
//        content
//            .scrollDismissesKeyboard(.never)
//            .navigationTitle(fieldValue.description)
//            .toolbar { keyboardToolbarContents }
//            .onAppear {
//                isFocused = true
//                fieldFormViewModel.getCroppedImage(for: fieldValue.fill)
//            }
//            .onChange(of: fieldValue.fill) { newValue in
//                fieldFormViewModel.getCroppedImage(for: newValue)
//            }
//            .sheet(isPresented: $fieldFormViewModel.showingImageTextPicker) {
//                imageTextPicker
//                    .presentationDetents([.medium, .large])
//                    .presentationDragIndicator(.hidden)
//            }
//            .onChange(of: fieldValue) { newValue in
//                guard !fieldFormViewModel.ignoreNextChange else {
//                    fieldFormViewModel.ignoreNextChange = false
//                    return
//                }
//                withAnimation {
//                    fieldValue.fill = .userInput
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
//        TextField("Required", text: $fieldValue.macroValue.string)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//            .focused($isFocused)
//            .interactiveDismissDisabled()
//            .font(.largeTitle)
//    }
//
//    var unitLabel: some View {
//        Text(fieldValue.macroValue.unitDescription)
//            .foregroundColor(.secondary)
//            .font(.title3)
//    }
//
//    var keyboardToolbarContents: some ToolbarContent {
//        ToolbarItemGroup(placement: .keyboard) {
//            HStack(spacing: 0) {
//                FillOptionsBar(fieldValue: $fieldValue)
//                    .environmentObject(fieldFormViewModel)
//                    .environmentObject(viewModel)
//                    .frame(maxWidth: .infinity)
//                Spacer()
//                Button("Done") {
//                    dismiss()
//                }
//            }
//        }
//    }
//
//    var imageTextPicker: some View {
//        ImageTextPicker(fill: fieldValue.fill) { text, scanResultId in
//
//            fieldFormViewModel.showingImageTextPicker = false
//
//            var newFieldValue = fieldValue
//            newFieldValue.macroValue.double = text.string.double
//            newFieldValue.fill = .scanSelection(recognizedText: text, scanResultId: scanResultId)
//
//            fieldFormViewModel.ignoreNextChange = true
//            withAnimation {
//                fieldValue = newFieldValue
//            }
//        }
//        .environmentObject(viewModel)
//    }
//}
