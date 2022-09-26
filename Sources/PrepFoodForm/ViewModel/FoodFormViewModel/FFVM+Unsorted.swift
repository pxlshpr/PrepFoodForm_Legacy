import SwiftUI
import PrepUnits

extension FoodFormViewModel {
    func cancelScan() {
        scanTask?.cancel()
        isScanning = false
    }
    
    var hasData: Bool {
        !name.isEmpty
        || !emoji.isEmpty
        || !detail.isEmpty
        || !brand.isEmpty
        || !barcode.isEmpty
        || !amountString.isEmpty
        || !servingString.isEmpty
        || !standardSizes.isEmpty
        || !volumePrefixedSizes.isEmpty
        || !summarySizeViewModels.isEmpty
        || !densityWeightString.isEmpty
        || !densityVolumeString.isEmpty
        || !energy.isEmpty
        || !carb.isEmpty
        || !fat.isEmpty
        || !protein.isEmpty
        || !micronutrientsIsEmpty
//            || amountUnit != .serving
//            || servingUnit != .weight(.g)
//            || !densityWeightUnit.isEmpty
//            || !densityVolumeUnit.isEmpty
    }
    
    var micronutrientsIsEmpty: Bool {
        for (_, fieldValues) in micronutrients {
            for fieldValue in fieldValues {
                if !fieldValue.isEmpty {
                    return false
                }
            }
        }
        return true
    }
    
    var sourceIncludesImages: Bool {
        sourceType.includesImages
    }
    
    /// Prefill used for Previews
    public func previewPrefill(onlyServing: Bool = false, includeAllMicronutrients: Bool = false) {
        if onlyServing {
            let sizes = [
                Size(quantity: 1, name: "container", amount: 5, amountUnit: .serving)
            ]
            
            self.standardSizes = sizes
            self.summarySizeViewModels = sizes.map { SizeViewModel(size: $0) }

            self.amountString = "1"
            self.servingString = "0.2"
            self.servingUnit = .size(standardSizes.first!, nil)
        } else {
            self.name =  FieldValue(identifier: .name("Carrot"))
            self.emoji = "🥕"
            self.detail = FieldValue(identifier: .detail("Baby"))
            self.brand = "Woolworths"
            self.barcode = "5012345678900"
            
            self.amountString = "1"
            self.amountUnit = .serving
            self.servingString = "50"
            self.servingUnit = .weight(.g)
            
            self.densityWeightString = "20"
            self.densityWeightUnit = .weight(.g)
            self.densityVolumeString = "25"
            self.densityVolumeUnit = .volume(.mL)
            
            self.standardSizes = mockStandardSizes
            self.volumePrefixedSizes = mockVolumePrefixedSizes
            
            self.summarySizeViewModels = Array((standardSizes + volumePrefixedSizes).map { SizeViewModel(size: $0) }.prefix(maxNumberOfSummarySizeViewModels))
            
            self.energy = FieldValue(identifier: .energy(125, "125", .kJ))
            self.carb = FieldValue(identifier: .macro(.carb, 23))
            self.fat = FieldValue(identifier: .macro(.fat, 8))
            self.protein = FieldValue(identifier: .macro(.protein, 3))
            
            //TODO: Micronutrients
//            self.micronutrients = includeAllMicronutrients ? mockAllMicronutrients : mockMicronutrients
        }
    }
    
    func nutrientValue(for nutrientType: NutrientType) -> Double? {
        guard let nutritionFact = nutritionFact(for: .micro(nutrientType)) else {
            return nil
        }
        return nutritionFact.amount
    }
    
    var hasNutritionFacts: Bool {
        !micronutrientsIsEmpty
        || !energy.isEmpty
        || !carb.isEmpty
        || !fat.isEmpty
        || !protein.isEmpty
    }
    
    func removeFact(of type: NutritionFactType) {
//        setNutritionFactType(type, withAmount: nil, unit: nil)
    }
}

