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
        || !amount.isEmpty
        || !serving.isEmpty
        || !standardSizes.isEmpty
        || !volumePrefixedSizes.isEmpty
        || !density.isEmpty
        || !energy.isEmpty
        || !carb.isEmpty
        || !fat.isEmpty
        || !protein.isEmpty
        || !micronutrientsIsEmpty
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
        shouldShowWizard = false
        if onlyServing {
            let sizes: [Size] = [
                Size(quantity: 1, quantityString: "1", name: "container", amount: 5, amountString: "5", unit: .serving)
            ]
            
            self.standardSizes = sizes

            self.amount = FieldValue.amount(doubleValue: FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
            self.serving = FieldValue.serving(doubleValue: FieldValue.DoubleValue(double: 0.2, string: "0.2", unit: .size(standardSizes.first!, nil)))
        } else {
            self.name =  FieldValue.name(FieldValue.StringValue(string: "Carrot"))
            self.emoji = FieldValue.emoji(FieldValue.StringValue(string: "🥕"))
            self.detail = FieldValue.detail(FieldValue.StringValue(string: "Baby"))
            self.brand = FieldValue.brand(FieldValue.StringValue(string: "Woolworths"))
            self.barcode = FieldValue.barcode(FieldValue.StringValue(string: "5012345678900"))
            
            self.amount = FieldValue.amount(doubleValue: FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
            self.serving = FieldValue.serving(doubleValue: FieldValue.DoubleValue(double: 50, string: "50", unit: .weight(.g)))
            
            self.density = FieldValue.density(density: FieldValue.Density(
                weight: FieldValue.DoubleValue(double: 20, string: "20", unit: .weight(.g)),
                volume: FieldValue.DoubleValue(double: 25, string: "25", unit: .volume(.mL)))
            )
            
            self.standardSizes = mockStandardSizes
            self.volumePrefixedSizes = mockVolumePrefixedSizes
            
//            self.summarySizeViewModels = Array((standardSizes + volumePrefixedSizes).map { SizeViewModel(size: $0) }.prefix(maxNumberOfSummarySizeViewModels))
            
            self.energy = FieldValue.energy(double: 125, string: "125", unit: .kJ)
            self.carb = FieldValue.macro(macro: .carb, double: 23, string: "23")
            self.fat = FieldValue.macro(macro: .fat, double: 8, string: "8")
            self.protein = FieldValue.macro(macro: .protein, double: 3, string: "3")
            
            //TODO: Micronutrients
            if includeAllMicronutrients {
                for g in micronutrients.indices {
                    for f in micronutrients[g].fieldValues.indices {
                        micronutrients[g].fieldValues[f].double = Double.random(in: 1...300)
                    }
                }
            } else {
                for g in micronutrients.indices {
                    for f in micronutrients[g].fieldValues.indices {
                        if micronutrients[g].fieldValues[f].nutrientType == .saturatedFat {
                            micronutrients[g].fieldValues[f].double = 25
                        }
                        if micronutrients[g].fieldValues[f].nutrientType == .biotin {
                            micronutrients[g].fieldValues[f].double = 5
                        }
                        if micronutrients[g].fieldValues[f].nutrientType == .caffeine {
                            micronutrients[g].fieldValues[f].double = 250
                        }
                        if micronutrients[g].fieldValues[f].nutrientType == .addedSugars {
                            micronutrients[g].fieldValues[f].double = 35
                        }
                    }
                }
            }
        }
    }
    
    var hasNutritionFacts: Bool {
        !micronutrientsIsEmpty
        || !energy.isEmpty
        || !carb.isEmpty
        || !fat.isEmpty
        || !protein.isEmpty
    }    
}

extension FoodFormViewModel {
    
    var hasMicronutrients: Bool {
        !micronutrientsIsEmpty
    }
    
    var shouldShowServingInField: Bool {
        !amount.isEmpty && amountIsServing
    }
    
    func updateShouldShowDensitiesSection() {
        withAnimation {
            shouldShowDensitiesSection =
            (amount.doubleValue.unit.isMeasurementBased && (amount.doubleValue.double ?? 0) > 0)
            ||
            (amount.doubleValue.unit.isMeasurementBased && (serving.doubleValue.double ?? 0) > 0)
        }
    }

    var amountIsServing: Bool {
        amount.doubleValue.unit == .serving
    }

