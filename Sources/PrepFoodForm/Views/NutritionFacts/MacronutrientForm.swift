import SwiftUI
import PrepUnits
import SwiftHaptics

struct MacronutrientForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @StateObject var fieldFormViewModel = FieldFormViewModel()
    @Binding var fieldValue: FieldValue
//    @State var showingImageTextPicker = false
}

extension MacronutrientForm {
    var body: some View {
        form
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .toolbar { keyboardToolbarContents }
            .onAppear {
                isFocused = true
            }
            .sheet(isPresented: $fieldFormViewModel.showingImageTextPicker) {
                ImageTextPicker(selectedTextId: fieldValue.fillType.valueText?.text.id)
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
    }
    
    var form: some View {
        Form {
            textFieldSection
            FilledImageSection(fieldValue: $fieldValue)
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 50)
        }
    }
    
    var textFieldSection: some View {
        Section(fieldValue.fillType.sectionHeaderString) {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $fieldValue.macroValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
            .font(.largeTitle)
    }
    
    var unitLabel: some View {
        Text(fieldValue.macroValue.unitDescription)
            .foregroundColor(.secondary)
            .font(.title3)
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack(spacing: 0) {
                FillOptionsBarNew(fieldValue: $fieldValue)
                    .environmentObject(fieldFormViewModel)
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity)
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
