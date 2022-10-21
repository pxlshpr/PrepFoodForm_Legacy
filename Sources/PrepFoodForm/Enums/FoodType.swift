import Foundation

public enum FoodVerificationStatus: Int16, Codable {
    case pending = 1
    case verified
    case rejected
}

public enum FoodDatabase: Int16, Codable {
    case usda = 1
    case foodb
    case australianFoodCompositionDatabase
}

public enum FoodType: Codable {
    case userPublic(FoodVerificationStatus)
    case userPrivate
    case foodDatabase(FoodDatabase)
    
    public var serverInt: Int16 {
        switch self {
        case .userPublic:   return 1
        case .userPrivate:  return 2
        case .foodDatabase: return 3
        }
    }
    
    public var verificationStatusServerInt: Int16? {
        guard case .userPublic(let foodVerificationStatus) = self else {
            return nil
        }
        return foodVerificationStatus.rawValue
    }
    
    public var databaseServerInt: Int16? {
        guard case .foodDatabase(let foodDatabase) = self else {
            return nil
        }
        return foodDatabase.rawValue
    }
}
