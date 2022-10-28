import Foundation
import PrepDataTypes

extension NutrientType {
    func matchesSearchString(_ string: String) -> Bool {
        description.lowercased().contains(string.lowercased())
    }
}

extension NutrientTypeGroup {
    var nutrients: [NutrientType] {
        NutrientType.allCases.filter({ $0.group == self })
    }
}

//TODO: Remove this
extension FieldValue.MicroValue {
    func matchesSearchString(_ string: String) -> Bool {
        nutrientType.matchesSearchString(string)
    }
}

