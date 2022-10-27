import SwiftUI
import SwiftUISugar

extension FoodForm.NutrientsList {
    struct EnergyForm: View {
        @Binding var fieldValue: FieldValue
        
        @State var doNotRegisterUserInput: Bool
        @FocusState var isFocused: Bool
        
        let placeholderString: String = "Required"
        
        init(fieldValue: Binding<FieldValue>) {
            _fieldValue = fieldValue
            let haveValue = !fieldValue.wrappedValue.string.isEmpty
            _doNotRegisterUserInput = State(initialValue: haveValue)
        }
    }
}

extension FoodForm.NutrientsList.EnergyForm {
    var body: some View {
        content
            .navigationTitle("Energy")
//            .navigationTitle(titleString ?? fieldValue.description)
//            .fullScreenCover(isPresented: $showingTextPicker) { textPicker }
        .onAppear {
            isFocused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                shouldAnimateOptions = true
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag
                /// in case it was set (due to a value already being present)
                doNotRegisterUserInput = false
            }
        }
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
//            supplementaryViewSection
//            fillOptionsSections
        }
    }
    
    //MARK: - TextField
    
    var textFieldSection: some View {
        @ViewBuilder
        var footer: some View {
//            if let footerString {
//                Text(footerString)
//            } else {
                defaultFooter
//            }
        }
        
        return Group {
//            if let headerString {
//                FormStyledSection(header: Text(headerString), footer: footer) {
//                    HStack {
//                        textField
//                        unitView
//                    }
//                }
//            } else {
                FormStyledSection(footer: footer) {
                    HStack {
                        textField
//                        unitView
                    }
                }
//            }
        }
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { fieldValue.string },
            set: {
                if !doNotRegisterUserInput, isFocused, $0 != fieldValue.string {
                    withAnimation {
//                        fieldViewModel.registerUserInput()
                    }
                }
                fieldValue.string = $0
            }
        )
        
        return TextField(placeholderString, text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(textFieldFont)
            .if(isForDecimalValue) { view in
                view
                    .keyboardType(.decimalPad)
                    .frame(minHeight: 50)
            }
            .if(!isForDecimalValue) { view in
                view
                    .lineLimit(1...3)
            }
            .scrollDismissesKeyboard(.interactively)
    }
    
    var defaultFooter: some View {
        var string: String {
//            let autofillString = viewModel.shouldShowFillOptions(for: fieldViewModel.fieldValue) ? "or autofill " : ""
//            return "Enter \(autofillString)a value"
            return "Enter a value"
        }

        return Group {
            if !isForDecimalValue {
                EmptyView()
            } else {
                Text(string)
            }
        }
    }
    
    //MARK: - Convenience
    var textFieldFont: Font {
        guard isForDecimalValue else {
            return .body
        }
        return fieldValue.string.isEmpty ? .body : .largeTitle
    }

    var isForDecimalValue: Bool {
        fieldValue.usesValueBasedTexts
    }

}
