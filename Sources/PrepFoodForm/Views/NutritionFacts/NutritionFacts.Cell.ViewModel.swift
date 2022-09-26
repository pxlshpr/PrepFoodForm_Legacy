import SwiftUI

extension FoodForm.NutritionFacts.Cell {
    class ViewModel: ObservableObject {
        
        @Published var fact: NutritionFact
        @Environment(\.colorScheme) var colorScheme
        
        init(fact: NutritionFact) {
            self.fact = fact
        }
    }
}

extension FoodForm.NutritionFacts.Cell.ViewModel {
    var iconImageName: String {
        switch fact.type {
        case .energy: return "flame.fill"
////            case .macro: return "circle.grid.cross"
////            case .micro: return "circle.hexagongrid"
//            case .energy: return "flame.circle.fill"
        case .macro: return "circle.circle.fill"
        case .micro: return "circle.circle"
        }
    }
    
    var typeName: String {
        fact.type.description
    }
    
    var isEmpty: Bool {
        fact.isEmpty
    }
    
    var labelColor: Color {
        isEmpty ? Color(.secondaryLabel) :  fact.type.textColor(for: colorScheme)
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    var fillTypeIconImage: String? {
        guard fact.fillType != .userInput else {
            return nil
        }
        return fact.fillType.iconSystemImage
    }
    
    var amountString: String {
        guard let amount = fact.amount else {
            if case .micro(_) = fact.type {
                return ""
            } else {
                return "Required"
            }
        }
        return amount.cleanAmount
    }
    
    var unitString: String {
        fact.unit?.description ?? ""
    }
}
