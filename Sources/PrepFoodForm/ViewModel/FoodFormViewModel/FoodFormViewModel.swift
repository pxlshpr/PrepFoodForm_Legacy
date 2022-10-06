import SwiftUI
import PrepUnits
import SwiftUISugar
import MFPScraper
import SwiftHaptics
import FoodLabelScanner
import FoodLabel

public class FoodFormViewModel: ObservableObject {
    
    static public var shared = FoodFormViewModel()
    
    public init() { }
    
    //MARK: - Food Details
    @Published var nameViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .name())
    @Published var emojiViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .emoji())
    @Published var detailViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .detail())
    @Published var brandViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .brand())
    @Published var barcodeViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .barcode())
    
    @Published var showingCameraImagePicker: Bool = false
    
    //MARK: Amount Per
    @Published var amountViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fillType: .userInput))) {
        didSet {
            updateShouldShowDensitiesSection()
            if amountViewModel.fieldValue.doubleValue.unit != .serving {
                servingViewModel.fieldValue.doubleValue.double = nil
                servingViewModel.fieldValue.doubleValue.string = ""
                servingViewModel.fieldValue.doubleValue.unit = .weight(.g)
            }
        }
    }
    
    @Published var servingViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: .serving()) {
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
    @Published var densityViewModel: FieldValueViewModel = FieldValueViewModel(fieldValue: FieldValue.density())

    /// These are used for the FoodLabel
    @Published public var energyValue: FoodLabelValue = .zero

    //MARK: Nutrition Facts
    @Published var energyViewModel: FieldValueViewModel = .init(fieldValue: .energy())
    @Published var carbViewModel: FieldValueViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
    @Published var fatViewModel: FieldValueViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
    @Published var proteinViewModel: FieldValueViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
    
    @Published var micronutrients: [(group: NutrientTypeGroup, fieldValueViewModels: [FieldValueViewModel])] = [
        (NutrientTypeGroup.fats, [
            .init(fieldValue: FieldValue(micronutrient: .saturatedFat)),
            .init(fieldValue: FieldValue(micronutrient: .monounsaturatedFat)),
            .init(fieldValue: FieldValue(micronutrient: .polyunsaturatedFat)),
            .init(fieldValue: FieldValue(micronutrient: .transFat)),
            .init(fieldValue: FieldValue(micronutrient: .cholesterol)),
        ]),
        (NutrientTypeGroup.fibers, [
            .init(fieldValue: FieldValue(micronutrient: .dietaryFiber)),
            .init(fieldValue: FieldValue(micronutrient: .solubleFiber)),
            .init(fieldValue: FieldValue(micronutrient: .insolubleFiber)),
        ]),
        (NutrientTypeGroup.sugars, [
            .init(fieldValue: FieldValue(micronutrient: .sugars)),
            .init(fieldValue: FieldValue(micronutrient: .addedSugars)),
            .init(fieldValue: FieldValue(micronutrient: .sugarAlcohols)),
        ]),
        (NutrientTypeGroup.minerals, [
            .init(fieldValue: FieldValue(micronutrient: .calcium)),
            .init(fieldValue: FieldValue(micronutrient: .chloride)),
            .init(fieldValue: FieldValue(micronutrient: .chromium)),
            .init(fieldValue: FieldValue(micronutrient: .copper)),
            .init(fieldValue: FieldValue(micronutrient: .iodine)),
            .init(fieldValue: FieldValue(micronutrient: .iron)),
            .init(fieldValue: FieldValue(micronutrient: .magnesium)),
            .init(fieldValue: FieldValue(micronutrient: .manganese)),
            .init(fieldValue: FieldValue(micronutrient: .molybdenum)),
            .init(fieldValue: FieldValue(micronutrient: .phosphorus)),
            .init(fieldValue: FieldValue(micronutrient: .potassium)),
            .init(fieldValue: FieldValue(micronutrient: .selenium)),
            .init(fieldValue: FieldValue(micronutrient: .sodium)),
            .init(fieldValue: FieldValue(micronutrient: .zinc)),
        ]),
        (NutrientTypeGroup.vitamins, [
            .init(fieldValue: FieldValue(micronutrient: .vitaminA)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminB1)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminB2)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminB3)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminB6)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminB12)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminC)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminD)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminE)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminK)),
            .init(fieldValue: FieldValue(micronutrient: .vitaminK2)),
            .init(fieldValue: FieldValue(micronutrient: .biotin)),
            .init(fieldValue: FieldValue(micronutrient: .choline)),
            .init(fieldValue: FieldValue(micronutrient: .cobalamin)),
            .init(fieldValue: FieldValue(micronutrient: .folate)),
            .init(fieldValue: FieldValue(micronutrient: .folicAcid)),
            .init(fieldValue: FieldValue(micronutrient: .niacin)),
            .init(fieldValue: FieldValue(micronutrient: .pantothenicAcid)),
            .init(fieldValue: FieldValue(micronutrient: .riboflavin)),
            .init(fieldValue: FieldValue(micronutrient: .thiamin)),
        ]),
        (NutrientTypeGroup.misc, [
            .init(fieldValue: FieldValue(micronutrient: .caffeine)),
            .init(fieldValue: FieldValue(micronutrient: .ethanol)),
            .init(fieldValue: FieldValue(micronutrient: .taurine)),
            .init(fieldValue: FieldValue(micronutrient: .polyols)),
            .init(fieldValue: FieldValue(micronutrient: .gluten)),
            .init(fieldValue: FieldValue(micronutrient: .starch)),
            .init(fieldValue: FieldValue(micronutrient: .salt)),
        ]),
    ]

    var autofillFieldValues: [FieldValue] = []
    
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
    @Published var showingEmojiPicker = false
    
    @Published var shouldShowWizard = true
    @Published var showingWizard = false

    @Published var shouldShowDensitiesSection = false
}

