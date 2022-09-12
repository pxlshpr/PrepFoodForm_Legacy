import PrepUnits

enum FormUnit {
    case weight(WeightUnit)
    case volume(VolumeUnit)
    case size
    case serving
}

extension FormUnit {
    var unitType: UnitType {
        switch self {
        case .weight:
            return .weight
        case .volume:
            return .volume
        case .size:
            return .size
        case .serving:
            return .serving
        }
    }
}

extension FormUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .weight(let weightUnit):
            return weightUnit.description
        case .volume(let volumeUnit):
            return volumeUnit.description
        case .size:
            return "[size]"
        case .serving:
            return "serving"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .weight(let weightUnit):
            return weightUnit.shortDescription
        case .volume(let volumeUnit):
            return volumeUnit.shortDescription
        case .size:
            return "[size]"
        case .serving:
            return "serving"
        }
    }
}
extension FormUnit: Equatable {
    static func ==(lhs: FormUnit, rhs: FormUnit) -> Bool {
        switch (lhs, rhs) {
        case (.serving, .serving):
            return true
        case (.size, .size):
            return true
        case (.weight(let lhsWeightUnit), .weight(let rhsWeightUnit)):
            return lhsWeightUnit == rhsWeightUnit
        case (.volume(let lhsVolumeUnit), .volume(let rhsVolumeUnit)):
            return lhsVolumeUnit == rhsVolumeUnit
        default:
            return false
        }
    }
}

