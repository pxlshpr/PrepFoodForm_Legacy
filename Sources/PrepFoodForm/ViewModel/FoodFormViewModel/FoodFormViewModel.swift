import SwiftUI
import PrepUnits
import SwiftUISugar
import MFPScraper

public class FoodFormViewModel: ObservableObject {
    
    static public var shared = FoodFormViewModel()
    
    public init() { }
    
    //MARK: - Food Details
    @Published var name: FieldValue = .name()
    @Published var emoji = ""
    @Published var detail: FieldValue = .detail()
    @Published var brand = ""
    @Published var barcode = ""
    
    //MARK: Amount Per
    @Published public var amountString: String = "" {
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
    @Published var energy: FieldValue = .energy()
    @Published var carb: FieldValue = .macro(macro: .carb)
    @Published var fat: FieldValue = .macro(macro: .fat)
    @Published var protein: FieldValue = .macro(macro: .protein)
    
    @Published var micronutrients: [(group: NutrientTypeGroup, fieldValues: [FieldValue])] = [
        (NutrientTypeGroup.fats, [
            FieldValue(micronutrient: .saturatedFat),
            FieldValue(micronutrient: .monounsaturatedFat),
            FieldValue(micronutrient: .polyunsaturatedFat),
            FieldValue(micronutrient: .transFat),
            FieldValue(micronutrient: .cholesterol),
        ]),
        (NutrientTypeGroup.fibers, [
            FieldValue(micronutrient: .dietaryFiber),
            FieldValue(micronutrient: .solubleFiber),
            FieldValue(micronutrient: .insolubleFiber),
        ]),
        (NutrientTypeGroup.sugars, [
            FieldValue(micronutrient: .sugars),
            FieldValue(micronutrient: .addedSugars),
            FieldValue(micronutrient: .sugarAlcohols),
        ]),
        (NutrientTypeGroup.minerals, [
            FieldValue(micronutrient: .calcium),
            FieldValue(micronutrient: .chloride),
            FieldValue(micronutrient: .chromium),
            FieldValue(micronutrient: .copper),
            FieldValue(micronutrient: .iodine),
            FieldValue(micronutrient: .iron),
            FieldValue(micronutrient: .magnesium),
            FieldValue(micronutrient: .manganese),
            FieldValue(micronutrient: .molybdenum),
            FieldValue(micronutrient: .phosphorus),
            FieldValue(micronutrient: .potassium),
            FieldValue(micronutrient: .selenium),
            FieldValue(micronutrient: .sodium),
            FieldValue(micronutrient: .zinc),
        ]),
        (NutrientTypeGroup.vitamins, [
            FieldValue(micronutrient: .vitaminA),
            FieldValue(micronutrient: .vitaminB6),
            FieldValue(micronutrient: .vitaminB12),
            FieldValue(micronutrient: .vitaminC),
            FieldValue(micronutrient: .vitaminD),
            FieldValue(micronutrient: .vitaminE),
            FieldValue(micronutrient: .vitaminK),
            FieldValue(micronutrient: .biotin),
            FieldValue(micronutrient: .choline),
            FieldValue(micronutrient: .folate),
            FieldValue(micronutrient: .niacin),
            FieldValue(micronutrient: .pantothenicAcid),
            FieldValue(micronutrient: .riboflavin),
            FieldValue(micronutrient: .thiamin),
            FieldValue(micronutrient: .vitaminB2),
            FieldValue(micronutrient: .cobalamin),
            FieldValue(micronutrient: .folicAcid),
            FieldValue(micronutrient: .vitaminB1),
            FieldValue(micronutrient: .vitaminB3),
            FieldValue(micronutrient: .vitaminK2),
        ]),
        (NutrientTypeGroup.misc, [
            FieldValue(micronutrient: .caffeine),
            FieldValue(micronutrient: .ethanol),
            FieldValue(micronutrient: .taurine),
            FieldValue(micronutrient: .polyols),
            FieldValue(micronutrient: .gluten),
            FieldValue(micronutrient: .starch),
            FieldValue(micronutrient: .salt),
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
