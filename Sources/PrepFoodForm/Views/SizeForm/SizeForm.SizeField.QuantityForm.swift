import SwiftUI

extension SizeForm.SizeField {
    struct QuantityForm: View {
        @EnvironmentObject var sizeFormViewModel: SizeForm.ViewModel
    }
}

extension SizeForm.SizeField.QuantityForm {
    var body: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack {
                    textField
                    stepper
                }
            }
        }
        .navigationTitle("Quantity")
    }
    
    //MARK: - Components
    
    var textField: some View {
        TextField("Enter the quantity", text: $sizeFormViewModel.quantityString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }

    var stepper: some View {
        Stepper("", value: $sizeFormViewModel.quantity, in: 1...100000)
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
""")
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
