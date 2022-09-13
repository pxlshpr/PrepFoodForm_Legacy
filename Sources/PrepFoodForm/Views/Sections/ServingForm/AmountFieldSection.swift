import SwiftUI
import PrepUnits

extension FoodForm.ServingForm {
    struct AmountFieldSection: View {
        @ObservedObject var viewModel: FoodForm.ViewModel
        @StateObject var controller: Controller
        @State var showingUnitSelector = false
        @State var showingAmountUnits = false
        @State var showingSizes = false
        
        init(viewModel: FoodForm.ViewModel) {
            self.viewModel = viewModel
            _controller = StateObject(wrappedValue: Controller(viewModel: viewModel))
        }
    }
}


extension FoodForm.ServingForm.AmountFieldSection {
    class Controller: ObservableObject {
        var viewModel: FoodForm.ViewModel
        init(viewModel: FoodForm.ViewModel) {
            self.viewModel = viewModel
        }
    }
}

extension FoodForm.ServingForm.AmountFieldSection.Controller: UnitSelectorDelegate {
    func didPickUnit(unit: FormUnit) {
        withAnimation {
            viewModel.amountUnit = unit
        }
    }
}
extension FoodForm.ServingForm.AmountFieldSection {
    
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
        .sheet(isPresented: $showingUnitSelector) {
            UnitSelector(pickedUnit: viewModel.amountUnit, delegate: controller)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }
    
    var textField: some View {
        TextField("Required", text: $viewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var unitButton: some View {
        Button {
            showingUnitSelector = true
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