    var isWeightBased: Bool {
        amount.doubleValue.unit.isWeightBased || serving.doubleValue.unit.isWeightBased
    }

    var isVolumeBased: Bool {
        amount.doubleValue.unit.isVolumeBased || serving.doubleValue.unit.isVolumeBased
    }
    
    var shouldShowSizesSection: Bool {
        !amount.isEmpty
    }

    func modifyServingAmount(for newUnit: FormUnit) {
        guard newUnit.isServingBased, case .size(let size, _) = newUnit else {
            return
        }
        let newServingAmount: Double
        if let amount = size.amount, let quantity = size.quantity, amount > 0 {
            newServingAmount = quantity / amount
        } else {
            newServingAmount = 0
        }
        
        serving.doubleValue.string = "\(newServingAmount.clean)"
    }

    func modifyServingUnitIfServingBased() {
        guard serving.doubleValue.unit.isServingBased, case .size(let size, _) = serving.doubleValue.unit else {
            return
        }
        let newAmount: Double
        if let quantity = size.quantity, let servingAmount = serving.doubleValue.double, servingAmount > 0 {
            newAmount = quantity / servingAmount
        } else {
            newAmount = 0
        }
        
        //TODO-SIZE: We need to get access to it here—possibly need to add it to sizes to begin with so that we can modify it here
//        size.amountDouble = newAmount
//        updateSummary()
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
    
    var numberOfSizes: Int {
        standardSizes.count + volumePrefixedSizes.count
    }
    
    /// Checks that we don't already have a size with the same name (and volume prefix unit) as what was provided
    func containsSize(withName name: String, andVolumePrefixUnit volumePrefixUnit: FormUnit?, ignoring sizeToIgnore: Size?) -> Bool {
        for sizes in [standardSizes, volumePrefixedSizes] {
            for size in sizes {
                guard size != sizeToIgnore else {
                    continue
                }
                if size.name.lowercased() == name.lowercased(),
                   size.volumePrefixUnit == volumePrefixUnit {
                    return true
                }
            }
        }
        return false
    }
    
    var isMeasurementBased: Bool {
        amount.doubleValue.unit.isMeasurementBased || serving.doubleValue.unit.isMeasurementBased
    }
    
    var hasNutrientsPerContent: Bool {
        !amount.isEmpty
    }
    
    var hasNutrientsPerServingContent: Bool {
        !serving.isEmpty
    }
    
    var hasServing: Bool {
        amount.doubleValue.unit == .serving
    }
    
    var amountDescription: String {
        guard !amount.isEmpty else {
            return ""
        }
        return "\(amount.doubleValue.string) \(amount.doubleValue.unitDescription)"
    }
    
    var amountFormHeaderString: String {
        switch amount.doubleValue.unit {
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
        switch serving.doubleValue.unit {
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
        serving.doubleValue.unit.description
    }
    
    var servingUnitShortString: String {
        serving.doubleValue.unit.shortDescription
    }
    
    var servingDescription: String {
        guard !serving.isEmpty else {
            return ""
        }
        return "\(serving.doubleValue.string) \(serving.doubleValue.unitDescription)"
    }
    
    var amountUnitString: String {
        amount.doubleValue.unit.description
    }
    
    var amountUnitShortString: String {
        amount.doubleValue.unit.shortDescription
    }

    var densityWeightAmount: Double {
        density.weight.double ?? 0
    }

    var densityVolumeAmount: Double {
        density.volume.double ?? 0
    }
    
    var hasValidDensity: Bool {
        densityWeightAmount > 0
        && densityVolumeAmount > 0
        && density.weight.unit.unitType == .weight
        && density.volume.unit.unitType == .volume
    }

    var densityDescription: String? {
        guard hasValidDensity else {
            return nil
        }
                
        let weight = "\(densityWeightAmount.cleanAmount) \(density.weight.unitDescription)"
        let volume = "\(densityVolumeAmount.cleanAmount) \(density.volume.unitDescription)"
        
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
            return density.weight.unitDescription
        } else {
            return density.volume.unitDescription
        }
    }
    
    var rhsDensityUnitString: String {
        if isWeightBased {
            return density.volume.unitDescription
        } else {
            return density.weight.unitDescription
        }
    }
    
    var servingSizeFooterString: String {
        switch serving.doubleValue.unit {
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
