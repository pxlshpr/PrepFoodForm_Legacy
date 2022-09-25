import SwiftUI

extension FoodForm.NutritionFacts {
    struct FactForm: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var viewModel: FoodFormViewModel
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
        .toolbar { navigationTrailingContent }
        .toolbar { keyboardToolbarContents }
        .onAppear {
            isFocused = true
        }
        .onChange(of: factViewModel.amountString) { newValue in
            factViewModel.dataDidChange()
        }
        .onChange(of: factViewModel.unit) { newValue in
            factViewModel.dataDidChange()
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            removeButton
        }
    }

    var content: some View {
        form
    }

    var content_legacy: some View {
        VStack(spacing: 0) {
            form
            addButtons
        }
    }

    @ViewBuilder
    var removeButton: some View {
        if factViewModel.shouldShowDeleteButton {
            Button("Remove") {
                factViewModel.removeExistingFact()
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    var addButtons: some View {
        if factViewModel.shouldShowAddButton {
            VStack {
                FormPrimaryButton(title: "Add") {
                    factViewModel.add()
                    viewModel.showingMicronutrientsPicker = false
                }
                .buttonStyle(.borderless)
                .padding(.top)
                FormSecondaryButton(title: "Add and Add Another") {
                    factViewModel.add()
                    dismiss()
                }
            }
            .background(Color(.systemGroupedBackground))
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
            Spacer()
            if factViewModel.shouldShowAddButton {
                Button("Add") {
                    factViewModel.add()
                    dismiss()
                }
            }
        }
    }
}
