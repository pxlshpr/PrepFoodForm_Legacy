import SwiftUI
import PrepUnits
import SwiftUISugar
import MFPScraper
import SwiftHaptics
import FoodLabelScanner
import FoodLabel
import PhotosUI
import Combine
public class FoodFormViewModel: ObservableObject {
    
    static public var shared = FoodFormViewModel()
    
    var sizeBeingEdited: Size? = nil
    
    func clearFieldModels() {
        amountViewModel = .init(fieldValue: .amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .userInput)))
        servingViewModel = .init(fieldValue: .serving())
        densityViewModel = .init(fieldValue: FieldValue.density())
        energyViewModel = .init(fieldValue: .energy())
        carbViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
        fatViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
        proteinViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
        micronutrients = DefaultMicronutrients()
        standardSizeViewModels = []
        volumePrefixedSizeViewModels = []
        
        addSubscriptionsForAllFieldViewModels()
        
        scannedFieldValues = []
    }
    
    var availableColumns: [String]? {
        for scanResult in scanResults {
            if let header1 = scanResult.headers?.header1Type?.description,
               let header2 = scanResult.headers?.header2Type?.description {
                return [header1, header2]
            }
        }
        return nil
    }
    
    var subscriptions: [AnyCancellable] = []
    
    func addSubscriptionsForAllFieldViewModels() {
        for viewModel in allFieldViewModels {
            addSubscription(for: viewModel)
        }
    }
    
    public init() {
        /// We add subscriptions to all field values except for sizes (as will have none to begin with—those will be set as they get added)
        addSubscriptionsForAllFieldViewModels()
//        subscriptions.append(
//            contentsOf: [
//                nameViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                emojiViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                detailViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                brandViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                barcodeViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                amountViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                servingViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                energyViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                carbViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                fatViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                proteinViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//                densityViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() },
//            ]
//        )
//        for sizeViewModel in standardSizeViewModels {
//            subscriptions.append(
//                sizeViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
//            )
//        }
//        for sizeViewModel in volumePrefixedSizeViewModels {
//            subscriptions.append(
//                sizeViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
//            )
//        }
//        for group in micronutrients {
//            for fieldViewModel in group.fieldViewModels {
//                subscriptions.append(
//                    fieldViewModel.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
//                )
//            }
//        }
    }
    

    //MARK: - Food Details
    @Published var nameViewModel: FieldViewModel = FieldViewModel(fieldValue: .name())
    @Published var emojiViewModel: FieldViewModel = FieldViewModel(fieldValue: .emoji())
    @Published var detailViewModel: FieldViewModel = FieldViewModel(fieldValue: .detail())
    @Published var brandViewModel: FieldViewModel = FieldViewModel(fieldValue: .brand())
    @Published var barcodeViewModel: FieldViewModel = FieldViewModel(fieldValue: .barcode())
    @Published var amountViewModel: FieldViewModel = FieldViewModel(fieldValue: .amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .userInput)))
    @Published var servingViewModel: FieldViewModel = FieldViewModel(fieldValue: .serving())
    @Published var energyViewModel: FieldViewModel = .init(fieldValue: .energy())
    @Published var carbViewModel: FieldViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
    @Published var fatViewModel: FieldViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
    @Published var proteinViewModel: FieldViewModel = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
    @Published var densityViewModel: FieldViewModel = FieldViewModel(fieldValue: FieldValue.density(FieldValue.DensityValue()))

    @Published var standardSizeViewModels: [FieldViewModel] = []
    @Published var volumePrefixedSizeViewModels: [FieldViewModel] = []
    @Published var micronutrients: [MicroGroupTuple] = DefaultMicronutrients()

    var scannedFieldValues: [FieldValue] = []
    
    /// These are used for the FoodLabel
    @Published public var energyValue: FoodLabelValue = .zero

    //MARK: - Source
//    @Published var sourceType: SourceType = .manualEntry
    @Published var imageViewModels: [ImageViewModel] = []
    @Published var imageSetStatus: ImageStatus = .loading
    @Published var linkInfo: LinkInfo? = nil

    @Published var prefilledFood: MFPProcessedFood? = nil

    //MARK: - View-related
    @Published var showingNutrientsPerAmountForm = false
    @Published var showingNutrientsPerServingForm = false
    @Published var showingMicronutrientsPicker = false
    @Published var showingThirdPartySearch = false
    @Published var showingEmojiPicker = false
    
    @Published var showingSourceMenu = false
    @Published var showingPhotosMenu = false
    @Published var showingAddLinkMenu = false
    @Published var showingRemoveImagesConfirmation = false
    @Published var showingRemoveLinkConfirmation = false

    @Published var showingCamera: Bool = false
    @Published var showingFoodLabelCamera: Bool = false
    
    @Published var shouldShowWizard = true
    @Published var showingWizard = false

    @Published var shouldShowDensitiesSection = false
    
    @Published var selectedPhotos: [PhotosPickerItem] = []
}

