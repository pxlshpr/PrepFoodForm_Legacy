import MFPScraper

extension FoodForm.Fields {
    func prefillFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        guard let food = prefilledFood else { return [] }
        
        switch fieldValue {
        case .name, .detail, .brand:
            return food.stringBasedFieldValues
        case .macro(let macroValue):
            return [food.macroFieldValue(for: macroValue.macro)]
        case .micro(let microValue):
            return [food.microFieldValue(for: microValue.nutrientType)].compactMap { $0 }
        case .energy:
            return [food.energyFieldValue]
        case .serving:
            return [food.servingFieldValue].compactMap { $0 }
        case .amount:
            return [food.amountFieldValue].compactMap { $0 }
        case .density:
            return [food.densityFieldValue].compactMap { $0 }
        case .size:
            guard let food = prefilledFood else { return [] }
            return newSizeFieldValues(from: food.sizeFieldValues, including: fieldValue)
        default:
            return []
        }
    }
}
