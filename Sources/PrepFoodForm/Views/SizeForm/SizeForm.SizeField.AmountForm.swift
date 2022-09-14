import SwiftUI

extension SizeForm.SizeField {
    struct AmountForm: View {        
        @StateObject var viewModel: SizeForm.ViewModel
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
        TextField("Required", text: $viewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var unitButton: some View {
        Button {
            viewModel.path.append(.amountUnit)
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.amountUnit.shortDescription)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var header: some View {
        Text(viewModel.amountUnit.unitType.description.lowercased())
    }
    
    @ViewBuilder
    var footer: some View {
        Text("\(viewModel.amountIsValid ? "This is" : "Enter") \(description).")
    }
    
    //MARK: - Helpers
    
    var quantiativeName: String {
        "\(viewModel.quantityString) \(viewModel.name.isEmpty ? "of this size" : viewModel.name.lowercased())"
    }
    
    var description: String {
        switch viewModel.amountUnit {
        case .volume:
            return "the volume of \(quantiativeName)"
        case .weight:
            return "how much \(quantiativeName) weighs"
        case .serving:
            return "how many servings \(quantiativeName) equals"
        case .size:
            return "how much of (insert size name here) \(quantiativeName) equals"
        }
    }
}
