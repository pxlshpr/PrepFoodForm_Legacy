import SwiftUI

extension SizeForm {
    struct AmountForm: View {        
        @StateObject var viewModel: SizeForm.ViewModel
    }
}

extension SizeForm.AmountForm {
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
    
    var textField: some View {
        TextField("Required", text: $viewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var header: some View {
        Text(viewModel.amountUnit.unitType.description.lowercased())
    }
    
    var footer: some View {
        let nameComponent = "\(viewModel.quantityString) \(viewModel.name.isEmpty ? "of this size" : viewModel.name.lowercased())"
        return Text("This is how much \(nameComponent) equals.")
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

}
