import MFPScraper
import SwiftUI
import PrepUnits
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
        let image = PrepFoodForm.sampleImage(number)!
        let imageViewModel = ImageViewModel(image)
        imageViewModels.append(imageViewModel)
    }
    
    func simulateImageSelection() {
        
        sourceType = .images
        imageSetStatus = .classifying
        
        simulateAddingImage(9)
//        simulateAddingImage(7)
//        simulateAddingImage(1)
//        simulateAddingImage(2)
//        simulateAddingImage(3)
//        simulateAddingImage(4)

        withAnimation {
            showingWizard = false
        }
    }
    
    func simulateImageClassification(_ indexes: [Int]) {
        sourceType = .images
        populateWithSampleImages(indexes)
        processScanResults()
        imageSetStatus = .classified
        withAnimation {
            showingWizard = false
        }
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
        
        prefillAmountPer(from: food)
        prefillNutrients(from: food)

        updateShouldShowDensitiesSection()

        prefilledFood = food
        
        withAnimation {
            showingWizard = false
        }
    }
    
    func prefillDetails(from food: MFPProcessedFood) {
        if !food.name.isEmpty {
            let fieldValue = FieldValue.name(FieldValue.StringValue(string: food.name, fillType: .prefill(prefillFields: [.name])))
            nameViewModel = .init(fieldValue: fieldValue)
        }
        if let detail = food.detail, !detail.isEmpty {
            let fieldValue = FieldValue.detail(FieldValue.StringValue(string: detail, fillType: .prefill(prefillFields: [.detail])))
            detailViewModel = .init(fieldValue: fieldValue)
        }
        if let brand = food.brand, !brand.isEmpty {
            let fieldValue = FieldValue.brand(FieldValue.StringValue(string: brand, fillType: .prefill(prefillFields: [.brand])))
            brandViewModel = .init(fieldValue: fieldValue)
        }
    }

    func prefillSizes(from food: MFPProcessedFood) {
        for size in food.sizes {
            guard !size.isDensity else {
                prefillDensitySize(size)
                continue
            }
            
            prefillSize(size)
        }
    }
    
    func prefillSize(_ processedSize: MFPProcessedFood.Size) {
        let fieldViewModel: FieldViewModel = .init(fieldValue: processedSize.fieldValue)
        if processedSize.isVolumePrefixed {
            volumePrefixedSizeViewModels.append(fieldViewModel)
        } else {
            standardSizeViewModels.append(fieldViewModel)
        }
    }

    func prefillSize(_ size: Size) {
        let fieldViewModel: FieldViewModel = .init(fieldValue: size.fieldValue)
        if size.isVolumePrefixed {
            volumePrefixedSizeViewModels.append(fieldViewModel)
        } else {
            standardSizeViewModels.append(fieldViewModel)
        }
    }

    func prefillDensitySize(_ size: MFPProcessedFood.Size) {
        guard let volumeUnit = size.prefixVolumeUnit else { return }
        let densityFieldValue = FieldValue.density(FieldValue.DensityValue(
            weight: .init(double: size.amount, string: size.amount.cleanAmount, unit: size.amountUnit.formUnit, fillType: .prefill()),
            volume: .init(double: size.quantity, string: size.quantity.cleanAmount, unit: volumeUnit.formUnit, fillType: .prefill()),
            fillType: .prefill())
        )
        densityViewModel = FieldViewModel(fieldValue: densityFieldValue)
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
        
        self.amountViewModel = .init(fieldValue: fieldValue)
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
    func formUnit(withSize size: Size? = nil) -> FormUnit {
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
    func formUnit(withSize size: Size? = nil) -> FormUnit {
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
            return .size(size, nil)
        }
    }
}

extension FieldValue {
    static func prefillOptionForName(with string: String) -> FieldValue {
        FieldValue.name(StringValue(string: string, fillType: .prefill(prefillFields: [.name])))
    }
}

//TODO: Write an extension on FieldValue or RecognizedText that provides alternative `FoodLabelValue`s for a specific type of `FieldValue`—so if its energy and we have a number, return it as the value with both units, or the converted value in kJ or kcal. If its simply a macro/micro value—use the stuff where we move the decimal place back or forward or correct misread values such as 'g' for '9', 'O' for '0' and vice versa.

//MARK: FFVM + Prefill Helpers
extension FoodFormViewModel {
    
    func hasPrefillOptions(for fieldValue: FieldValue) -> Bool {
        !prefillOptionFieldValues(for: fieldValue).isEmpty
    }
    
    func prefillOptionFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        guard let food = prefilledFood else {
            return []
        }
        
        switch fieldValue {
        case .name:
            return food.detailStrings.map { FieldValue.prefillOptionForName(with: $0) }
        case .macro(let macroValue):
            return [food.macroFieldValue(for: macroValue.macro)]
        case .micro(let microValue):
            return [food.microFieldValue(for: microValue.nutrientType)].compactMap { $0 }
        case .energy:
            return [food.energyFieldValue]
        case .serving:
            return [food.servingFieldValue].compactMap { $0 }
        case .amount:
            return [food.amountFieldValue].compactMap { $0 }
//        case .brand(let stringValue):
//            return FieldValue.brand(FieldValue.StringValue(string: detail, fillType: .prefill))
//            return food.detail
//        case .barcode(let stringValue):
//            return nil
//        case .detail(let stringValue):
//
//        case .density(let densityValue):
//            <#code#>
        default:
            return []
        }
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
            let texts = fieldValue.usesValueBasedTexts ? imageViewModel.textsWithValues : imageViewModel.texts
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
            $0.fillType.uses(text: text)
        })
    }
}

extension MFPProcessedFood.Size {
    var size: Size {
        Size(
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

extension Size {
    var fieldValue: FieldValue {
        .size(FieldValue.SizeValue(
            size: self,
            fillType: .prefill())
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
