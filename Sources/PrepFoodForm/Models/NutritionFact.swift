import Foundation
import PrepUnits

enum NutritionFactUnit {
    case kcal
    case kj
    case g
    case mg
    case ug
}

extension NutritionFactUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .kcal:
            return "kcal"
        case .kj:
            return "kJ"
        case .g:
            return "g"
        case .mg:
            return "mg"
        case .ug:
            return "μ"
        }
    }
}

class NutritionFact: Identifiable {
    var id = UUID()
    var type: NutritionFactType
    var amount: Double
    var unit: NutritionFactUnit
    var inputType: NutritionFactInputType
    
    init(id: UUID = UUID(), type: NutritionFactType, amount: Double, unit: NutritionFactUnit, inputType: NutritionFactInputType) {
        self.id = id
        self.type = type
        self.amount = amount
        self.unit = unit
        self.inputType = inputType
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
        hasher.combine(inputType)
    }
}
