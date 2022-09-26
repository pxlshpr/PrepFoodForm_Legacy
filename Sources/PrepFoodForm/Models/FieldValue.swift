import SwiftUI
import PrepUnits

struct FieldValue: Hashable, Equatable {
    let identifier: FieldValueIdentifier
    var string: String {
        didSet {
            if identifier.usesDouble {
                double = Double(string)
            }
        }
    }
    var double: Double?
    var nutritionFactUnit: NutritionFactUnit

    var fillType: FieldFillType
    var fillIdentifier: UUID?

    init(identifier: FieldValueIdentifier, string: String = "", double: Double? = nil, nutritionFactUnit: NutritionFactUnit? = nil, fillType: FieldFillType = .userInput, fillIdentifier: UUID? = nil) {
        self.identifier = identifier
        self.string = string
        self.double = double
        self.fillType = fillType
        self.fillIdentifier = fillIdentifier
        
        if let unit = nutritionFactUnit {
            self.nutritionFactUnit = unit
        } else {
            self.nutritionFactUnit = identifier.defaultUnit
        }
    }
}

extension FieldValue {
    var isEmpty: Bool {
        switch identifier.valueType {
        case .string:
            return string.isEmpty
        case .double:
            return double == nil
        case .nutrient:
            return double == nil
        }
    }
}


extension FieldValue: CustomStringConvertible {
    var description: String {
        identifier.description
    }
    
    var amountColor: Color {
        isEmpty ? Color(.quaternaryLabel) : Color(.label)
    }

    var fillTypeIconImage: String? {
        guard identifier.valueType == .nutrient else {
            return fillType.iconSystemImage
        }
        guard fillType != .userInput else {
            return nil
        }
        return fillType.iconSystemImage
    }

    func labelColor(for colorScheme: ColorScheme) -> Color {
        isEmpty ? Color(.secondaryLabel) :  identifier.textColor(for: colorScheme)
    }
    
    var amountString: String {
        guard let amount = double else {
            if case .micro(_) = identifier {
                return ""
            } else {
                return "Required"
            }
        }
        return amount.cleanAmount
    }
    
    var unitString: String {
        nutritionFactUnit.description
//        nutritionFactUnit?.description ?? ""
    }
}
