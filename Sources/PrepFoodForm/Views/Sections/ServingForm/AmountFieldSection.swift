import SwiftUI
import PrepUnits

extension FoodForm.NutrientsPerForm {
    struct AmountFieldSection: View {
        @EnvironmentObject var viewModel: FoodForm.ViewModel
        @State var showingAmountUnits = false
        @State var showingSizes = false
    }
}

extension FoodForm.NutrientsPerForm.AmountFieldSection {
    
    var body: some View {
        Section(header: header, footer: footer) {
            HStack(spacing: 0) {
                textField
                unitButton
            }
        }
        .sheet(isPresented: $showingAmountUnits) {
            Text("Amount units")
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingSizes) {
            Text("Sizes")
                .presentationDetents([.medium])
        }
    }
    
    var textField: some View {
        TextField("Required", text: $viewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var unitButton: some View {
        Button {
            viewModel.path.append(.amountUnitSelector)
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.amountUnitShortString)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var header: some View {
        Text("Amount")
    }
    
    var footer: some View {
        Text("This is how much of this food the nutritional values are for. You'll be able to log this food using the unit you choose.")
    }
}
