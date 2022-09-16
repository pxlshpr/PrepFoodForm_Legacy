import SwiftUI

extension FoodForm.NutritionFacts.Cell {
    class ViewModel: ObservableObject {
        
        @Published var nutritionFactType: NutritionFactType
        @Published var nutritionFact: NutritionFact?
        @Environment(\.colorScheme) var colorScheme
        
        init(nutritionFactType: NutritionFactType, nutritionFact: NutritionFact? = nil) {
            self.nutritionFactType = nutritionFactType
            self.nutritionFact = nutritionFact
        }
    }
}

extension FoodForm.NutritionFacts.Cell.ViewModel {
    var iconImageName: String {
        switch nutritionFactType {
        case .energy: return "flame.fill"
////            case .macro: return "circle.grid.cross"
////            case .micro: return "circle.hexagongrid"
//            case .energy: return "flame.circle.fill"
        case .macro: return "circle.circle.fill"
        case .micro: return "circle.circle"
        }
    }
    
    var typeName: String {
        nutritionFactType.description
    }
    
    var isEmpty: Bool {
        nutritionFact == nil
    }
    var labelColor: Color {
        isEmpty ? Color(.secondaryLabel) :  nutritionFactType.textColor(for: colorScheme)
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    var inputTypeImageName: String? {
        guard let nutritionFact = nutritionFact, nutritionFact.inputType != .manuallyEntered else {
            return nil
        }
        return nutritionFact.inputType.image
    }
    
    var amountString: String {
        guard let nutritionFact = nutritionFact else {
            if case .micro(_) = nutritionFactType {
                return ""
            } else {
                return "Required"
            }
        }
        return nutritionFact.amount.cleanAmount
    }
    
    var unitString: String {
        nutritionFact?.unit.description ?? ""
    }
}
