import SwiftUI
import PrepUnits

extension FoodForm.ServingForm {
    struct ServingSizeFieldSection: View {
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

extension FoodForm.ServingForm.ServingSizeFieldSection {
    class Controller: ObservableObject {
        var viewModel: FoodForm.ViewModel
        init(viewModel: FoodForm.ViewModel) {
            self.viewModel = viewModel
        }
    }
}

extension FoodForm.ServingForm.ServingSizeFieldSection.Controller: UnitSelectorDelegate {
    func didPickUnit(unit: FormUnit) {
        withAnimation {
            viewModel.servingUnit = unit
        }
    }
}

extension FoodForm.ServingForm.ServingSizeFieldSection {
    
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
            FoodForm.ServingForm.UnitSelector(pickedUnit: viewModel.servingUnit, includeServing: false, delegate: controller)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }
    
    var textField: some View {
        TextField("", text: $viewModel.servingString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .placeholder(when: viewModel.servingString.isEmpty) {
                Text("Optional").foregroundColor(Color(.quaternaryLabel))
            }
    }
    
    var unitButton: some View {
        Button {
            showingUnitSelector = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.servingUnitShortString)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var header: some View {
        Text(viewModel.servingSizeHeaderString)
    }

    var footer: some View {
        Text(viewModel.servingSizeFooterString)
    }
}

extension FoodForm.ViewModel {
    var servingSizeHeaderString: String {
        switch servingUnit {
        case .weight:
            return "Serving Weight"
        case .volume:
            return "Serving Volume"
        case .size:
            return "Serving Size"
        case .serving:
            return "Unsupported"
        }
    }
    var servingSizeFooterString: String {
        switch servingUnit {
        case .weight:
            return "Enter this to also log this food using its weight."
        case .volume:
            return "Enter this to also log this food using its volume."
        case .size:
            return "Enter this to also log this food using its [insert unitType of size here]"
        case .serving:
            return "Unsupported"
        }
    }
}