import MFPScraper
import SwiftUI
import PrepDataTypes
import VisionSugar

extension FoodFormViewModel {
    func fieldValueFromPrefilledFood(for fieldValue: FieldValue) -> FieldValue? {
        switch fieldValue {
        case .energy:
            return prefilledFood?.energyFieldValue
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: return prefilledFood?.carbFieldValue
            case .fat: return prefilledFood?.fatFieldValue
            case .protein: return prefilledFood?.proteinFieldValue
            }
        case .micro(let microValue):
            return prefilledFood?.microFieldValue(for: microValue.nutrientType)
        default:
            return nil
        }
    }
    
    func simulateThirdPartyImport() {
//        prefill(MockProcessedFood.Banana)
    }
    
    func simulateAddingImage(_ number: Int) {
//        let image = PrepFoodForm.sampleImage(number)!
//        let imageViewModel = ImageViewModel(image)
//        imageViewModels.append(imageViewModel)
    }
    
    func simulateImageSelection() {
        
//        sourceType = .images
        imageSetStatus = .scanning
        
        simulateAddingImage(9)
//        simulateAddingImage(7)
//        simulateAddingImage(1)
//        simulateAddingImage(2)
//        simulateAddingImage(3)
//        simulateAddingImage(4)

        dismissWizard()
//        withAnimation {
//            showingWizard = false
//        }
    }
    
    func simulateImageScanning(_ indexes: [Int]) {
//        sourceType = .images
        populateWithSampleImages(indexes)
        processScanResults()
        imageSetStatus = .scanned
        dismissWizard()
//        withAnimation {
//            showingWizard = false
//        }
    }
    
    func dismissWizard() {
        withAnimation(WizardAnimation) {
            showingWizard = false
        }
        withAnimation(.easeOut(duration: 0.1)) {
            showingWizardOverlay = false
        }
        formDisabled = false
    }
    

    func prefill(_ food: MFPProcessedFood) {
        
        /// For testing purposes
        Task(priority: .low) {
            food.saveToJson()
        }
        
        self.showingThirdPartySearch = false

        prefillDetails(from: food)
        
        /// Create sizes first as we might have one as the amount or serving unit
        prefillSizes(from: food)
        
        prefillDensity(from: food)
        
        prefillAmountPer(from: food)
        prefillNutrients(from: food)

        updateShouldShowDensitiesSection()

        prefilledFood = food
        
        dismissWizard()
//        withAnimation {
//            showingWizard = false
//        }
    }
    
    func prefillDetails(from food: MFPProcessedFood) {
        /// We only ever prefill it at the beginning, so we can be sure there aren't any user-input values already
        if let fieldValue = food.nameFieldValue {
            nameViewModel.value = fieldValue
        }
        if let fieldValue = food.detailFieldValue {
            detailViewModel.value = fieldValue
        }
        if let fieldValue = food.brandFieldValue {
            brandViewModel.value = fieldValue
        }
    }

    func prefillSizes(from food: MFPProcessedFood) {
        for size in food.sizes.filter({ !$0.isDensity }) {
            prefillSize(size)
        }
    }
    
    func prefillSize(_ processedSize: MFPProcessedFood.Size) {
        let fieldViewModel: Field = .init(fieldValue: processedSize.fieldValue)
        if processedSize.isVolumePrefixed {
            addVolumePrefixedSizeViewModel(fieldViewModel)
        } else {
            addStandardSizeViewModel(fieldViewModel)
        }
    }
    
    func prefillSize(_ size: FormSize) {
        let fieldViewModel: Field = .init(fieldValue: size.fieldValue)
        if size.isVolumePrefixed {
            addVolumePrefixedSizeViewModel(fieldViewModel)
        } else {
            addStandardSizeViewModel(fieldViewModel)
        }
    }

    func prefillDensity(from food: MFPProcessedFood) {
        guard let fieldValue = food.densityFieldValue else { return }
        densityViewModel = .init(fieldValue: fieldValue)
    }

    func prefillAmountPer(from food: MFPProcessedFood) {
        prefillAmount(from: food)
        prefillServing(from: food)
    }
    
    func prefillAmount(from food: MFPProcessedFood) {
        guard let fieldValue = food.amountFieldValue else {
            return
        }
        
//        /// If the amount had a size as a unit???prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        amountViewModel.value = fieldValue
    }
    
    func prefillServing(from food: MFPProcessedFood) {
        guard let fieldValue = food.servingFieldValue else {
            return
        }
        
//        /// If the serving had a size as a unit???prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        self.servingViewModel = .init(fieldValue: fieldValue)
    }
    
    func prefillNutrients(from food: MFPProcessedFood) {
        self.energyViewModel = .init(fieldValue: food.energyFieldValue)
        self.carbViewModel = .init(fieldValue: food.carbFieldValue)
        self.fatViewModel = .init(fieldValue: food.fatFieldValue)
        self.proteinViewModel = .init(fieldValue: food.proteinFieldValue)
        
        setMicronutrients(with: food.microFieldValues)
    }
    
    func setMicronutrients(with fieldValues: [FieldValue]) {
        for groupIndex in micronutrients.indices {
            for index in micronutrients[groupIndex].fields.indices {
                guard let nutrientType = micronutrients[groupIndex].fields[index].nutrientType,
                      let fieldValue = fieldValues.first(where: { $0.microValue.nutrientType == nutrientType })
                else {
                    continue
                }
                let fieldViewModel = Field(fieldValue: fieldValue)
                micronutrients[groupIndex].fields[index].copyData(from: fieldViewModel)
            }
        }
    }
}

//MARK: FFVM + Prefill Helpers
extension FoodFormViewModel {
    
    func hasPrefillOptions(for fieldValue: FieldValue) -> Bool {
        !prefillOptionFieldValues(for: fieldValue).isEmpty
    }


    /**
     Returns true if there is at least one available (unused`RecognizedText` in all the `ScanResult`s that is compatible with the `fieldValue`
     */
    func hasAvailableTexts(for fieldValue: FieldValue) -> Bool {
        !availableTexts(for: fieldValue).isEmpty
    }
    
    func availableTexts(for fieldValue: FieldValue) -> [RecognizedText] {
        var availableTexts: [RecognizedText] = []
        for imageViewModel in imageViewModels {
            let texts = fieldValue.usesValueBasedTexts ? imageViewModel.textsWithFoodLabelValues : imageViewModel.texts
//            let filtered = texts.filter { isNotUsingText($0) }
            availableTexts.append(contentsOf: texts)
        }
        return availableTexts
    }

//    func texts(for fieldValue: FieldValue) -> [RecognizedText] {
//        var texts: [RecognizedText] = []
//        for scanResult in scanResults {
//            let filtered = scanResult.texts.filter {
//                $0.isFillOptionFor(fieldValue)
//            }
//            texts.append(contentsOf: filtered)
//        }
//        return texts
//    }

    func isNotUsingText(_ text: RecognizedText) -> Bool {
        fieldValueUsing(text: text) == nil
    }
    /**
     Returns the `fieldValue` (if any) that is using the `RecognizedText`
     */
    func fieldValueUsing(text: RecognizedText) -> FieldValue? {
        allFieldValues.first(where: {
            $0.fill.uses(text: text)
        })
    }
}
