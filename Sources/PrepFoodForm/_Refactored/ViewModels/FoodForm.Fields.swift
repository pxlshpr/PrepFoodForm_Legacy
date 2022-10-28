import SwiftUI
import FoodLabel
import PrepDataTypes
import MFPScraper
import VisionSugar

let DefaultAmount = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .discardable))

extension FoodForm {
    
    class Fields: ObservableObject {
        
        static let shared = Fields()
        
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
    func handleExtractedFieldsValues(_ fieldValues: [FieldValue], shouldOverwrite: Bool) {
        
        for fieldValue in fieldValues.filter({ $0.isOneToOne }) {
            handleOneToOneExtractedNutrientFieldValue(fieldValue, shouldOverwrite: shouldOverwrite)
        }
        
        updateShouldShowFoodLabel()
        
        print("Got \(fieldValues.count) fieldValues to fill in")
        print("We here")
    }
    
    func handleOneToOneExtractedNutrientFieldValue(_ fieldValue: FieldValue, shouldOverwrite: Bool) {
        guard shouldOverwrite || oneToOneFieldIsDiscardableOrNotPresent(for: fieldValue) else {
            return
        }
        fillOneToOneField(with: fieldValue)
    }
    
    func fillOneToOneField(with fieldValue: FieldValue) {
        switch fieldValue {
        case .amount:
            amount.fill(with: fieldValue)
        case .serving:
            serving.fill(with: fieldValue)
        case .density:
            density.fill(with: fieldValue)
        case .energy:
            energy.fill(with: fieldValue)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: carb.fill(with: fieldValue)
            case .fat: fat.fill(with: fieldValue)
            case .protein: protein.fill(with: fieldValue)
            }
        case .micro(let microValue):
            micronutrientField(for: microValue.nutrientType)?.fill(with: fieldValue)
        default:
            break
        }
        replaceOrSetExtractedFieldValue(fieldValue)
    }
    
    func replaceOrSetExtractedFieldValue(_ fieldValue: FieldValue) {
        /// First remove any existing `FieldValue` for this type (or a duplicate in the 1-many cases)
        switch fieldValue {
        case .amount:
            extractedFieldValues.removeAll(where: { $0.isAmount })
        case .serving:
            extractedFieldValues.removeAll(where: { $0.isServing })
        case .density:
            extractedFieldValues.removeAll(where: { $0.isDensity })
        case .energy:
            extractedFieldValues.removeAll(where: { $0.isEnergy })
        case .macro(let macroValue):
            extractedFieldValues.removeAll(where: { $0.isMacro(macroValue.macro)})
        case .micro(let microValue):
            extractedFieldValues.removeAll(where: { $0.isMicro(microValue.nutrientType)})
        case .size(let sizeValue):
            /// Make sure we never have two sizes with the same name and volume-prefix in the `scannedFieldValues` array at any given time
            extractedFieldValues.removeAll(where: {
                guard let size = $0.size else { return false }
                return size.conflictsWith(sizeValue.size)
            })
        case .barcode(let barcodeValue):
            /// Make sure we never have two barcodes with the same payload string **and** symbology in `scannedFieldValues`
            extractedFieldValues.removeAll(where: {
                guard let otherBarcodeValue = $0.barcodeValue else { return false }
                return barcodeValue.payloadString == otherBarcodeValue.payloadString
                && barcodeValue.symbology == otherBarcodeValue.symbology
            })
        default:
            break
        }
        
        /// Then add the provided `FieldValue`
        extractedFieldValues.append(fieldValue)
    }
    
    func updateShouldShowFoodLabel() {
        shouldShowFoodLabel = (
            !energy.value.isEmpty
            && !carb.value.isEmpty
            && !fat.value.isEmpty
            && !protein.value.isEmpty
        )
    }
    
    //MARK: - Convenience
    
    func micronutrientField(for nutrientType: NutrientType) -> Field? {
        for group in micronutrients {
            for fieldViewModel in group.fieldViewModels {
                if case .micro(let microValue) = fieldViewModel.value, microValue.nutrientType == nutrientType {
                    return fieldViewModel
                }
            }
        }
        return nil
    }

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
            partialResult + tuple.fieldViewModels
        }
    }

    var allIncludedMicronutrientFields: [Field] {
        micronutrients.reduce([Field]()) { partialResult, tuple in
            partialResult + tuple.fieldViewModels
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
