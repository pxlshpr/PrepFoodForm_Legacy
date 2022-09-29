import SwiftUI
import PrepUnits
import SwiftUISugar
import MFPScraper
import SwiftHaptics
import NutritionLabelClassifier

public class FoodFormViewModel: ObservableObject {
    
    static public var shared = FoodFormViewModel()
    
    public init() { }
    
    //MARK: - Food Details
    @Published var name: FieldValue = .name()
    @Published var emoji: FieldValue = .emoji()
    @Published var detail: FieldValue = .detail()
    @Published var brand: FieldValue = .brand()
    @Published var barcode: FieldValue = .barcode()
    
    //MARK: Amount Per
    @Published var amount: FieldValue = .amount() {
        didSet {
            updateShouldShowDensitiesSection()
            if amount.doubleValue.unit != .serving {
                serving.doubleValue.double = nil
                serving.doubleValue.string = ""
                serving.doubleValue.unit = .weight(.g)
            }
        }
    }
    
    @Published var serving: FieldValue = .serving() {
        didSet {
            /// If we've got a serving-based unit for the serving size—modify it to make sure the values equate
            modifyServingUnitIfServingBased()
            updateShouldShowDensitiesSection()
//            if !servingString.isEmpty && amountString.isEmpty {
//                amountString = "1"
//            }
        }
    }
    
    //MARK: Sizes
    @Published var standardSizes: [Size] = []
    @Published var volumePrefixedSizes: [Size] = []

    //MARK: Density
    @Published var density = FieldValue.density()
    
    //MARK: Nutrition Facts
    @Published var energy: FieldValue = .energy()
    @Published var carb: FieldValue = .macro(FieldValue.MacroValue(macro: .carb))
    @Published var fat: FieldValue = .macro(FieldValue.MacroValue(macro: .fat))
    @Published var protein: FieldValue = .macro(FieldValue.MacroValue(macro: .protein))
    
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
    @Published var imageViewModels: [ImageViewModel] = []
    @Published var imageSetStatus: ImageStatus = .loading
    
    //MARK: Scan
    var scanTask: Task<(), any Error>? = nil
    
    @Published var isScanning = false {
        didSet {
            if isScanning {
                sourceType = .images
            }
            withAnimation {
                DispatchQueue.main.async {
//                    self.isClassifyingImage = self.isScanning || self.isImporting
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
//                isClassifyingImage = isScanning || isImporting
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

extension FoodFormViewModel {
    
    var allMicronutrientFields: [FieldValue] {
        micronutrients.reduce([FieldValue]()) { partialResult, tuple in
            partialResult + tuple.fieldValues
        }
    }
    var allFields: [FieldValue] {
        [
            name, emoji, detail, brand, barcode,
            amount, serving, density,
            energy, carb, fat, protein,
        ]
        + allMicronutrientFields
    }
    
    var allSizes: [Size] {
        standardSizes + volumePrefixedSizes
    }
    
    var hasNonUserInputFills: Bool {
        for field in allFields {
            if field.fillType != .userInput {
                return true
            }
        }
        for size in allSizes {
            if size.fillType != .userInput {
                return true
            }
        }
        return false
    }
    
    var shouldShowFillButton: Bool {
        hasNonUserInputFills
    }
    
    func imageDidFinishClassifying(_ imageViewModel: ImageViewModel) {
        guard imageSetStatus != .classified else {
            return
        }
        
        /// Used for testing currently—so that we can save the output and read it again without re-running the classifier
        imageViewModel.saveOutputToJson()
        
        if imageViewModels.allSatisfy({ $0.status == .classified }) {
            Haptics.successFeedback()
            withAnimation {
                imageSetStatus = .classified
            }
            processAllClassifierOutputs()
        }
    }
    
    var classifiedNutrientCount: Int {
        imageViewModels.reduce(0) { partialResult, imageViewModel in
            partialResult + (imageViewModel.output?.nutrients.rows.count ?? 0)
        }
    }
    
    func imageViewModel(forOutputId outputId: UUID) -> ImageViewModel? {
        imageViewModels.first(where: { $0.output?.id == outputId })
    }
}

extension ImageViewModel {
    func saveOutputToJson() {
        guard let output else {
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(output)
            
            if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                url.appendPathComponent("output.json")
                try data.write(to: url)
                print("📝 Wrote output to: \(url)")
            }
        } catch {
            print(error)
        }
    }
}