extension FoodFormViewModel {
    
    var allMicronutrientFieldValues: [FieldValue] {
        allMicronutrientFieldValueViewModels.map { $0.fieldValue }
    }

    var allMicronutrientFieldValueViewModels: [FieldValueViewModel] {
        micronutrients.reduce([FieldValueViewModel]()) { partialResult, tuple in
            partialResult + tuple.fieldValueViewModels
        }
    }
    
    var allFieldValues: [FieldValue] {
        allFieldValueViewModels.map { $0.fieldValue }
    }
    
    var allFieldValueViewModels: [FieldValueViewModel] {
        [
            nameViewModel, emojiViewModel, detailViewModel, brandViewModel, barcodeViewModel,
            amountViewModel, servingViewModel, densityViewModel,
            energyViewModel, carbViewModel, fatViewModel, proteinViewModel,
        ]
        + allMicronutrientFieldValueViewModels
    }
    
    var allSizes: [Size] {
        standardSizes + volumePrefixedSizes
    }
    
    var hasNonUserInputFills: Bool {
        for field in allFieldValues {
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
    
    func imageDidFinishClassifying(_ imageViewModel: ImageViewModel) {
        guard imageSetStatus != .classified else {
            return
        }
        
        Task(priority: .low) {
            /// Used for testing currently—so that we can save the scanResult and read it again without re-running the classifier
            imageViewModel.saveScanResultToJson()
        }
        
        if imageViewModels.allSatisfy({ $0.status == .classified }) {
            Haptics.successFeedback()
            DispatchQueue.main.async {
                withAnimation {
                    self.imageSetStatus = .classified
                    self.processScanResults()
                }
            }
        }
    }
    
    var classifiedNutrientCount: Int {
        imageViewModels.reduce(0) { partialResult, imageViewModel in
            partialResult + (imageViewModel.scanResult?.nutrients.rows.count ?? 0)
        }
    }
    
    func imageViewModel(forScanResultId scanResultId: UUID) -> ImageViewModel? {
        imageViewModels.first(where: { $0.scanResult?.id == scanResultId })
    }
}

extension ImageViewModel {
    func saveScanResultToJson() {
        guard let scanResult else {
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(scanResult)
            
            if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                url.appendPathComponent("scanResult.json")
                try data.write(to: url)
                print("📝 Wrote scanResult to: \(url)")
            }
        } catch {
            print(error)
        }
    }
}

extension MFPProcessedFood {
    func saveToJson() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            
            if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                url.appendPathComponent("mfpProcessedFood.json")
                try data.write(to: url)
                print("📝 Wrote mfpProcessedFood to: \(url)")
            }
        } catch {
            print(error)
        }
    }
}


extension FoodFormViewModel: FoodLabelDataSource {
    
    public var allowTapToChangeEnergyUnit: Bool {
        false
    }
    
    public var nutrients: [NutrientType : Double] {
        var nutrients: [NutrientType : Double] = [:]
        for (_, fieldValueViewModels) in micronutrients {
            for fieldValueViewModel in fieldValueViewModels {
                guard case .micro = fieldValueViewModel.fieldValue else {
                    continue
                }
                nutrients[fieldValueViewModel.fieldValue.microValue.nutrientType] = fieldValueViewModel.fieldValue.double
            }
        }
        return nutrients
    }
    
    public var showFooterText: Bool {
        false
    }
    
    public var showRDAValues: Bool {
        false
    }
    
    public var amountPerString: String {
        amountDescription
    }
    
    public var carbAmount: Double {
        carbViewModel.fieldValue.double ?? 0
    }
    
    public var proteinAmount: Double {
        proteinViewModel.fieldValue.double ?? 0
    }
    
    public var fatAmount: Double {
        fatViewModel.fieldValue.double ?? 0
    }
    
//    public var energyAmount: Double {
//        energyViewModel.fieldValue.double ?? 0
//    }
}
