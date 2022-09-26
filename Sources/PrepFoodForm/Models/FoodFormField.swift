import Foundation

extension FoodFormViewModel.FieldValue {
    enum Identifier {
        case name
        case detail
        
        var valueType: ValueType {
            switch self {
            case .name:
                return .string
            case .detail:
                return .string
            }
        }
        
        var isString: Bool {
            valueType == .string
        }
        
        var isDouble: Bool {
            valueType == .double
        }
    }
    
    enum ValueType {
        case string
        case double
    }
    
}

enum FieldFillType: Hashable {
    case userInput
    case imageSelection
    case imageAutofill
    case thirdPartyFoodPrefill
    
    var iconSystemImage: String {
        switch self {
        case .userInput:
            return "square.and.pencil"
        case .imageSelection:
            return "photo"
        case .imageAutofill:
            return "text.viewfinder"
        case .thirdPartyFoodPrefill:
            return "link"
        }
    }
    var buttonSystemImage: String {
        switch self {
        case .userInput:
            return "square.and.pencil.circle.fill"
        case .imageSelection:
            return "photo.circle.fill"
        case .imageAutofill:
            return "viewfinder.circle.fill"
        case .thirdPartyFoodPrefill:
            return "link.circle.fill"
        }
    }
}

extension FoodFormViewModel {
    struct FieldValue {
        let identifier: Identifier
        var string: String {
            didSet {
                if identifier.isDouble {
                    double = Double(string)
                }
            }
        }
        var double: Double?

        var fillType: FieldFillType
        var fillIdentifier: UUID?

        init(identifier: Identifier, string: String = "", double: Double? = nil, fillType: FieldFillType = .userInput, fillIdentifier: UUID? = nil) {
            self.identifier = identifier
            self.string = string
            self.double = double
            self.fillType = fillType
            self.fillIdentifier = fillIdentifier
        }
    }
}

extension FoodFormViewModel.FieldValue {
    var isEmpty: Bool {
        switch identifier.valueType {
        case .string:
            return string.isEmpty
        case .double:
            return double == nil
        }
    }
}
