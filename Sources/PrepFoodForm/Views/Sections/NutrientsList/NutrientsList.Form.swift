import SwiftUI

extension FoodForm.NutrientsList {
 
    struct Form: View {
        
        @State var amount: String
        @State var unit: String
        @State var title: String
        @State var units = ["g", "mg"]
        @FocusState var isFocused: Bool
    }
}

extension FoodForm.NutrientsList.Form {
    var body: some View {
        Form {
            HStack {
                TextField("Amount", text: $amount)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .interactiveDismissDisabled()
//                    .introspectTextField { textField in
//                        textField.becomeFirstResponder()
//                    }
                Picker("", selection: $unit) {
                    ForEach(units, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
        .scrollDismissesKeyboard(.never)
        .navigationTitle(title)
        .onAppear {
            isFocused = true
        }
    }
}
