import SwiftUI
import PrepUnits
import SwiftHaptics

struct MacronutrientForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
    @State var showingFillForm = false
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
        .sheet(isPresented: $showingFillForm) {
            FillForm()
        }
    }
    
    var form: some View {
        Form {
            HStack {
                textField
                unitLabel
                fillButton
            }
        }
    }
    
    @ViewBuilder
    var fillButton: some View {
        if viewModel.shouldShowFillButton {
            Button {
                Haptics.feedback(style: .soft)
                showingFillForm = true
            } label: {
                Image(systemName: fieldValue.macroValue.fillType.buttonSystemImage)
                    .imageScale(.large)
            }
            .buttonStyle(.borderless)
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