extension FoodFormViewModel {
    
    func includeMicronutrients(for nutrientTypes: [NutrientType]) {
        for g in micronutrients.indices {
            for f in micronutrients[g].fieldViewModels.indices {
                guard let nutrientType = micronutrients[g].fieldViewModels[f].nutrientType,
                      nutrientTypes.contains(nutrientType) else {
                    continue
                }
                micronutrients[g].fieldViewModels[f].fieldValue.microValue.isIncluded = true
            }
        }
    }
    
    func submittedSourceLink(_ string: String) {
        //TODO: Validate link here before saving
        self.linkInfo = LinkInfo(string)
    }
    
    func amountChanged() {
        updateShouldShowDensitiesSection()
        if amountViewModel.fieldValue.doubleValue.unit != .serving {
            servingViewModel.fieldValue.doubleValue.double = nil
            servingViewModel.fieldValue.doubleValue.string = ""
            servingViewModel.fieldValue.doubleValue.unit = .weight(.g)
        }
    }
    
    func servingChanged() {
        /// If we've got a serving-based unit for the serving size—modify it to make sure the values equate
        modifyServingUnitIfServingBased()
        updateShouldShowDensitiesSection()
//        if !servingString.isEmpty && amountString.isEmpty {
//            amountString = "1"
//        }
    }
    var allMicronutrientFieldValues: [FieldValue] {
        allMicronutrientFieldViewModels.map { $0.fieldValue }
    }

    var allMicronutrientFieldViewModels: [FieldViewModel] {
        micronutrients.reduce([FieldViewModel]()) { partialResult, tuple in
            partialResult + tuple.fieldViewModels
        }
    }
    
    var allFieldValues: [FieldValue] {
        allFieldViewModels.map { $0.fieldValue }
    }

    var allSingleFieldViewModels: [FieldViewModel] {
        [
            nameViewModel, emojiViewModel, detailViewModel, brandViewModel, barcodeViewModel,
            amountViewModel, servingViewModel, densityViewModel,
            energyViewModel, carbViewModel, fatViewModel, proteinViewModel,
        ]
    }

    var allFieldViewModels: [FieldViewModel] {
        allSingleFieldViewModels
        + allMicronutrientFieldViewModels
        + standardSizeViewModels
        + volumePrefixedSizeViewModels
    }
    
    var allSizeViewModels: [FieldViewModel] {
        standardSizeViewModels + volumePrefixedSizeViewModels
    }
    
    var hasNonUserInputFills: Bool {
        for field in allFieldValues {
            if field.fill != .userInput {
                return true
            }
        }
        
        for model in allSizeViewModels {
            if model.fieldValue.fill != .userInput {
                return true
            }
        }
        return false
    }
    
    func imageDidFinishScanning(_ imageViewModel: ImageViewModel) {
        guard imageSetStatus != .scanned else {
            return
        }
        
        Task(priority: .low) {
            /// Used for testing currently—so that we can save the scanResult and read it again without re-running the classifier
            imageViewModel.saveScanResultToJson()
        }
        
        if imageViewModels.allSatisfy({ $0.status == .scanned }) {
            Haptics.successFeedback()
            DispatchQueue.main.async {
                withAnimation {
                    self.imageSetStatus = .scanned
                    self.processScanResults()
                }
            }
        }
    }

    func imageDidFinishLoading(_ imageViewModel: ImageViewModel) {
        DispatchQueue.main.async {
            withAnimation {
                self.imageSetStatus = .scanning
            }
        }
    }

    var scannedNutrientCount: Int {
        imageViewModels.reduce(0) { partialResult, imageViewModel in
            partialResult + (imageViewModel.scanResult?.nutrients.rows.count ?? 0)
        }
    }
    
    var scannedColumnCount: Int {
        imageViewModels.first?.scanResult?.columnCount ?? 1
    }

    func imageViewModel(forScanResultId scanResultId: UUID) -> ImageViewModel? {
        imageViewModels.first(where: { $0.scanResult?.id == scanResultId })
    }
    
    var densityDescription: String? {
        densityViewModel.fieldValue.densityValue?.description(weightFirst: isWeightBased)
    }
}

extension ScanResult {
    var columnCount: Int {
        headers?.header2Type != nil ? 2 : 1
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
        for (_, fieldViewModels) in micronutrients {
            for fieldViewModel in fieldViewModels {
                guard case .micro = fieldViewModel.fieldValue else {
                    continue
                }
                nutrients[fieldViewModel.fieldValue.microValue.nutrientType] = fieldViewModel.fieldValue.double
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
        amountViewModel.doubleValueDescription
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

typealias MicroGroupTuple = (group: NutrientTypeGroup, fieldViewModels: [FieldViewModel])
func DefaultMicronutrients() -> [MicroGroupTuple] {
    [
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
}
