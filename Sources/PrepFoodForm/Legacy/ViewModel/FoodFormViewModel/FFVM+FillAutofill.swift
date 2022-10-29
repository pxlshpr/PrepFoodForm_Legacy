import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepDataTypes

extension FoodFormViewModel {

    var scanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }
    
    func setMicronutrient(_ nutrientType: NutrientType, with fieldValue: FieldValue) {
        guard let indexes = micronutrientIndexes(for: nutrientType) else {
            print("Couldn't find indexes for nutrientType: \(nutrientType) in micronutrients array")
            return
        }
        micronutrients[indexes.groupIndex].fields[indexes.fieldIndex] = .init(fieldValue: fieldValue)
        scannedFieldValues.append(fieldValue)
    }
    
    func micronutrientIndexes(for nutrientType: NutrientType) -> (groupIndex: Int, fieldIndex: Int)? {
        guard let groupIndex = micronutrients.firstIndex(where: { $0.group == nutrientType.group }) else {
            return nil
        }
        guard let fieldIndex = micronutrients[groupIndex].fields.firstIndex(where: { $0.value.microValue.nutrientType == nutrientType }) else {
            return nil
        }
        return (groupIndex, fieldIndex)
    }
}
