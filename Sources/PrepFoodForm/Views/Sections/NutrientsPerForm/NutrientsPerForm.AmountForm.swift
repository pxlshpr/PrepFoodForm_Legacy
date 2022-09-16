import SwiftUI
import SwiftHaptics

extension FoodForm.NutrientsPerForm {
    struct AmountForm: View {
        @EnvironmentObject var viewModel: FoodForm.ViewModel
        @State var showingUnitPicker = false
        @State var showingSizeForm = false
    }
}

extension FoodForm.NutrientsPerForm.AmountForm {
    
    var body: some View {
        form
//        .navigationTitle("Amount")
    }
    
    var form: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack(spacing: 0) {
                    textField
                    unitButton
                }
            }
        }
        .sheet(isPresented: $showingUnitPicker) {
            UnitPicker(
                sizes: viewModel.allSizes,
                pickedUnit: viewModel.amountUnit
            ) {
                showingSizeForm = true
            } didPickUnit: { unit in
                withAnimation {
                    viewModel.amountUnit = unit
                }
            }
            .sheet(isPresented: $showingSizeForm) {
                SizeForm(includeServing: false, allowAddSize: false) { size in
                    withAnimation {
                        viewModel.amountUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            Haptics.feedback(style: .rigid)
                            showingUnitPicker = false
                        }
                    }
                }
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $viewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
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
        Text(viewModel.amountFormHeaderString)
    }
    
    @ViewBuilder
    var footer: some View {
        Text("This is how much of this food the nutritional values are for. You'll be able to log this food using the unit you choose.")
            .foregroundColor(viewModel.amountString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
}
