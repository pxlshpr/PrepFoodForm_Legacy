import Foundation
import PrepUnits

class NutritionFact: ObservableObject, Identifiable {
    var id = UUID()
    var type: NutritionFactType
    @Published var amount: Double?
    @Published var unit: NutritionFactUnit?
    @Published var fillType: FieldFillType
    
    init(id: UUID = UUID(), type: NutritionFactType, amount: Double? = nil, unit: NutritionFactUnit? = nil, fillType: FieldFillType = .userInput) {
        self.id = id
        self.type = type
        self.amount = amount
        self.unit = unit
        self.fillType = fillType
    }
    
    var isEmpty: Bool {
        amount == nil
        && unit == nil
    }
    
    var amountDescription: String? {
        guard let amount = amount, let unit = unit else {
            return nil
        }
        return "\(amount.clean) \(unit.description)"
    }
    
    func makeEmpty() {
        amount = nil
        unit = nil
    }
}

extension NutritionFact: Equatable {
    static func ==(lhs: NutritionFact, rhs: NutritionFact) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension NutritionFact: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(amount)
        hasher.combine(unit)
        hasher.combine(fillType)
    }
}
