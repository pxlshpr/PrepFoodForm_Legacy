import SwiftUI
import FoodLabel
import PrepDataTypes

extension FoodForm {
    class Fields: ObservableObject {
        @Published var energy: Field
        
        init() {
            self.energy = .init(fieldValue: .energy())
        }
    }
}

extension FoodForm.Fields {
    var hasNutritionFacts: Bool {
        !energy.value.isEmpty
    }
}
