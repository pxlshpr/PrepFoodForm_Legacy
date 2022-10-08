import SwiftUI
import PrepUnits

extension FoodFormViewModel {
    func cancelScan() {
        scanTask?.cancel()
        isScanning = false
    }
    
    var hasEnoughData: Bool {
        !nameViewModel.fieldValue.isEmpty
//        || !emojiViewModel.fieldValue.isEmpty
        || !detailViewModel.fieldValue.isEmpty
        || !brandViewModel.fieldValue.isEmpty
        || !barcodeViewModel.fieldValue.isEmpty
//        || !amountViewModel.fieldValue.isEmpty
        || !servingViewModel.fieldValue.isEmpty
        || !standardSizeViewModels.isEmpty
        || !volumePrefixedSizeViewModels.isEmpty
        || !densityViewModel.fieldValue.isEmpty
        || !energyViewModel.fieldValue.isEmpty
        || !carbViewModel.fieldValue.isEmpty
        || !fatViewModel.fieldValue.isEmpty
        || !proteinViewModel.fieldValue.isEmpty
        || !micronutrientsIsEmpty
    }
    
    var micronutrientsIsEmpty: Bool {
        for (_, fieldViewModels) in micronutrients {
            for fieldViewModel in fieldViewModels {
                if !fieldViewModel.fieldValue.isEmpty {
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
            let size = Size(quantity: 1, name: "container", amount: 5, unit: .serving)
            let sizeViewModels: [FieldViewModel] = [
                FieldViewModel(fieldValue: .size(.init(size: size, fillType: .userInput)))
            ]
            
            self.standardSizeViewModels = sizeViewModels

            self.amountViewModel.fieldValue = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
            self.servingViewModel.fieldValue = FieldValue.serving(FieldValue.DoubleValue(double: 0.2, string: "0.2", unit: .size(size, nil)))
        } else {
            self.nameViewModel.fieldValue =  FieldValue.name(FieldValue.StringValue(string: "Carrot"))
            self.emojiViewModel.fieldValue = FieldValue.emoji(FieldValue.StringValue(string: "🥕"))
            self.detailViewModel.fieldValue = FieldValue.detail(FieldValue.StringValue(string: "Baby"))
            self.brandViewModel.fieldValue = FieldValue.brand(FieldValue.StringValue(string: "Woolworths"))
            self.barcodeViewModel.fieldValue = FieldValue.barcode(FieldValue.StringValue(string: "5012345678900"))
            
            self.amountViewModel.fieldValue = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
            self.servingViewModel.fieldValue = FieldValue.serving(FieldValue.DoubleValue(double: 50, string: "50", unit: .weight(.g)))
            
            self.densityViewModel.fieldValue = FieldValue.density(FieldValue.DensityValue(
                weight: FieldValue.DoubleValue(double: 20, string: "20", unit: .weight(.g)),
                volume: FieldValue.DoubleValue(double: 25, string: "25", unit: .volume(.mL)))
            )
            
            self.standardSizeViewModels = mockStandardSizes.fieldViewModels
            self.volumePrefixedSizeViewModels = mockVolumePrefixedSizes.fieldViewModels
            
            self.energyViewModel.fieldValue = FieldValue.energy(FieldValue.EnergyValue(double: 125, string: "125", unit: .kJ))
            self.carbViewModel.fieldValue = FieldValue.macro(FieldValue.MacroValue(macro: .carb, double: 23, string: "23"))
            self.fatViewModel.fieldValue = FieldValue.macro(FieldValue.MacroValue(macro: .fat, double: 8, string: "8"))
            self.proteinViewModel.fieldValue = FieldValue.macro(FieldValue.MacroValue(macro: .protein, double: 3, string: "3"))
            
            //TODO: Micronutrients
            if includeAllMicronutrients {
                for g in micronutrients.indices {
                    for f in micronutrients[g].fieldViewModels.indices {
                        micronutrients[g].fieldViewModels[f].fieldValue.microValue.double = Double.random(in: 1...300)
                    }
                }
            } else {
                for g in micronutrients.indices {
                    for f in micronutrients[g].fieldViewModels.indices {
                        if micronutrients[g].fieldViewModels[f].fieldValue.microValue.nutrientType == .saturatedFat {
                            micronutrients[g].fieldViewModels[f].fieldValue.microValue.double = 25
                        }
                        if micronutrients[g].fieldViewModels[f].fieldValue.microValue.nutrientType == .biotin {
                            micronutrients[g].fieldViewModels[f].fieldValue.microValue.double = 5
                        }
                        if micronutrients[g].fieldViewModels[f].fieldValue.microValue.nutrientType == .caffeine {
                            micronutrients[g].fieldViewModels[f].fieldValue.microValue.double = 250
                        }
                        if micronutrients[g].fieldViewModels[f].fieldValue.microValue.nutrientType == .addedSugars {
                            micronutrients[g].fieldViewModels[f].fieldValue.microValue.double = 35
                        }
                    }
                }
            }
        }
    }
    
    var hasNutritionFacts: Bool {
        !micronutrientsIsEmpty
        || !energyViewModel.fieldValue.isEmpty
        || !carbViewModel.fieldValue.isEmpty
        || !fatViewModel.fieldValue.isEmpty
        || !proteinViewModel.fieldValue.isEmpty
    }    
}

extension FoodFormViewModel {
    
    var hasMicronutrients: Bool {
        !micronutrientsIsEmpty
    }
    
    var shouldShowServingInField: Bool {
        !amountViewModel.fieldValue.isEmpty && amountIsServing
    }
    
    func updateShouldShowDensitiesSection() {
        withAnimation {
            shouldShowDensitiesSection =
            (amountViewModel.fieldValue.doubleValue.unit.isMeasurementBased && (amountViewModel.fieldValue.doubleValue.double ?? 0) > 0)
            ||
            (amountViewModel.fieldValue.doubleValue.unit.isMeasurementBased && (servingViewModel.fieldValue.doubleValue.double ?? 0) > 0)
        }
    }

    var amountIsServing: Bool {
        amountViewModel.fieldValue.doubleValue.unit == .serving
    }

    var isWeightBased: Bool {
        amountViewModel.fieldValue.doubleValue.unit.isWeightBased || servingViewModel.fieldValue.doubleValue.unit.isWeightBased
    }

    var isVolumeBased: Bool {
        amountViewModel.fieldValue.doubleValue.unit.isVolumeBased || servingViewModel.fieldValue.doubleValue.unit.isVolumeBased
    }
    
    var shouldShowSizesSection: Bool {
        !amountViewModel.fieldValue.isEmpty
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
        
        servingViewModel.fieldValue.doubleValue.string = "\(newServingAmount.clean)"
    }

    func modifyServingUnitIfServingBased() {
        guard servingViewModel.fieldValue.doubleValue.unit.isServingBased, case .size(let size, _) = servingViewModel.fieldValue.doubleValue.unit else {
            return
        }
        let newAmount: Double
        if let quantity = size.quantity, let servingAmount = servingViewModel.fieldValue.doubleValue.double, servingAmount > 0 {
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
                volumePrefixedSizeViewModels.append(size.asFieldViewModelForUserInput)
            } else {
                standardSizeViewModels.append(size.asFieldViewModelForUserInput)
            }
        }
    }

    func add(sizeViewModel: FieldViewModel) {
        /// Make sure it's actually got a size in it first
        guard let size = sizeViewModel.size else { return }
        withAnimation {
            if size.isVolumePrefixed {
                volumePrefixedSizeViewModels.append(sizeViewModel)
            } else {
                standardSizeViewModels.append(sizeViewModel)
            }
        }
    }
    
    func editStandardSizeViewModel(_ sizeViewModel: FieldViewModel, with newSizeViewModel: FieldViewModel) {
        if newSizeViewModel.size?.isVolumePrefixed == true {
            /// Remove it from the standard list
            standardSizeViewModels.removeAll(where: { $0.id == sizeViewModel.id })
            
            /// Append the new one to the volume based list
            volumePrefixedSizeViewModels.append(newSizeViewModel)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        } else {
            guard let index = standardSizeViewModels.firstIndex(where: { $0.id == sizeViewModel.id }) else {
                return
            }
            standardSizeViewModels[index].copyData(from: newSizeViewModel)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        }
    }
    
    func editVolumeBasedSizeViewModel(_ sizeViewModel: FieldViewModel, with newSizeViewModel: FieldViewModel) {
        if newSizeViewModel.size?.isVolumePrefixed == false {
            /// Remove it from the standard list
            volumePrefixedSizeViewModels.removeAll(where: { $0.id == sizeViewModel.id })
            
            /// Append the new one to the volume based list
            standardSizeViewModels.append(newSizeViewModel)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        } else {
            guard let index = volumePrefixedSizeViewModels.firstIndex(where: { $0.id == sizeViewModel.id }) else {
                return
            }
            volumePrefixedSizeViewModels[index].copyData(from: newSizeViewModel)
            //TODO: We'll also need to cases where other form fields are dependent on this here—requiring user confirmation first
        }
    }

    func edit(_ sizeViewModel: FieldViewModel, with newSizeViewModel: FieldViewModel) {
        /// if this was a standard
        if sizeViewModel.size?.isVolumePrefixed == false {
            editStandardSizeViewModel(sizeViewModel, with: newSizeViewModel)
        } else {
            editVolumeBasedSizeViewModel(sizeViewModel, with: newSizeViewModel)
        }
    }

    var numberOfSizes: Int {
        standardSizeViewModels.count + volumePrefixedSizeViewModels.count
    }
    
    var allSizes: [Size] {
        standardSizeViewModels.compactMap({ $0.fieldValue.size })
        + volumePrefixedSizeViewModels.compactMap({ $0.fieldValue.size })
    }
    
    /// Checks that we don't already have a size with the same name (and volume prefix unit) as what was provided
    func containsSize(withName name: String, andVolumePrefixUnit volumePrefixUnit: FormUnit?, ignoring sizeToIgnore: Size?) -> Bool {
        for size in allSizes {
            guard size != sizeToIgnore else {
                continue
            }
            if size.name.lowercased() == name.lowercased(),
               size.volumePrefixUnit == volumePrefixUnit {
                return true
            }
        }
        return false
    }
    
    var isMeasurementBased: Bool {
        amountViewModel.fieldValue.doubleValue.unit.isMeasurementBased || servingViewModel.fieldValue.doubleValue.unit.isMeasurementBased
    }
    
    var hasNutrientsPerContent: Bool {
        !amountViewModel.fieldValue.isEmpty
    }
    
    var hasNutrientsPerServingContent: Bool {
        !servingViewModel.fieldValue.isEmpty
    }
    
    var hasServing: Bool {
        amountViewModel.fieldValue.doubleValue.unit == .serving
    }
    
    var amountDescription: String {
        guard !amountViewModel.fieldValue.isEmpty else {
            return ""
        }
        return "\(amountViewModel.fieldValue.doubleValue.string) \(amountViewModel.fieldValue.doubleValue.unitDescription)"
    }
    
    var servingFormHeaderString: String {
        switch servingViewModel.fieldValue.doubleValue.unit {
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
        servingViewModel.fieldValue.doubleValue.unit.description
    }
    
    var servingUnitShortString: String {
        servingViewModel.fieldValue.doubleValue.unit.shortDescription
    }
    
    var servingDescription: String {
        guard !servingViewModel.fieldValue.isEmpty else {
            return ""
        }
        return "\(servingViewModel.fieldValue.doubleValue.string) \(servingViewModel.fieldValue.doubleValue.unitDescription)"
    }
    
    var amountUnitString: String {
        amountViewModel.fieldValue.doubleValue.unit.description
    }
    
    var densityWeightAmount: Double {
        densityViewModel.fieldValue.weight.double ?? 0
    }

    var densityVolumeAmount: Double {
        densityViewModel.fieldValue.volume.double ?? 0
    }
    
    var hasValidDensity: Bool {
        densityWeightAmount > 0
        && densityVolumeAmount > 0
        && densityViewModel.fieldValue.weight.unit.unitType == .weight
        && densityViewModel.fieldValue.volume.unit.unitType == .volume
    }

    var densityDescription: String? {
        guard hasValidDensity else {
            return nil
        }
                
        let weight = "\(densityWeightAmount.cleanAmount) \(densityViewModel.fieldValue.weight.unitDescription)"
        let volume = "\(densityVolumeAmount.cleanAmount) \(densityViewModel.fieldValue.volume.unitDescription)"
        
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
            return densityViewModel.fieldValue.weight.unitDescription
        } else {
            return densityViewModel.fieldValue.volume.unitDescription
        }
    }
    
    var rhsDensityUnitString: String {
        if isWeightBased {
            return densityViewModel.fieldValue.volume.unitDescription
        } else {
            return densityViewModel.fieldValue.weight.unitDescription
        }
    }
    
    var servingSizeFooterString: String {
        switch servingViewModel.fieldValue.doubleValue.unit {
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

extension FoodFormViewModel {
    public static var mock: FoodFormViewModel {
        let viewModel = FoodFormViewModel()
        
        guard let image = sampleImage(13),
//              let mfpProcessedFood = sampleMFPProcessedFood(11),
              let scanResult = sampleScanResult(13)
        else {
            fatalError("Couldn't load mock files")
        }
        
        viewModel.shouldShowWizard = false
        
//        viewModel.prefilledFood = mfpProcessedFood
        
        viewModel.sourceType = .images
        viewModel.imageViewModels.append(
            ImageViewModel(image: image,
                           scanResult: scanResult
                           
                          )
        )
        viewModel.processScanResults()
        viewModel.imageSetStatus = .classified
        
        return viewModel
    }
}

extension Size {
    var asFieldViewModelForUserInput: FieldViewModel {
        FieldViewModel(fieldValue: .size(.init(size: self, fillType: .userInput)))
    }
}

extension FieldValue {
    var size: Size? {
        get {
            switch self {
            case .size(let sizeValue):
                return sizeValue.size
            default:
                return nil
            }
        }
        set {
            guard let newValue else {
                return
            }
            switch self {
            case .size(let sizeValue):
                self = .size(.init(size: newValue, fillType: sizeValue.fillType))
            default:
                break
            }
        }
    }
}

extension FoodFormViewModel {
    func micronutrientFieldViewModel(for nutrientType: NutrientType) -> FieldViewModel? {
        for group in micronutrients {
            for fieldViewModel in group.fieldViewModels {
                if case .micro(let microValue) = fieldViewModel.fieldValue, microValue.nutrientType == nutrientType {
                    return fieldViewModel
                }
            }
        }
        return nil
    }
}

extension FieldValue.MicroValue {
    var convertedFromPercentage: (amount: Double, unit: NutrientUnit)? {
        guard let double, unit == .p else {
            return nil
        }
        return nutrientType.convertRDApercentage(double)
    }
}

