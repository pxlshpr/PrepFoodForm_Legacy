import SwiftUI

extension FoodForm.AmountPerForm.SizeForm {
    struct Quantity: View {
        @ObservedObject var sizeViewModel: Field
        
        @Environment(\.dismiss) var dismiss
        @State var hasBecomeFirstResponder: Bool = false
    }
}

extension FoodForm.AmountPerForm.SizeForm.Quantity {
    
    var body: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack {
                    textField
                    stepper
                }
            }
        }
        .navigationTitle("Size Quantity")
        .navigationBarTitleDisplayMode(.large)
        .scrollDismissesKeyboard(.never)
        .introspectTextField(customize: introspectTextField)
        .toolbar { keyboardToolbarContents }
        .interactiveDismissDisabled(sizeViewModel.sizeQuantityString.isEmpty)
    }
    
    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
    func introspectTextField(_ uiTextField: UITextField) {
        guard !hasBecomeFirstResponder else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
        }
    }
    
    //MARK: - Components
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                dismiss()
            }
            .disabled(sizeViewModel.sizeQuantityString.isEmpty)
        }
    }

    var textField: some View {
        TextField("Required", text: $sizeViewModel.sizeQuantityString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }

    var stepper: some View {
        Stepper("", value: $sizeViewModel.sizeQuantity, in: 1...100000)
            .labelsHidden()
    }

    var header: some View {
        Text("Quantity")
//        Text(viewModel.amountUnit.unitType.description.lowercased())
    }
    
    var footer: some View {
        Text("""
This is used when nutritional labels display nutrients for more than a single serving or size.

For e.g. when the serving size reads '5 cookies (57g)', you would enter 5 as the quantity here. This allows us determine the nutrients for a single cookie.
"""
        )
        .foregroundColor(sizeViewModel.sizeQuantityString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
    

//    var quantiativeName: String {
//        "\(viewModel.quantityString) \(viewModel.name.isEmpty ? "of this size" : viewModel.name.lowercased())"
//    }
//
//    var description: String {
//        switch viewModel.amountUnit {
//        case .volume:
//            return "the volume of \(quantiativeName)"
//        case .weight:
//            return "how much \(quantiativeName) weighs"
//        case .serving:
//            return "how many servings \(quantiativeName) equals"
//        case .size:
//            return "how much of (insert size name here) \(quantiativeName) equals"
//        }
//    }
}
