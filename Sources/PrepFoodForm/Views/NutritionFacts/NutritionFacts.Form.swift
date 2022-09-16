import SwiftUI

extension FoodForm.NutritionFacts.FactForm {
    class ViewModel: ObservableObject {
        
        @Published var amountString: String
        @Published var unit: NutritionFactUnit
        
        init(nutritionFact: NutritionFact? = nil) {
            guard let nutritionFact = nutritionFact else {
                self.amountString = ""
                self.unit = .g
                return
            }
            self.amountString = nutritionFact.amount.cleanAmount
            self.unit = nutritionFact.unit
        }
    }
}

extension FoodForm.NutritionFacts.FactForm.ViewModel {
    
}

extension FoodForm.NutritionFacts {
    struct FactForm: View {

        @ObservedObject var viewModel: FoodForm.ViewModel
        @StateObject var factViewModel: ViewModel
        let nutritionFactType: NutritionFactType
        
        @FocusState var isFocused: Bool
        
        init(nutritionFactType: NutritionFactType, foodFormViewModel: FoodForm.ViewModel) {
            self.nutritionFactType = nutritionFactType
            _viewModel = ObservedObject(wrappedValue: foodFormViewModel)
            let nutritionFact = foodFormViewModel.nutritionFact(for: nutritionFactType)
            _factViewModel = StateObject(wrappedValue: ViewModel(nutritionFact: nutritionFact))
        }
    }
}

extension FoodForm.NutritionFacts.FactForm {
    var body: some View {
        Form {
            HStack {
                textField
                unitButton
            }
        }
        .scrollDismissesKeyboard(.never)
        .navigationTitle(nutritionFactType.description)
        .onAppear {
            isFocused = true
        }
    }
    
    var textField: some View {
        TextField("Required", text: $factViewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
    }
    
    var unitButton: some View {
        Button {
        } label: {
            HStack(spacing: 5) {
                Text(factViewModel.unit.description)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
}
