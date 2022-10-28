import Foundation
import PrepDataTypes

extension FoodForm.Fields {
    func includeMicronutrients(for nutrientTypes: [NutrientType]) {
        for g in micronutrients.indices {
            for f in micronutrients[g].fieldViewModels.indices {
                guard let nutrientType = micronutrients[g].fieldViewModels[f].nutrientType,
                      nutrientTypes.contains(nutrientType) else {
                    continue
                }
                micronutrients[g].fieldViewModels[f].value.microValue.isIncluded = true
            }
        }
    }
    
    func hasEmptyFieldValuesInMicronutrientsGroup(at index: Int, matching searchString: String = "") -> Bool {
        micronutrients[index].fieldViewModels.contains(where: {
            if !searchString.isEmpty {
                return $0.value.isEmpty && $0.value.microValue.matchesSearchString(searchString)
            } else {
                return $0.value.isEmpty
            }
        })
    }
    
    func hasIncludedFieldValuesInMicronutrientsGroup(at index: Int) -> Bool {
        micronutrients[index].fieldViewModels.contains(where: { $0.value.microValue.isIncluded })
    }
}