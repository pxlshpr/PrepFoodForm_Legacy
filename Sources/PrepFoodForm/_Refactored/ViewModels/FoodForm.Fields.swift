import SwiftUI
import FoodLabel
import PrepDataTypes
import MFPScraper
import VisionSugar

let DefaultAmount = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .discardable))

extension FoodForm {
    
    class Fields: ObservableObject {
        
        static var shared = Fields()
        
        @Published var amount: Field
        @Published var serving: Field
        @Published var energy: Field
        @Published var carb: Field
        @Published var fat: Field
        @Published var protein: Field
        
        @Published var standardSizes: [Field] = []
        @Published var volumePrefixedSizes: [Field] = []
        @Published var density: Field

        @Published var micronutrients: [MicroGroupTuple] = DefaultMicronutrients()
        @Published var microsFats: [Field] = []
        @Published var microsFibers: [Field] = []
        
        @Published var barcodes: [Field] = []

        @Published var shouldShowFoodLabel: Bool = false
        
        /**
         These are the last extracted `FieldValues` returned from the `FieldsExtractor`,
         which would have analysed and picked the best values from all available `ScanResult`s
         (after the user selects a column if applicable).
         */
        var extractedFieldValues: [FieldValue] = []
        var prefilledFood: MFPProcessedFood? = nil

        var sizeBeingEdited: FormSize? = nil

        init() {
            self.amount = .init(fieldValue: DefaultAmount)
            self.serving = .init(fieldValue: .serving())
            self.energy = .init(fieldValue: .energy())
            self.carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
            self.fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
            self.protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
            self.density = .init(fieldValue: .density(FieldValue.DensityValue()))
        }
    }
}

extension FoodForm.Fields {
    
    func updateShouldShowFoodLabel() {
        shouldShowFoodLabel = (
            !energy.value.isEmpty
            && !carb.value.isEmpty
            && !fat.value.isEmpty
            && !protein.value.isEmpty
        )
    }
    
    //MARK: - Convenience
    
    func oneToOneFieldIsDiscardableOrNotPresent(for fieldValue: FieldValue) -> Bool {
        guard let existingField = existingOneToOneField(for: fieldValue) else {
            /// not present
            return true
        }
        return existingField.isDiscardable
    }
    
    func existingOneToOneField(for fieldValue: FieldValue) -> Field? {
        switch fieldValue {
        case .amount:
            return amount
        case .serving:
            return serving
        case .density:
            return density
        case .energy:
            return energy
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: return carb
            case .protein: return protein
            case .fat: return fat
            }
        case .micro(let microValue):
            return micronutrientField(for: microValue.nutrientType)
        default:
            return nil
        }
    }
    
    var isWeightBased: Bool {
        amount.value.doubleValue.unit.isWeightBased
        || serving.value.doubleValue.unit.isWeightBased
    }
    
    //MARK: Fills
    
    var hasNonUserInputFills: Bool {
        for field in allFieldValues {
            if field.fill != .userInput {
                return true
            }
        }
        
        for model in allSizeFields {
            if model.value.fill != .userInput {
                return true
            }
        }
        return false
    }

    var containsFieldWithFillImage: Bool {
        allFieldValues.contains(where: { $0.fill.usesImage })
    }
    
    //MARK: Fields
    
    var allSingleFields: [Field] {
        [amount, serving, density, energy, carb, fat, protein]
    }

    var allMicronutrientFieldValues: [FieldValue] {
        allMicronutrientFields.map { $0.value }
    }

    var allMicronutrientFields: [Field] {
        micronutrients.reduce([Field]()) { partialResult, tuple in
            partialResult + tuple.fields
        }
    }

    var allIncludedMicronutrientFields: [Field] {
        micronutrients.reduce([Field]()) { partialResult, tuple in
            partialResult + tuple.fields
        }
        .filter { $0.value.microValue.isIncluded }
    }

    var allFieldValues: [FieldValue] {
        allFields.map { $0.value }
    }

    var allFields: [Field] {
        allSingleFields
        + allMicronutrientFields
        + standardSizes
        + volumePrefixedSizes
        + barcodes
    }
    
    var allSizeFields: [Field] {
        standardSizes + volumePrefixedSizes
    }
    
    //MARK: - Extracted Fields Convenience
    
    func firstExtractedText(for fieldValue: FieldValue) -> RecognizedText? {
        guard let fill = extractedFieldValues(for: fieldValue).first?.fill else {
            return nil
        }
        return fill.text
    }
    
    func firstExtractedFill(for fieldValue: FieldValue, with densityValue: FieldValue.DensityValue) -> Fill? {
        guard let fill = extractedFieldValues(for: fieldValue).first?.fill,
              let fillDensityValue = fill.densityValue,
              fillDensityValue.equalsValues(of: densityValue) else {
            return nil
        }
        return fill
    }

    func firstExtractedFill(for fieldValue: FieldValue, with text: RecognizedText) -> Fill? {
        guard let fill = extractedFieldValues(for: fieldValue).first?.fill,
              fill.text == text else {
            return nil
        }
        return fill
    }
}
