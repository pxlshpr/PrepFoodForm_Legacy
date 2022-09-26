import SwiftUI
import PrepUnits

struct FieldValue: Hashable, Equatable {
    var identifier: FieldValueIdentifier
    var fillType: FieldFillType
    var fillIdentifier: UUID?

    //TODO: Associate fillIdentifier with fillType
    init(identifier: FieldValueIdentifier, fillType: FieldFillType = .userInput, fillIdentifier: UUID? = nil) {
        self.identifier = identifier
        self.fillType = fillType
        self.fillIdentifier = fillIdentifier
    }
    
    init(micronutrient: NutrientType, fillType: FieldFillType = .userInput, fillIdentifier: UUID? = nil) {
        self.identifier = .micro(micronutrient, nil, "", micronutrient.units.first ?? .g)
        self.fillType = fillType
        self.fillIdentifier = fillIdentifier
    }
}

extension FieldValue {
    var isEmpty: Bool {
        identifier.isEmpty
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
        identifier.amountString
    }
    
    var unitString: String {
        identifier.unitString
    }
}
