import PrepUnits

indirect enum FormUnit: Hashable {
    case weight(WeightUnit)
    case volume(VolumeUnit)
    case size(Size, VolumeUnit?)
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
        case .size(let size, let volumePrefixUnit):
            return size.namePrefixed(with: volumePrefixUnit)
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
        case .size(let size, let volumePrefixUnit):
            return size.namePrefixed(with: volumePrefixUnit)
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
        case (.size(let lhsSize, let lhsVolumePrefixUnit), .size(let rhsSize, let rhsVolumePrefixUnit)):
            return lhsSize == rhsSize && lhsVolumePrefixUnit == rhsVolumePrefixUnit
        case (.weight(let lhsWeightUnit), .weight(let rhsWeightUnit)):
            return lhsWeightUnit == rhsWeightUnit
        case (.volume(let lhsVolumeUnit), .volume(let rhsVolumeUnit)):
            return lhsVolumeUnit == rhsVolumeUnit
        default:
            return false
        }
    }
}

