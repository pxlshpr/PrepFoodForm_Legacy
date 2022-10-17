import SwiftUI
import PrepUnits

extension FoodFormViewModel {
    var hasEnoughData: Bool {
        !nameViewModel.fieldValue.isEmpty
//        || !emojiViewModel.fieldValue.isEmpty
        || !detailViewModel.fieldValue.isEmpty
        || !brandViewModel.fieldValue.isEmpty
//        || !barcodeViewModel.fieldValue.isEmpty
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
    
    /// Prefill used for Previews
    public func previewPrefill(onlyServing: Bool = false, includeAllMicronutrients: Bool = false) {
        shouldShowWizard = false
        if onlyServing {
            let size = Size(quantity: 1, name: "container", amount: 5, unit: .serving)
            let sizeViewModels: [FieldViewModel] = [
                FieldViewModel(fieldValue: .size(.init(size: size, fill: .userInput)))
            ]
            
            self.standardSizeViewModels = sizeViewModels
            for sizeViewModel in sizeViewModels {
                addSubscription(for: sizeViewModel)
            }

            self.amountViewModel.fieldValue = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
            self.servingViewModel.fieldValue = FieldValue.serving(FieldValue.DoubleValue(double: 0.2, string: "0.2", unit: .size(size, nil)))
        } else {
            self.nameViewModel.fieldValue =  FieldValue.name(FieldValue.StringValue(string: "Carrot"))
            self.emojiViewModel.fieldValue = FieldValue.emoji(FieldValue.StringValue(string: "🥕"))
            self.detailViewModel.fieldValue = FieldValue.detail(FieldValue.StringValue(string: "Baby"))
            self.brandViewModel.fieldValue = FieldValue.brand(FieldValue.StringValue(string: "Woolworths"))
//            self.barcodeViewModel.fieldValue = FieldValue.barcode(FieldValue.StringValue(string: "5012345678900"))
            
            self.amountViewModel.fieldValue = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
            self.servingViewModel.fieldValue = FieldValue.serving(FieldValue.DoubleValue(double: 50, string: "50", unit: .weight(.g)))
            
            self.densityViewModel.fieldValue = FieldValue.density(FieldValue.DensityValue(
                weight: FieldValue.DoubleValue(double: 20, string: "20", unit: .weight(.g)),
                volume: FieldValue.DoubleValue(double: 25, string: "25", unit: .volume(.mL)))
            )
            
            self.standardSizeViewModels = mockStandardSizes.fieldViewModels
            self.volumePrefixedSizeViewModels = mockVolumePrefixedSizes.fieldViewModels
            self.addSubscriptionsForSizeViewModels()

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
            (servingViewModel.fieldValue.doubleValue.unit.isMeasurementBased && (servingViewModel.fieldValue.doubleValue.double ?? 0) > 0)
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
                guard volumePrefixedSizeViewModels.containsSizeNamed(size.name) else {
                    return
                }
                addVolumePrefixedSizeViewModel(size.asFieldViewModelForUserInput)
            } else {
                guard standardSizeViewModels.containsSizeNamed(size.name) else {
                    return
                }
                addStandardSizeViewModel(size.asFieldViewModelForUserInput)
            }
        }
    }

    /// Returns true if the size was added
    func add(sizeViewModel: FieldViewModel) -> Bool {
        /// Make sure it's actually got a size in it first
        guard let size = sizeViewModel.size else { return false }
        
        if size.isVolumePrefixed {
            ///Make sure we don't already have one with the name
            guard !volumePrefixedSizeViewModels.containsSizeNamed(size.name) else {
                return false
            }
            withAnimation {
                addVolumePrefixedSizeViewModel(sizeViewModel)
            }
        } else {
            ///Make sure we don't already have one with the name
            guard !standardSizeViewModels.containsSizeNamed(size.name) else {
                return false
            }

            withAnimation {
                addStandardSizeViewModel(sizeViewModel)
            }
        }
        return true
    }
    
