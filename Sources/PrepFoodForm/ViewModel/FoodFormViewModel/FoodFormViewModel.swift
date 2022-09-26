import SwiftUI
import PrepUnits
import SwiftUISugar
import MFPScraper

public class FoodFormViewModel: ObservableObject {
    
    static public var shared = FoodFormViewModel()
    
    public init() { }
    
    //MARK: - Food Details
    @Published var name = FieldValue(identifier: .name)
    @Published var emoji = ""
    @Published var detail = FieldValue(identifier: .detail)
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
    @Published var energy = FieldValue(identifier: .energy)
    @Published var carb = FieldValue(identifier: .macro(.carb))
    @Published var fat = FieldValue(identifier: .macro(.fat))
    @Published var protein = FieldValue(identifier: .macro(.protein))
    
    @Published var micronutrients: [(group: NutrientTypeGroup, fieldValues: [FieldValue])] = [
        (NutrientTypeGroup.fats, [
            FieldValue(identifier: .micro(.saturatedFat)),
            FieldValue(identifier: .micro(.monounsaturatedFat)),
            FieldValue(identifier: .micro(.polyunsaturatedFat)),
            FieldValue(identifier: .micro(.transFat)),
            FieldValue(identifier: .micro(.cholesterol)),
        ]),
        (NutrientTypeGroup.fibers, [
            FieldValue(identifier: .micro(.dietaryFiber)),
            FieldValue(identifier: .micro(.solubleFiber)),
            FieldValue(identifier: .micro(.insolubleFiber)),
        ]),
        (NutrientTypeGroup.sugars, [
            FieldValue(identifier: .micro(.sugars)),
            FieldValue(identifier: .micro(.addedSugars)),
            FieldValue(identifier: .micro(.sugarAlcohols)),
        ]),
        (NutrientTypeGroup.minerals, [
            FieldValue(identifier: .micro(.calcium)),
            FieldValue(identifier: .micro(.chloride)),
            FieldValue(identifier: .micro(.chromium)),
            FieldValue(identifier: .micro(.copper)),
            FieldValue(identifier: .micro(.iodine)),
            FieldValue(identifier: .micro(.iron)),
            FieldValue(identifier: .micro(.magnesium)),
            FieldValue(identifier: .micro(.manganese)),
            FieldValue(identifier: .micro(.molybdenum)),
            FieldValue(identifier: .micro(.phosphorus)),
            FieldValue(identifier: .micro(.potassium)),
            FieldValue(identifier: .micro(.selenium)),
            FieldValue(identifier: .micro(.sodium)),
            FieldValue(identifier: .micro(.zinc)),
        ]),
        (NutrientTypeGroup.vitamins, [
            FieldValue(identifier: .micro(.vitaminA)),
            FieldValue(identifier: .micro(.vitaminB6)),
            FieldValue(identifier: .micro(.vitaminB12)),
            FieldValue(identifier: .micro(.vitaminC)),
            FieldValue(identifier: .micro(.vitaminD)),
            FieldValue(identifier: .micro(.vitaminE)),
            FieldValue(identifier: .micro(.vitaminK)),
            FieldValue(identifier: .micro(.biotin)),
            FieldValue(identifier: .micro(.choline)),
            FieldValue(identifier: .micro(.folate)),
            FieldValue(identifier: .micro(.niacin)),
            FieldValue(identifier: .micro(.pantothenicAcid)),
            FieldValue(identifier: .micro(.riboflavin)),
            FieldValue(identifier: .micro(.thiamin)),
            FieldValue(identifier: .micro(.vitaminB2)),
            FieldValue(identifier: .micro(.cobalamin)),
            FieldValue(identifier: .micro(.folicAcid)),
            FieldValue(identifier: .micro(.vitaminB1)),
            FieldValue(identifier: .micro(.vitaminB3)),
            FieldValue(identifier: .micro(.vitaminK2)),
        ]),
        (NutrientTypeGroup.misc, [
            FieldValue(identifier: .micro(.caffeine)),
            FieldValue(identifier: .micro(.ethanol)),
            FieldValue(identifier: .micro(.taurine)),
            FieldValue(identifier: .micro(.polyols)),
            FieldValue(identifier: .micro(.gluten)),
            FieldValue(identifier: .micro(.starch)),
            FieldValue(identifier: .micro(.salt)),
        ]),
    ]
    
    //MARK: - Source
    @Published var sourceType: SourceType = .manualEntry
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
    
    @Published var prefilledFood: MFPProcessedFood? = nil
    
    //MARK: - View-related
    @Published var showingNutrientsPerAmountForm = false
    @Published var showingNutrientsPerServingForm = false
    @Published var showingMicronutrientsPicker = false
    @Published var showingThirdPartySearch = false
    
    @Published var shouldShowWizard = true
    @Published var showingWizard = false

    @Published var shouldShowDensitiesSection = false
}
