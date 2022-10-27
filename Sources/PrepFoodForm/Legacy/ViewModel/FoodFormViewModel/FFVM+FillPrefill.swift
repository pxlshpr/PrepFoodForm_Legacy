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
        prefill(MockProcessedFood.Banana)
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
    
    func dismissWizard() {
        withAnimation(WizardAnimation) {
            showingWizard = false
        }
        withAnimation(.easeOut(duration: 0.1)) {
            showingWizardOverlay = false
        }
        formDisabled = false
    }
    
    func prefillDetails(from food: MFPProcessedFood) {
        /// We only ever prefill it at the beginning, so we can be sure there aren't any user-input values already
        if let fieldValue = food.nameFieldValue {
            nameViewModel.fieldValue = fieldValue
        }
        if let fieldValue = food.detailFieldValue {
            detailViewModel.fieldValue = fieldValue
        }
        if let fieldValue = food.brandFieldValue {
            brandViewModel.fieldValue = fieldValue
        }
    }

    func prefillSizes(from food: MFPProcessedFood) {
        for size in food.sizes.filter({ !$0.isDensity }) {
            prefillSize(size)
        }
    }
    
    func prefillSize(_ processedSize: MFPProcessedFood.Size) {
        let fieldViewModel: FieldViewModel = .init(fieldValue: processedSize.fieldValue)
        if processedSize.isVolumePrefixed {
            addVolumePrefixedSizeViewModel(fieldViewModel)
        } else {
            addStandardSizeViewModel(fieldViewModel)
        }
    }
    
    func prefillSize(_ size: FormSize) {
        let fieldViewModel: FieldViewModel = .init(fieldValue: size.fieldValue)
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
        
//        /// If the amount had a size as a unit—prefill that too
//        if case .size(let size, _) = fieldValue.doubleValue.unit {
//            prefillSize(size)
//        }
        
        amountViewModel.fieldValue = fieldValue
    }
    
    func prefillServing(from food: MFPProcessedFood) {
        guard let fieldValue = food.servingFieldValue else {
            return
        }
        
//        /// If the serving had a size as a unit—prefill that too
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
            for index in micronutrients[groupIndex].fieldViewModels.indices {
                guard let nutrientType = micronutrients[groupIndex].fieldViewModels[index].nutrientType,
                      let fieldValue = fieldValues.first(where: { $0.microValue.nutrientType == nutrientType })
                else {
                    continue
                }
                let fieldViewModel = FieldViewModel(fieldValue: fieldValue)
                micronutrients[groupIndex].fieldViewModels[index].copyData(from: fieldViewModel)
            }
        }
    }
}

extension FieldViewModel {
    var nutrientType: NutrientType? {
        fieldValue.microValue.nutrientType
    }
}

extension AmountUnit {
    func formUnit(withSize size: FormSize? = nil) -> FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .serving:
            return .serving
        case .size:
            /// We should have had a size (pre-created from the actual `MFPProcessedFood.Size`) and passed into this function—otherwise fallback to a serving unit
            guard let size else {
                return .serving
            }
            return .size(size, nil)
        }
    }
}

extension ServingUnit {
    func formUnit(withSize size: FormSize? = nil) -> FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .size:
            /// We should have had a size (pre-created from the actual `MFPProcessedFood.Size`) and passed into this function—otherwise fallback to a default unit
            guard let size else {
                return .weight(.g)
            }
            return .size(size, .cup)
        }
    }
}


//TODO: Write an extension on FieldValue or RecognizedText that provides alternative `FoodLabelValue`s for a specific type of `FieldValue`—so if its energy and we have a number, return it as the value with both units, or the converted value in kJ or kcal. If its simply a macro/micro value—use the stuff where we move the decimal place back or forward or correct misread values such as 'g' for '9', 'O' for '0' and vice versa.

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

extension MFPProcessedFood.Size {
    var size: FormSize {
        FormSize(
            quantity: quantity,
            volumePrefixUnit: prefixVolumeUnit?.formUnit,
            name: name.lowercased(),
            amount: amount,
            unit: amountUnit.formUnit
        )
    }
    
    var fieldValue: FieldValue {
        size.fieldValue
    }
    
    var isVolumePrefixed: Bool {
        prefixVolumeUnit != nil
    }
}

extension FormSize {
    var fieldValue: FieldValue {
        .size(FieldValue.SizeValue(
            size: self,
            fill: .prefill())
        )
    }
}

extension AmountUnit {
    var formUnit: FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .serving:
            return .serving
        case .size(let processedSize):
            return .size(processedSize.size, nil)
        }
    }
    
    var weightUnit: WeightUnit? {
        switch self {
        case .weight(let weightUnit):
            return weightUnit
        default:
            return nil
        }
    }
}
extension VolumeUnit {
    var formUnit: FormUnit {
        .volume(self)
    }
}