    func add(barcodeViewModel: FieldViewModel) -> Bool {
        guard let barcodeValue = barcodeViewModel.fieldValue.barcodeValue else { return false }
        
        guard !barcodeViewModels.contains(where: {
            $0.fieldValue.barcodeValue?.payloadString == barcodeValue.payloadString
        }) else {
            return false
        }
        
        withAnimation {
            addBarcodeViewModel(barcodeViewModel)
        }
        return true
    }
    
    func editStandardSizeViewModel(_ sizeViewModel: FieldViewModel, with newSizeViewModel: FieldViewModel) {
        if newSizeViewModel.size?.isVolumePrefixed == true {
            /// Remove it from the standard list
            standardSizeViewModels.removeAll(where: { $0.id == sizeViewModel.id })
            
            /// Append the new one to the volume based list
            addVolumePrefixedSizeViewModel(newSizeViewModel)
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
            addStandardSizeViewModel(newSizeViewModel)
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
        guard let newSize = newSizeViewModel.size, let oldSize = sizeViewModel.size else {
            return
        }
        
        /// if this was a standard
        if oldSize.isVolumePrefixed == false {
            editStandardSizeViewModel(sizeViewModel, with: newSizeViewModel)
        } else {
            editVolumeBasedSizeViewModel(sizeViewModel, with: newSizeViewModel)
        }
        
        /// if this size was used for either amount or serving—update it with the new size
        if amountViewModel.fieldValue.doubleValue.unit.size == oldSize {
            amountViewModel.fieldValue.doubleValue.unit.size = newSize
        }
        if servingViewModel.fieldValue.doubleValue.unit.size == oldSize {
            servingViewModel.fieldValue.doubleValue.unit.size = newSize
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
    
    var hasSourceImages: Bool {
        !imageViewModels.isEmpty
    }
    var hasSourceLink: Bool {
        linkInfo != nil
    }
    
    var hasSources: Bool {
        hasSourceImages || hasSourceLink
    }
    
    var shouldShowImagesButton: Bool {
        for fieldViewModel in allFieldViewModels {
            if fieldViewModel.fill.usesImage {
                return true
            }
        }
        return false
    }
    
    /// Returns how many
    var availableImagesCount: Int {
        /// Returns how many images can still be added to this food
        max(5 - imageViewModels.count, 0)
    }
}

import FoodLabelScanner
import MFPScraper

extension FoodFormViewModel {
    
    public enum MockCase: String, CaseIterable {
        case spinach = "spinach"
        case pumpkinSeeds = "pumpkin_seeds"
        case iceCream = "ice_cream"
        case milk = "milk"
        case yoghurt = "yoghurt"
        case starbucks = "starbucks"
        case mcdonalds = "mcdonalds"
        case subway = "subway"
        case googleEggs = "google_eggs"
        case vanillaFlour = "vanilla_flour"
        
        case phillyCheese = "philly_cheese"
        case chocolate = "chocolate"
        case tobleroneLabel = "toblerone_label"
        case tobleroneBarcode = "toblerone_barcode"

        public var name: String {
            rawValue
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
        
        public static var prefilledMocks: [MockCase] {
            allCases.filter { $0.mfpProcessedFood != nil }
        }
        
        public static var scannedMocks: [MockCase] {
            allCases.filter { $0.scanResult != nil }
        }
        
        public static var linkMocks: [MockCase] {
            allCases.filter { $0.linkUrlString != nil }
        }
        
        var image: UIImage? {
            sampleImage(imageFilename: rawValue)
        }
        
        var scanResult: ScanResult? {
            sampleScanResult(jsonFilename: rawValue)
        }
        
        var mfpProcessedFood: MFPProcessedFood? {
            sampleMFPProcessedFood(jsonFilename: "mfp_\(self.rawValue)")
        }
        
        var linkUrlString: String? {
            switch self {
            case .starbucks: return "https://www.starbucks.com/menu/product/407/hot/nutrition"
            case .mcdonalds: return "https://mcdonalds.com.au/maccas-food/nutrition"
            case .pumpkinSeeds: return "https://store.edenfoods.com/pumpkin-seeds-organic-4-oz/"
            case .subway: return "https://www.subway.com/en-AU/MenuNutrition/Nutrition"
            default:
                return nil
            }
        }
    }

    public static func mock(for mockCase: MockCase) -> FoodFormViewModel {
        let viewModel = FoodFormViewModel()
        
        viewModel.shouldShowWizard = false

        if let processedFood = mockCase.mfpProcessedFood {
            viewModel.prefill(processedFood)
        }

        if let image = mockCase.image, let scanResult = mockCase.scanResult {
            viewModel.imageViewModels.append(
                ImageViewModel(image: image, scanResult: scanResult)
            )
            viewModel.processScanResults()
            viewModel.imageSetStatus = .scanned
        }

        if let linkUrlString = mockCase.linkUrlString {
            viewModel.linkInfo = LinkInfo(linkUrlString)
        }
        
        return viewModel
    }
    
    public static var mockWith5Images: FoodFormViewModel {
        mockWithCases([.phillyCheese, .pumpkinSeeds, .googleEggs, .vanillaFlour, .starbucks])
    }
    
    public static func mockWithCases(_ cases: [MockCase]) -> FoodFormViewModel {
        
        let viewModel = FoodFormViewModel()
        
        viewModel.shouldShowWizard = false
        
        for mockCase in cases {
            guard let image = mockCase.image, let scanResult = mockCase.scanResult else {
                continue
            }
            viewModel.imageViewModels.append(
                ImageViewModel(image: image, scanResult: scanResult)
            )
        }
        viewModel.processScanResults()
        viewModel.imageSetStatus = .scanned

        return viewModel
    }

    
    public static var mock: FoodFormViewModel {
        let viewModel = FoodFormViewModel()
        
        guard let mfpProcessedFood = sampleMFPProcessedFood(10) else {
            fatalError("Couldn't load mock files")
        }
        
        viewModel.shouldShowWizard = false
        viewModel.prefill(mfpProcessedFood)
        return viewModel
    }
}

extension Size {
    var asFieldViewModelForUserInput: FieldViewModel {
        FieldViewModel(fieldValue: .size(.init(size: self, fill: .userInput)))
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
                self = .size(.init(size: newValue, fill: sizeValue.fill))
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


extension Array where Element == FieldViewModel {
    func containsSizeNamed(_ name: String) -> Bool {
        contains(where: { $0.isSizeNamed(name) })
    }
}

extension FieldViewModel {
    func isSizeNamed(_ name: String) -> Bool {
        size?.name == name
    }
}

extension FieldViewModel {
    var doubleValueDescription: String {
        guard !fieldValue.isEmpty else {
            return ""
        }
        return "\(fieldValue.doubleValue.string) \(fieldValue.doubleValue.unitDescription)"
    }
}

//MARK: - Subscriptions
extension FoodFormViewModel {
    
    /// We use this helper so that we ensure the view model subscribes to changes in the `FieldViewModel` instance.
    func addStandardSizeViewModel(_ sizeViewModel: FieldViewModel) {
        addSubscription(for: sizeViewModel)
        standardSizeViewModels.append(sizeViewModel)
    }
    
    func addBarcodeViewModel(_ barcodeViewModel: FieldViewModel) {
        addSubscription(for: barcodeViewModel)
        barcodeViewModels.append(barcodeViewModel)
    }

    func addVolumePrefixedSizeViewModel(_ sizeViewModel: FieldViewModel) {
        addSubscription(for: sizeViewModel)
        volumePrefixedSizeViewModels.append(sizeViewModel)
    }

    func addSubscription(for fieldViewModel: FieldViewModel) {
        subscriptions.append(
            fieldViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
        )
    }
}

//MARK: - Preview

extension FoodFormViewModel {

    func populateWithSampleImages(_ indexes: [Int]) {
        for index in indexes {
            populateWithSampleImage(index)
        }
    }

    func populateWithSampleImage(_ number: Int) {
        guard let image = sampleImage(number), let scanResult = sampleScanResult(number) else {
            fatalError("Couldn't populate sample image: \(number)")
        }
        imageViewModels.append(ImageViewModel(image: image, scanResult: scanResult))
    }

}
