import SwiftUI
import PrepUnits
import SwiftHaptics

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
    
    @State var showingFillForm = false
}

extension EnergyForm {
    var body: some View {
        form
        .scrollDismissesKeyboard(.never)
        .navigationTitle(fieldValue.description)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            isFocused = true
        }
        .onChange(of: fieldValue.energyValue.string) { newValue in
            fieldValue.energyValue.fillType = .userInput
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
                Image(systemName: fieldValue.energyValue.fillType.buttonSystemImage)
                    .imageScale(.large)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var textField: some View {
        TextField("Required", text: $fieldValue.energyValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
    }
    
    var unitLabel: some View {
        Text(fieldValue.unitString)
            .foregroundColor(.secondary)
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Picker("", selection: $fieldValue.energyValue.unit) {
                ForEach(EnergyUnit.allCases, id: \.self) { unit in
                    Text(unit.shortDescription).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
    }
}
