import SwiftUI

extension FoodForm.NutritionFacts.FactForm {
    class ViewModel: ObservableObject {
        
        var type: NutritionFactType
        
        @Published var amountString: String
        @Published var unit: NutritionFactUnit
        
        init(fact: NutritionFact) {
            
            self.type = fact.type
            
            self.amountString = fact.amount?.cleanAmount ?? ""
            self.unit = fact.unit ?? .g
        }
    }
}

extension FoodForm.ViewModel {
    func setNutritionFactType(_ type: NutritionFactType, withAmount amount: Double, unit: NutritionFactUnit) {
        switch type {
        case .energy:
            energyFact.amount = amount
            energyFact.unit = unit
        case .macro(let macro):
            switch macro {
            case .carb:
                carbFact.amount = amount
                carbFact.unit = unit
            case .protein:
                proteinFact.amount = amount
                proteinFact.unit = unit
            case .fat:
                fatFact.amount = amount
                fatFact.unit = unit
            }
        case .micro(_):
            return
        }
    }
}

extension FoodForm.NutritionFacts.FactForm.ViewModel {
    var amount: Double {
        Double(amountString) ?? 0
    }
}

extension FoodForm.NutritionFacts {
    struct FactForm: View {
        @EnvironmentObject var viewModel: FoodForm.ViewModel
        @StateObject var factViewModel: ViewModel
        let type: NutritionFactType
        
        @FocusState var isFocused: Bool
        
        init(type: NutritionFactType) {
            
            self.type = type
            
            //TODO: We need to preload data
            let fact = NutritionFact(type: type)
            let factViewModel = ViewModel(fact: fact)
            _factViewModel = StateObject(wrappedValue: factViewModel)
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
        .navigationTitle(type.description)
        .onAppear {
            isFocused = true
        }
        .onChange(of: factViewModel.amountString) { newValue in
            print("amount is now: \(newValue)")
            viewModel.setNutritionFactType(type, withAmount: factViewModel.amount, unit: factViewModel.unit)
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
