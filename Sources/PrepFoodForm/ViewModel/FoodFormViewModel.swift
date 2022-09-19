import SwiftUI
import PrepUnits
import SwiftUISugar

public class FoodFormViewModel: ObservableObject {

    public init() { }

    static public var shared = FoodFormViewModel()
    
    @Published var path: [FoodFormRoute] = []
    @Published var showingMicronutrientsPicker = false
    @Published var shouldShowDensitiesSection: Bool = false
    
    //MARK: - Food Details
    @Published var name: String = ""
    @Published var emoji = ""
    @Published var detail = ""
    @Published var brand = ""
    @Published var barcode = ""

    //MARK: Amount Per
    @Published var amountString: String = "" {
        didSet {
            updateShouldShowDensitiesSection()
        }
    }
    
    @Published var amountUnit: FormUnit = .serving {
        didSet {
            updateShouldShowDensitiesSection()
            if amountUnit != .serving {
                servingString = ""
                servingUnit = .weight(.g)
            }
        }
    }
    @Published var servingString: String = "" {
        didSet {
            /// If we've got a serving-based unit for the serving size—modify it to make sure the values equate
            modifyServingUnitIfServingBased()
            updateShouldShowDensitiesSection()
//                if !servingString.isEmpty && amountString.isEmpty {
//                    amountString = "1"
//                }
        }
    }
    @Published var servingUnit: FormUnit = .weight(.g) {
        didSet {
            updateShouldShowDensitiesSection()
        }
    }
    
    //MARK: Sizes
    @Published var standardSizes: [Size] = []
    @Published var volumePrefixedSizes: [Size] = []
    @Published var summarySizeViewModels: [SizeViewModel] = []
    
    //MARK: Density
    @Published var densityWeightString: String = ""
    @Published var densityWeightUnit: FormUnit = .weight(.g)
    @Published var densityVolumeString: String = ""
    @Published var densityVolumeUnit: FormUnit = .volume(.mL)

    //MARK: Nutrition Facts
    @Published var energyFact = NutritionFact(type: .energy)
    @Published var carbFact = NutritionFact(type: .macro(.carb))
    @Published var fatFact = NutritionFact(type: .macro(.fat))
    @Published var proteinFact = NutritionFact(type: .macro(.protein))
    @Published var micronutrients: [NutritionFact] = []
    
    //MARK: - Source
    @Published var sourceType: SourceType? = nil
    @Published var isProcessingSource = false
    @Published var sourceImageViewModels: [SourceImageViewModel] = []
    
    //MARK: Scan
    var scanTask: Task<(), any Error>? = nil
    
    @Published var isScanning = false {
        didSet {
            if isScanning {
                sourceType = .images
            }
            withAnimation {
                DispatchQueue.main.async {
                    self.isProcessingSource = self.isScanning || self.isImporting
                }
            }
        }
    }
    
    @Published var numberOfScannedImages: Int = 0
    
    @Published var numberOfScannedDataPoints: Int? = nil
    
    //MARK: - Import
    @Published var isImporting = false {
        didSet {
            if isImporting {
                sourceType = .onlineSource
            }
            withAnimation {
                isProcessingSource = isScanning || isImporting
            }
        }
    }
}

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
        || !energyFact.isEmpty
        || !carbFact.isEmpty
        || !fatFact.isEmpty
        || !proteinFact.isEmpty
        || !micronutrients.isEmpty
