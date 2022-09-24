import SwiftUI
import SwiftHaptics

extension FoodForm.NutrientsPerForm {
    struct ServingForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @State var showingUnitPicker = false
        @State var showingSizeForm = false
        @FocusState var isFocused
    }
}

extension FoodForm.NutrientsPerForm.ServingForm {
    
    var body: some View {
        form
            .navigationTitle("Serving Size")
            .onAppear {
                isFocused = true
            }
            .toolbar { keyboardToolbarContents }
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("Units") {
                showingUnitPicker = true
            }
        }
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
                pickedUnit: viewModel.servingUnit,
                includeServing: false)
            {
                showingSizeForm = true
            } didPickUnit: { unit in
                withAnimation {
                    if unit.isServingBased {
                        viewModel.modifyServingAmount(for: unit)
                    }
                    viewModel.servingUnit = unit
                }
            }
            .sheet(isPresented: $showingSizeForm) {
                SizeForm(includeServing: true, allowAddSize: false) { size in
                    withAnimation {
                        viewModel.servingUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
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
        TextField("", text: $viewModel.servingString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .placeholder(when: viewModel.servingString.isEmpty) {
                Text("Optional").foregroundColor(Color(.quaternaryLabel))
            }
            .focused($isFocused)
    }
    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
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
        Text(viewModel.servingFormHeaderString)
    }

    @ViewBuilder
    var footer: some View {
        Text(viewModel.servingSizeFooterString)
            .foregroundColor(viewModel.servingString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
}