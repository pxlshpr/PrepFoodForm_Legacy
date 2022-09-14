import SwiftUI

extension SizeForm.SizeField {
    struct AmountForm: View {        
        @EnvironmentObject var sizeFormViewModel: SizeForm.ViewModel
    }
}

extension SizeForm.SizeField.AmountForm {
    var body: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack {
                    textField
                    unitButton
                }
            }
        }
        .navigationTitle("Amount")
    }
    
    //MARK: - Components
    
    var textField: some View {
        TextField("Required", text: $sizeFormViewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var unitButton: some View {
        Button {
            sizeFormViewModel.path.append(.amountUnit)
        } label: {
            HStack(spacing: 5) {
                Text(sizeFormViewModel.amountUnit.shortDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var header: some View {
        Text(sizeFormViewModel.amountUnit.unitType.description.lowercased())
    }
    
    @ViewBuilder
    var footer: some View {
        Text("\(sizeFormViewModel.amountIsValid ? "This is" : "Enter") \(description).")
    }
    
    //MARK: - Helpers
    
    var quantiativeName: String {
        "\(sizeFormViewModel.quantityString) \(sizeFormViewModel.name.isEmpty ? "of this size" : sizeFormViewModel.name.lowercased())"
    }
    
    var description: String {
        switch sizeFormViewModel.amountUnit {
        case .volume:
            return "the volume of \(quantiativeName)"
        case .weight:
            return "how much \(quantiativeName) weighs"
        case .serving:
            return "how many servings \(quantiativeName) equals"
        case .size(let size, let volumePrefixUnit):
            //TODO: prefix name here with volumePrefixUnit
            return "how many \(size.prefixedName) \(quantiativeName) equals"
        }
    }
}
