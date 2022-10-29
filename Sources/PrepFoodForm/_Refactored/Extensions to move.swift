import Foundation
import PrepDataTypes
import VisionSugar

extension NutrientType {
    func matchesSearchString(_ string: String) -> Bool {
        description.lowercased().contains(string.lowercased())
    }
}

extension Array where Element == FormSize {
    var standardSizes: [FormSize] {
        filter({ $0.volumePrefixUnit == nil })
    }
    
    var volumePrefixedSizes: [FormSize] {
        filter({ $0.volumePrefixUnit != nil })
    }
}

extension NutrientTypeGroup {
    var nutrients: [NutrientType] {
        NutrientType.allCases.filter({ $0.group == self })
    }
}

extension FieldValue.MicroValue {
    func matchesSearchString(_ string: String) -> Bool {
        nutrientType.matchesSearchString(string)
    }
}

/// This was created to populate fill options for sizes, but is currently unused
extension RecognizedText {
    /// Returns the first `Size` that can be extracted from this text
    var size: FormSize? {
        nil
//        servingArtefacts.count > 0
    }
}

import PrepDataTypes

extension RecognizedText {
    var densityValue: FieldValue.DensityValue? {
        string.detectedValues.densityValue
    }
}

extension Array where Element == FoodLabelValue {
    var firstWeightValue: FoodLabelValue? {
        first(where: { $0.unit?.unitType == .weight })
    }
    
    var firstVolumeValue: FoodLabelValue? {
        first(where: { $0.unit?.unitType == .volume })
    }

    var densityValue: FieldValue.DensityValue? {
        guard let weightDoubleValue, let volumeDoubleValue else {
            return nil
        }
        return FieldValue.DensityValue(
            weight: weightDoubleValue,
            volume: volumeDoubleValue,
            fill: .discardable
        )
    }
    
    var weightDoubleValue: FieldValue.DoubleValue? {
        firstWeightValue?.asDoubleValue
    }
    var volumeDoubleValue: FieldValue.DoubleValue? {
        firstVolumeValue?.asDoubleValue
    }
}

extension FoodLabelValue {
    var asDoubleValue: FieldValue.DoubleValue? {
        guard let formUnit = unit?.formUnit else { return nil }
        return FieldValue.DoubleValue(
            double: amount,
            string: amount.cleanAmount,
            unit: formUnit,
            fill: .discardable
        )
    }
}