extension FoodFormViewModel {

    var carbAmount: Double {
        carb.identifier.double ?? 0
    }
    
    var proteinAmount: Double {
        protein.identifier.double ?? 0
    }
    
    var fatAmount: Double {
        fat.identifier.double ?? 0
    }
    
    var hasMicronutrients: Bool {
        !micronutrientsIsEmpty
    }
    
    func hasNutrientFor(_ nutrientType: NutrientType) -> Bool {
        nutritionFact(for: .micro(nutrientType)) != nil
    }
    
    var energyAmount: Double {
        energy.identifier.double ?? 0
    }
    
    func nutritionFact(for type: NutritionFactType) -> NutritionFact? {
        switch type {
        case .energy:
            return nil
//            return energyFact
        case .macro(let macro):
            switch macro {
            case .carb:
                return nil
            case .fat:
                return nil
            case .protein:
                return nil
            }
        case .micro:
            return nil
//            return micronutrients.first(where: { $0.type == type })
        }
    }
    
    var shouldShowServingInField: Bool {
        !amountString.isEmpty && amountIsServing
    }
    
    func updateShouldShowDensitiesSection() {
        withAnimation {
            shouldShowDensitiesSection =
            (amountUnit.isMeasurementBased && amount > 0)
            ||
            (servingUnit.isMeasurementBased && servingAmount > 0)
        }
    }

    var amountIsServing: Bool {
        amountUnit == .serving
    }

    var isWeightBased: Bool {
        amountUnit.isWeightBased || servingUnit.isWeightBased
    }

    var isVolumeBased: Bool {
        amountUnit.isVolumeBased || servingUnit.isVolumeBased
    }
    
    var shouldShowSizesSection: Bool {
        !amountString.isEmpty
    }

    func modifyServingAmount(for newUnit: FormUnit) {
        guard newUnit.isServingBased, case .size(let size, _) = newUnit else {
            return
        }
        let newServingAmount: Double
        if size.amount > 0 {
            newServingAmount = size.quantity / size.amount
        } else {
            newServingAmount = 0
        }
        
        servingString = "\(newServingAmount.clean)"
    }

    func modifyServingUnitIfServingBased() {
        guard servingUnit.isServingBased, case .size(let size, _) = servingUnit else {
            return
        }
        let newAmount: Double
        if servingAmount > 0 {
            newAmount = size.quantity / servingAmount
        } else {
            newAmount = 0
        }
        
        print("Now we need to change: \(size) to new amount \(newAmount)")
        
        standardSizes.first!.amount = newAmount
        updateSummary()
    }
    
    func add(size: Size) {
        withAnimation {
            if size.isVolumePrefixed {
                volumePrefixedSizes.append(size)
            } else {
                standardSizes.append(size)
            }
        }
    }
    
    var isMeasurementBased: Bool {
        amountUnit.isMeasurementBased || servingUnit.isMeasurementBased
    }
    
    var allSizes: [Size] {
        standardSizes + volumePrefixedSizes
    }
    
    var allSizesViewModels: [SizeViewModel] {
        allSizes.map { SizeViewModel(size: $0) }
    }

    var standardSizesViewModels: [SizeViewModel] {
        standardSizes
            .filter({ $0.volumePrefixUnit == nil })
            .map { SizeViewModel(size: $0) }
    }

    var volumePrefixedSizesViewModels: [SizeViewModel] {
        volumePrefixedSizes
            .filter({ $0.volumePrefixUnit != nil })
            .map { SizeViewModel(size: $0) }
    }

    var hasNutrientsPerContent: Bool {
        !amountString.isEmpty
    }
    
    var hasNutrientsPerServingContent: Bool {
        !servingString.isEmpty
    }
    
    var hasServing: Bool {
        amountUnit == .serving
    }
    
    var amount: Double {
        Double(amountString) ?? 0
    }
    
