import SwiftUI

struct OptionalNutrientForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
    @Binding var transientString: String
    
}

extension OptionalNutrientForm {
    var body: some View {
        form
        .scrollDismissesKeyboard(.never)
        .navigationTitle(fieldValue.description)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            isFocused = true
        }
    }
    
    var form: some View {
        Form {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    var textField: some View {
        TextField("Optional", text: $transientString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
    }
    
    var unitLabel: some View {
        Text(fieldValue.unitString)
            .foregroundColor(.secondary)
    }
    
    var units: [NutritionFactUnit] {
        fieldValue.identifier.supportedUnits
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            if units.count > 1 {
                Picker("", selection: $fieldValue.nutritionFactUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit.description).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
            Spacer()
            Button("Add") {
                dismiss()
//                fieldValue.string = transientString
            }
        }
    }
}
