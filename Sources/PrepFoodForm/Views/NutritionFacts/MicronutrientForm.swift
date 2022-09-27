import SwiftUI
import PrepUnits

struct MicronutrientForm: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
    @State var isBeingEdited: Bool
    var didSubmit: ((String, NutrientUnit) -> ())
    
    @State var string: String = ""
    @State var nutrientUnit: NutrientUnit = .g
    
    init(fieldValue: Binding<FieldValue>, isBeingEdited: Bool = false, didSubmit: @escaping ((String, NutrientUnit) -> ())) {
        _fieldValue = fieldValue
        _isBeingEdited = State(initialValue: isBeingEdited)
        self.didSubmit = didSubmit
    }
}

extension MicronutrientForm {
    var body: some View {
        form
        .scrollDismissesKeyboard(.never)
        .navigationTitle(fieldValue.description)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            isFocused = true
            string = fieldValue.string
            nutrientUnit = fieldValue.nutrientUnit
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
        TextField("Optional", text: $string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
    }
    
    var unitLabel: some View {
        Text(nutrientUnit.shortDescription)
            .foregroundColor(.secondary)
    }
    
    var units: [NutrientUnit] {
        fieldValue.supportedNutrientUnits
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            if units.count > 1 {
                Picker("", selection: $nutrientUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit.shortDescription).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
            Spacer()
            Button(isBeingEdited ? "Save" : "Add") {
                didSubmit(string, nutrientUnit)
                dismiss()
            }
        }
    }
}
