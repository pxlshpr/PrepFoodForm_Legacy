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
        prefillDensity(from: food)
        prefillNutrients(from: food)
        
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
        
    }

    func prefillAmountPer(from food: MFPProcessedFood) {
        prefillAmount(from: food)
        prefillServing(from: food)
    }
    
    func prefillAmount(from food: MFPProcessedFood) {
        guard food.amount > 0 else {
            return
        }
        
        let size: Size?
        if case .size(let mfpSize) = food.amountUnit {
            size = nil
        } else {
            size = nil
        }
        
        let fieldValue = FieldValue.amount(FieldValue.DoubleValue(
            double: food.amount,
            string: food.amount.cleanAmount,
            unit: food.amountUnit.formUnit(withSize: size),
            fillType: .prefill())
        )
        self.amountViewModel = .init(fieldValue: fieldValue)
    }
    
    func prefillDensity(from food: MFPProcessedFood) {
    }
    
    func prefillServing(from food: MFPProcessedFood) {
    }
    
    func prefillNutrients(from food: MFPProcessedFood) {
        self.energyViewModel = .init(fieldValue: food.energyFieldValue)
        self.carbViewModel = .init(fieldValue: food.carbFieldValue)
        self.fatViewModel = .init(fieldValue: food.fatFieldValue)
        self.proteinViewModel = .init(fieldValue: food.proteinFieldValue)
    }
}

extension MFPProcessedFood {
    var energyFieldValue: FieldValue {
        .energy(FieldValue.EnergyValue(double: energy, string: energy.cleanAmount, unit: .kcal, fillType: .prefill()))
    }
    
    func macroFieldValue(macro: Macro, double: Double) -> FieldValue {
        .macro(FieldValue.MacroValue(macro: macro, double: double, string: double.cleanAmount, fillType: .prefill()))
    }
    
    var carbFieldValue: FieldValue {
        macroFieldValue(macro: .carb, double: carbohydrate)
    }
    var fatFieldValue: FieldValue {
        macroFieldValue(macro: .fat, double: fat)
    }

    var proteinFieldValue: FieldValue {
        macroFieldValue(macro: .protein, double: protein)
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

extension FieldValue {
    static func prefillOptionForName(with string: String) -> FieldValue {
        FieldValue.name(StringValue(string: string, fillType: .prefill(prefillFields: [.name])))
    }
}

//TODO: Write an extension on FieldValue or RecognizedText that provides alternative `FoodLabelValue`s for a specific type of `FieldValue`—so if its energy and we have a number, return it as the value with both units, or the converted value in kJ or kcal. If its simply a macro/micro value—use the stuff where we move the decimal place back or forward or correct misread values such as 'g' for '9', 'O' for '0' and vice versa.

//MARK: FFVM + FillOptions Helpers
extension FoodFormViewModel {
    
    func autofillOptionFieldValue(for fieldValue: FieldValue) -> FieldValue? {
        
        switch fieldValue {
        case .energy:
            return autofillFieldValues.first(where: { $0.isEnergy })
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
        default:
            return nil
        }
    }
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
//            return FieldValue.name(FieldValue.StringValue(string: food.name, fillType: .prefill))
//        case .brand(let stringValue):
//            return FieldValue.brand(FieldValue.StringValue(string: detail, fillType: .prefill))
//            return food.detail
//        case .barcode(let stringValue):
//            return nil
//        case .detail(let stringValue):
//
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
//        case .energy(let energyValue):
//            <#code#>
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
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
            let filtered = texts.filter { isNotUsingText($0) }
            availableTexts.append(contentsOf: filtered)
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
