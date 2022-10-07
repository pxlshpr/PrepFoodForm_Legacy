import SwiftUI

struct SizeQuantityForm: View {
    @ObservedObject var formViewModel: FieldValueViewModel
}

extension SizeQuantityForm {
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
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }
    
    //MARK: - Components
    
    var textField: some View {
        TextField("Enter the quantity", text: $formViewModel.sizeQuantityString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }

    var stepper: some View {
        Stepper("", value: $formViewModel.sizeQuantity, in: 1...100000)
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
        .foregroundColor(formViewModel.sizeQuantityString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
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
