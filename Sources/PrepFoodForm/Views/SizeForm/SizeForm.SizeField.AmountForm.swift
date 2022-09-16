import SwiftUI
import SwiftHaptics

extension SizeForm.SizeField {
    struct AmountForm: View {        
        @EnvironmentObject var foodFormViewModel: FoodForm.ViewModel
        @EnvironmentObject var sizeFormViewModel: SizeForm.ViewModel
        @State var showingUnitPickerForAmount = false
        @State var showingSizeForm = false
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
        .sheet(isPresented: $showingUnitPickerForAmount) {
            unitPickerForAmount
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    //MARK: - Components
    
    var unitPickerForAmount: some View {
        UnitPicker(
            sizes: foodFormViewModel.allSizes,
            pickedUnit: sizeFormViewModel.amountUnit,
            includeServing: sizeFormViewModel.includeServing,
            servingDescription: foodFormViewModel.servingDescription,
            allowAddSize: sizeFormViewModel.allowAddSize)
        {
            showingSizeForm = true
        } didPickUnit: { unit in
            sizeFormViewModel.amountUnit = unit
        }
        .sheet(isPresented: $showingSizeForm) {
            SizeForm(includeServing: foodFormViewModel.hasServing, allowAddSize: false) { size in
                withAnimation {
                    sizeFormViewModel.amountUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        Haptics.feedback(style: .rigid)
                        showingUnitPickerForAmount = false
                    }
                }
            }
            .environmentObject(sizeFormViewModel)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
    
    var textField: some View {
        TextField("Required", text: $sizeFormViewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
    }
    
    var unitButton: some View {
        Button {
//            sizeFormViewModel.path.append(.amountUnit)
            showingUnitPickerForAmount = true
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
            .foregroundColor(!sizeFormViewModel.amountIsValid ? FormFooterEmptyColor : FormFooterFilledColor)
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
        case .size(let size, _):
            //TODO: prefix name here with volumePrefixUnit
            return "how many \(size.prefixedName) \(quantiativeName) equals"
        }
    }
}
