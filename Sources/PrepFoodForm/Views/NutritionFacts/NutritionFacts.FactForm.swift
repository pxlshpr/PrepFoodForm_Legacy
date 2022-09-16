import SwiftUI

extension FoodForm.NutritionFacts {
    struct FactForm: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var viewModel: FoodForm.ViewModel
        @StateObject var factViewModel: ViewModel
        
        let type: NutritionFactType
        
        @FocusState var isFocused: Bool
        
        init(type: NutritionFactType, isNewMicronutrient: Bool = false) {
            
            self.type = type
            
            let fact = NutritionFact(type: type)
            let factViewModel = ViewModel(fact: fact, isNewMicronutrient: isNewMicronutrient)
            _factViewModel = StateObject(wrappedValue: factViewModel)
        }
    }
}

extension FoodForm.NutritionFacts.FactForm {
    var body: some View {
        content
        .scrollDismissesKeyboard(.never)
        .navigationTitle(type.description)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            isFocused = true
        }
        .onChange(of: factViewModel.amountString) { newValue in
            dataDidChange()
        }
        .onChange(of: factViewModel.unit) { newValue in
            dataDidChange()
        }
    }
    
    func dataDidChange() {
        factViewModel.dataDidChange()
        guard !factViewModel.isNewMicronutrient else { return }
        viewModel.setNutritionFactType(type, withAmount: factViewModel.amount, unit: factViewModel.unit)
    }
    
    var content: some View {
        VStack {
            form
            Spacer()
            if factViewModel.shouldShowAddButton {
                FormPrimaryButton(title: "Add") {
                    viewModel.path.removeLast()
                }
                FormSecondaryButton(title: "Add and Add Another") {
                    dismiss()
                }
            }
        }
    }
    
    var form: some View {
        Form {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $factViewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
    }
    
    var unitLabel: some View {
        Text(factViewModel.unit.description)
            .foregroundColor(.secondary)
    }
    
    var units: [NutritionFactUnit] {
        type.supportedUnits
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            if units.count > 1 {
                Picker("", selection: $factViewModel.unit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit.description).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