//            || amountUnit != .serving
//            || servingUnit != .weight(.g)
//            || !densityWeightUnit.isEmpty
//            || !densityVolumeUnit.isEmpty
    }
    
    var sourceIncludesImages: Bool {
        sourceType?.includesImages ?? false
    }
    
    public func prefill(onlyServing: Bool = false, includeAllMicronutrients: Bool = false) {
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
            self.name = "Carrot"
            self.emoji = "🥕"
            self.detail = "Baby"
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
            
            self.energyFact = NutritionFact(type: .energy, amount: 125, unit: .kj, inputType: .manuallyEntered)
            self.carbFact = NutritionFact(type: .macro(.carb), amount: 23, unit: .g, inputType: .manuallyEntered)
            self.fatFact = NutritionFact(type: .macro(.fat), amount: 8, unit: .g, inputType: .manuallyEntered)
            self.proteinFact = NutritionFact(type: .macro(.protein), amount: 3, unit: .g, inputType: .manuallyEntered)
            
            self.micronutrients = includeAllMicronutrients ? mockAllMicronutrients : mockMicronutrients
        }
    }
    func nutrientValue(for nutrientType: NutrientType) -> Double? {
        guard let nutritionFact = nutritionFact(for: .micro(nutrientType)) else {
            return nil
        }
        return nutritionFact.amount
    }
    var hasNutritionFacts: Bool {
        !micronutrients.isEmpty
        || !energyFact.isEmpty
        || !carbFact.isEmpty
        || !fatFact.isEmpty
        || !proteinFact.isEmpty
    }
    
    func removeFact(of type: NutritionFactType) {
        setNutritionFactType(type, withAmount: nil, unit: nil)
    }

    func setNutritionFactType(_ type: NutritionFactType, withAmount amount: Double?, unit: NutritionFactUnit?) {
        
        let makingEmpty = amount == nil && unit == nil
        
        func newFact(from fact: NutritionFact, amount: Double?, unit: NutritionFactUnit?) -> NutritionFact {
            /// We're doing this to trigger an update immediately
            let fact = fact
            fact.amount = amount
            fact.unit = unit
            if makingEmpty {
                fact.inputType = nil
            }
            return fact
        }

        switch type {
        case .energy:
            energyFact = newFact(from: energyFact, amount: amount, unit: unit)
        case .macro(let macro):
            switch macro {
            case .carb:
                carbFact = newFact(from: carbFact, amount: amount, unit: unit)
            case .protein:
                proteinFact = newFact(from: proteinFact, amount: amount, unit: unit)
            case .fat:
                fatFact = newFact(from: fatFact, amount: amount, unit: unit)
            }
        case .micro(let nutrientType):
            guard !makingEmpty else {
                micronutrients.removeAll(where: { $0.nutrientType == nutrientType })
                return
            }
            guard let fact = micronutrients.first(where: { $0.nutrientType == nutrientType }),
                  let index = micronutrients.firstIndex(of: fact) else {
                micronutrients.append(NutritionFact(type: .micro(nutrientType)))
                return
            }
            let newFact = newFact(from: fact, amount: amount, unit: unit)
            micronutrients.removeAll(where: { $0.nutrientType == nutrientType })
            micronutrients.insert(newFact, at: index)
        }
    }
}

extension FoodFormViewModel {

    var carbAmount: Double {
        carbFact.amount ?? 0
    }
    
    var proteinAmount: Double {
        proteinFact.amount ?? 0
    }
    
    var fatAmount: Double {
        fatFact.amount ?? 0
    }
    
    var hasMicronutrients: Bool {
        !micronutrients.isEmpty
    }
    
    func hasNutrientFor(_ nutrientType: NutrientType) -> Bool {
        nutritionFact(for: .micro(nutrientType)) != nil
    }
    
    var energyAmount: Double {
        energyFact.amount ?? 0
    }
    
    func nutritionFact(for type: NutritionFactType) -> NutritionFact? {
        switch type {
        case .energy:
            return energyFact
        case .macro(let macro):
            switch macro {
            case .carb:
                return carbFact
            case .fat:
                return fatFact
            case .protein:
                return proteinFact
            }
        case .micro:
            return micronutrients.first(where: { $0.type == type })
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
}

let mockMicronutrients = [
    NutritionFact(type: .micro(.saturatedFat), amount: 25, unit: .g, inputType: .manuallyEntered),
    NutritionFact(type: .micro(.biotin), amount: 5, unit: .g, inputType: .manuallyEntered),
    NutritionFact(type: .micro(.caffeine), amount: 250, unit: .mg, inputType: .manuallyEntered),
    NutritionFact(type: .micro(.addedSugars), amount: 35, unit: .g, inputType: .manuallyEntered),
]

var mockAllMicronutrients: [NutritionFact] {
    NutrientType.allCases.map {
        NutritionFact(type: .micro($0), amount: Double.random(in: 1...300), unit: $0.units.first!.nutritionFactUnit, inputType: .manuallyEntered)
    }
}
