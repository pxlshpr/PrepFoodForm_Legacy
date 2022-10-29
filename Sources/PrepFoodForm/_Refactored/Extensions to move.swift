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