    var amountDescription: String {
        guard !amountString.isEmpty else {
            return ""
        }
        return "\(amountString) \(amountUnitShortString)"
    }
    
    var servingAmount: Double {
        Double(servingString) ?? 0
    }
    
    var amountFormHeaderString: String {
        switch amountUnit {
        case .serving:
            return "Servings"
        case .weight:
            return "Weight"
        case .volume:
            return "Volume"
        case .size:
            return "Size"
        }
    }

    var servingFormHeaderString: String {
        switch servingUnit {
        case .weight:
            return "Weight"
        case .volume:
            return "Volume"
        case .size:
            return "Size"
        default:
            return ""
        }
    }

    var servingUnitDescription: String {
        servingUnit.description
    }
    
    var servingUnitShortString: String {
        servingUnit.shortDescription
    }
    
    var servingDescription: String {
        guard !servingString.isEmpty else {
            return ""
        }
        return "\(servingString) \(servingUnitShortString)"
    }
    
    var amountUnitString: String {
        amountUnit.description
    }
    
    var amountUnitShortString: String {
        amountUnit.shortDescription
    }

    var densityWeightAmount: Double {
        Double(densityWeightString) ?? 0
    }

    var densityVolumeAmount: Double {
        Double(densityVolumeString) ?? 0
    }
    
    var hasValidDensity: Bool {
        densityWeightAmount > 0
        && densityVolumeAmount > 0
        && densityWeightUnit.unitType == .weight
        && densityVolumeUnit.unitType == .volume
    }

    var densityDescription: String? {
        guard hasValidDensity else {
            return nil
        }
                
        let weight = "\(densityWeightAmount.cleanAmount) \(densityWeightUnit.shortDescription)"
        let volume = "\(densityVolumeAmount.cleanAmount) \(densityVolumeUnit.shortDescription)"
        
        if isWeightBased {
            return "\(weight) = \(volume)"
        } else {
            return "\(volume) = \(weight)"
        }
    }
    
    var lhsDensityAmountString: String {
        if isWeightBased {
            return densityWeightAmount.cleanAmount
        } else {
            return densityVolumeAmount.cleanAmount
        }
    }
    
    var rhsDensityAmountString: String {
        if isWeightBased {
            return densityVolumeAmount.cleanAmount
        } else {
            return densityWeightAmount.cleanAmount
        }
    }

    var lhsDensityUnitString: String {
        if isWeightBased {
            return densityWeightUnit.shortDescription
        } else {
            return densityVolumeUnit.shortDescription
        }
    }
    
    var rhsDensityUnitString: String {
        if isWeightBased {
            return densityVolumeUnit.shortDescription
        } else {
            return densityWeightUnit.shortDescription
        }
    }
    
    var servingSizeFooterString: String {
        switch servingUnit {
        case .weight:
            return "This is the weight of 1 serving. Enter this to log this food using its weight in addition to servings."
        case .volume:
            return "This is the volume of 1 serving. Enter this to log this food using its volume in addition to servings."
        case .size(let size, _):
            return "This is how many \(size.prefixedName) is 1 serving."
        case .serving:
            return "Unsupported"
        }
    }
    
    var shouldShowSavePublicButton: Bool {
        //TODO: only show if user includes a valid source
        true
    }
}

let mockMicronutrients = [
    NutritionFact(type: .micro(.saturatedFat), amount: 25, unit: .g),
    NutritionFact(type: .micro(.biotin), amount: 5, unit: .g),
    NutritionFact(type: .micro(.caffeine), amount: 250, unit: .mg),
    NutritionFact(type: .micro(.addedSugars), amount: 35, unit: .g),
]

var mockAllMicronutrients: [NutritionFact] {
    NutrientType.allCases.map {
        NutritionFact(type: .micro($0), amount: Double.random(in: 1...300), unit: $0.units.first!.nutritionFactUnit)
    }
}
