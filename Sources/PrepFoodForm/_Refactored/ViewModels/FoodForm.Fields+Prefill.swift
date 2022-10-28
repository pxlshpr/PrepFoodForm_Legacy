import MFPScraper
import PrepDataTypes

extension FoodForm.Fields {

    func prefill(_ food: MFPProcessedFood) {
        
        /// Create sizes first as we might have one as the amount or serving unit
        prefillSizes(from: food)
        
        prefillDensity(from: food)
        
        prefillAmountPer(from: food)
        prefillNutrients(from: food)

        //TODO: Bring this back
//        updateShouldShowDensitiesSection()

        prefilledFood = food
    }
    
    func prefillSizes(from food: MFPProcessedFood) {
        for size in food.sizes.filter({ !$0.isDensity }) {
            prefillSize(size)
        }
    }
    
    func prefillSize(_ processedSize: MFPProcessedFood.Size) {
        let field: Field = .init(fieldValue: processedSize.fieldValue)
        if processedSize.isVolumePrefixed {
//            addVolumePrefixedSizeViewModel(field)
        } else {
//            addStandardSizeViewModel(field)
        }
    }
    
    func prefillSize(_ size: FormSize) {
        let field: Field = .init(fieldValue: size.fieldValue)
        if size.isVolumePrefixed {
//            addVolumePrefixedSizeViewModel(field)
        } else {
//            addStandardSizeViewModel(field)
        }
    }

    func prefillDensity(from food: MFPProcessedFood) {
        guard let fieldValue = food.densityFieldValue else { return }
        density = .init(fieldValue: fieldValue)
    }

    func prefillAmountPer(from food: MFPProcessedFood) {
        prefillAmount(from: food)
        prefillServing(from: food)
    }
    
    func prefillAmount(from food: MFPProcessedFood) {
        guard let fieldValue = food.amountFieldValue else {
            return
        }
        
//        /// If the amount had a size as a unit—prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        amount.value = fieldValue
    }
    
    func prefillServing(from food: MFPProcessedFood) {
        guard let fieldValue = food.servingFieldValue else {
            return
        }
        
//        /// If the serving had a size as a unit—prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        serving = .init(fieldValue: fieldValue)
    }
    
    func prefillNutrients(from food: MFPProcessedFood) {
        energy = .init(fieldValue: food.energyFieldValue)
        carb = .init(fieldValue: food.carbFieldValue)
        fat = .init(fieldValue: food.fatFieldValue)
        protein = .init(fieldValue: food.proteinFieldValue)
        
        prefillMicros(food.microFieldValues)
    }
    
    func prefillMicros(_ fieldValues: [FieldValue]) {
        for fieldValue in fieldValues {
            addMicronutrient(fieldValue)
        }
    }
    
    func addMicronutrient(_ fieldValue: FieldValue) {
        guard let group = fieldValue.microValue.nutrientType.group else {
            return
        }
        let field = Field(fieldValue: fieldValue)
        switch group {
        case .fats:         microsFats.append(field)
        case .fibers:       microsFibers.append(field)
        case .sugars:       microsSugars.append(field)
        case .minerals:     microsMinerals.append(field)
        case .vitamins:     microsVitamins.append(field)
        case .misc:     	microsMisc.append(field)
        }
    }
}

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
