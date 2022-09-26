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
    @Published var energyFact = NutritionFact(type: .energy)
    @Published var carbFact = NutritionFact(type: .macro(.carb))
    @Published var fatFact = NutritionFact(type: .macro(.fat))
    @Published var proteinFact = NutritionFact(type: .macro(.protein))
    @Published var micronutrients: [NutritionFact] = []
    
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
    
    @Published var showingWizard = true

    @Published var shouldShowDensitiesSection = false
}
