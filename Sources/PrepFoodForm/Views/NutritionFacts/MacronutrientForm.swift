import SwiftUI
import PrepUnits
import SwiftHaptics

struct MacronutrientForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
}

extension MacronutrientForm {
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .toolbar { keyboardToolbarContents }
            .onAppear {
                isFocused = true
            }
    }
    
    var content: some View {
        ZStack {
            form
            VStack {
                Spacer()
                FillOptionsBar(fieldValue: $fieldValue)
                    .environmentObject(viewModel)
            }
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
    }
    
    var unitLabel: some View {
        Text(fieldValue.macroValue.unitDescription)
            .foregroundColor(.secondary)
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
    }
}
