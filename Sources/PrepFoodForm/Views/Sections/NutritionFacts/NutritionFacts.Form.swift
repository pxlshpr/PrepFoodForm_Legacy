import SwiftUI

extension FoodForm.NutritionFacts {
 
    struct AmountForm: View {
        
        @State var amount: String
        @State var unit: String
        @State var title: String
        @State var units = ["g", "mg"]
        @FocusState var isFocused: Bool
    }
}

extension FoodForm.NutritionFacts.AmountForm {
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
