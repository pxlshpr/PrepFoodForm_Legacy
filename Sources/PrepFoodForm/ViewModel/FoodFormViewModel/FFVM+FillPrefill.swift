import MFPScraper
import SwiftUI
import PrepUnits

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
    
    func simulateImageClassification() {
        sourceType = .images
        populateWithSampleImages()
        processAllClassifierOutputs()
        imageSetStatus = .classified
        withAnimation {
            showingWizard = false
        }
    }
    
    func prefill(_ food: MFPProcessedFood) {

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
            name = FieldValue.name(FieldValue.StringValue(string: food.name, fillType: .thirdPartyFoodPrefill))
        }
        if let detail = food.detail, !detail.isEmpty {
            self.detail = FieldValue.detail(FieldValue.StringValue(string: detail, fillType: .thirdPartyFoodPrefill))
        }
        if let brand = food.brand, !brand.isEmpty {
            self.brand = FieldValue.brand(FieldValue.StringValue(string: brand, fillType: .thirdPartyFoodPrefill))
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
        
        self.amount = FieldValue.amount(FieldValue.DoubleValue(
            double: food.amount,
            string: food.amount.cleanAmount,
            unit: food.amountUnit.formUnit(withSize: size),
            fillType: .thirdPartyFoodPrefill)
        )
    }
    
    func prefillDensity(from food: MFPProcessedFood) {
    }
    
    func prefillServing(from food: MFPProcessedFood) {
    }
    
    func prefillNutrients(from food: MFPProcessedFood) {
        self.energy = food.energyFieldValue
        self.carb = food.carbFieldValue
        self.fat = food.fatFieldValue
        self.protein = food.proteinFieldValue
    }
}

extension MFPProcessedFood {
    var energyFieldValue: FieldValue {
        .energy(FieldValue.EnergyValue(double: energy, string: energy.cleanAmount, unit: .kcal, fillType: .thirdPartyFoodPrefill))
    }
    
    func macroFieldValue(macro: Macro, double: Double) -> FieldValue {
        .macro(FieldValue.MacroValue(macro: macro, double: double, string: double.cleanAmount, fillType: .thirdPartyFoodPrefill))
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
