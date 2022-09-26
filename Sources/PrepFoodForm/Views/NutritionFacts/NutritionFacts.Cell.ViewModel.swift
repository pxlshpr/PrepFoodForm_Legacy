import SwiftUI

extension FoodForm.NutritionFacts.Cell {
    class ViewModel: ObservableObject {
        
        @Published var fieldValue: FieldValue
        @Environment(\.colorScheme) var colorScheme
        
        init(fieldValue: FieldValue) {
            self.fieldValue = fieldValue
        }
    }
}

extension FoodForm.NutritionFacts.Cell.ViewModel {
    var iconImageName: String {
        switch fieldValue.identifier {
        case .energy: return "flame.fill"
////            case .macro: return "circle.grid.cross"
////            case .micro: return "circle.hexagongrid"
//            case .energy: return "flame.circle.fill"
        case .macro: return "circle.circle.fill"
        case .micro: return "circle.circle"
        default:
            return ""
        }
    }
    
    var typeName: String {
        fieldValue.identifier.description
    }
    
    var isEmpty: Bool {
        fieldValue.isEmpty
    }
    
    var labelColor: Color {
        Color.red
//        isEmpty ? Color(.secondaryLabel) :  fact.type.textColor(for: colorScheme)
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    var fillTypeIconImage: String? {
        guard fieldValue.fillType != .userInput else {
            return nil
        }
        return fieldValue.fillType.iconSystemImage
    }
    
    var amountString: String {
        guard let amount = fieldValue.double else {
            if case .micro(_) = fieldValue.identifier {
                return ""
            } else {
                return "Required"
            }
        }
        return amount.cleanAmount
    }
    
    var unitString: String {
        "unit goes here"
//        fact.unit?.description ?? ""
    }
}
