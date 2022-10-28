import SwiftUI
import FoodLabel
import PrepDataTypes

extension FoodForm {
    class Fields: ObservableObject {
        
        @Published var energy: Field
        @Published var carb: Field
        @Published var fat: Field
        @Published var protein: Field
        
        @Published var shouldShowFoodLabel: Bool = false
        
        /**
         These are the last extracted `FieldValues` returned from the `FieldsExtractor`,
         which would have analysed and picked the best values from all available `ScanResult`s
         (after the user selects a column if applicable).
         */
        var extractedFieldValues: [FieldValue] = []
        
        init() {
            self.energy = .init(fieldValue: .energy())
            self.carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
            self.fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
            self.protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
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
        guard shouldOverwrite || fieldIsDiscardableOrNotPresent(for: fieldValue) else {
            return
        }
        fillOneToOneField(with: fieldValue)
    }
    
    func fillOneToOneField(with fieldValue: FieldValue) {
        switch fieldValue {
//        case .amount:
//            amountViewModel.fillScannedFieldValue(fieldValue)
//        case .serving:
//            servingViewModel.fillScannedFieldValue(fieldValue)
//        case .density:
//            densityViewModel.fillScannedFieldValue(fieldValue)
        case .energy:
            energy.fill(with: fieldValue)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: carb.fill(with: fieldValue)
            case .fat: fat.fill(with: fieldValue)
            case .protein: protein.fill(with: fieldValue)
            }
//        case .micro(let microValue):
//            micronutrientFieldViewModel(for: microValue.nutrientType)?.fillScannedFieldValue(fieldValue)
        default:
            break
        }
        replaceOrSetExtractedFieldValue(fieldValue)
    }
    
    func replaceOrSetExtractedFieldValue(_ fieldValue: FieldValue) {
        switch fieldValue {
//        case .amount:
//            scannedFieldValues.removeAll(where: { $0.isAmount })
//        case .serving:
//            scannedFieldValues.removeAll(where: { $0.isServing })
//        case .density:
//            scannedFieldValues.removeAll(where: { $0.isDensity })
        case .energy:
            extractedFieldValues.removeAll(where: { $0.isEnergy })
//        case .macro(let macroValue):
//            scannedFieldValues.removeAll(where: { $0.isMacro(macroValue.macro)})
//        case .micro(let microValue):
//            scannedFieldValues.removeAll(where: { $0.isMicro(microValue.nutrientType)})
//        case .size(let sizeValue):
//            /// Make sure we never have two sizes with the same name and volume-prefix in the `scannedFieldValues` array at any given time
//            scannedFieldValues.removeAll(where: {
//                guard let size = $0.size else { return false }
//                return size.conflictsWith(sizeValue.size)
//            })
//        case .barcode(let barcodeValue):
//            /// Make sure we never have two barcodes with the same payload string in `scannedFieldValues`
//            scannedFieldValues.removeAll(where: {
//                guard let otherBarcodeValue = $0.barcodeValue else { return false }
//                return barcodeValue.payloadString == otherBarcodeValue.payloadString
//            })
        default:
            break
        }
        extractedFieldValues.append(fieldValue)
    }
    
    func fieldIsDiscardableOrNotPresent(for fieldValue: FieldValue) -> Bool {
        guard let existingField = existingField(for: fieldValue) else {
            /// not present
            return true
        }
        return existingField.isDiscardable
    }
    
    func existingField(for fieldValue: FieldValue) -> Field? {
        switch fieldValue {
//        case .amount(let doubleValue):
//        case .serving(let doubleValue):
//        case .density(let densityValue):
        case .energy:
            return energy
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: return carb
            case .protein: return protein
            case .fat: return fat
            }
//        case .micro(let microValue):
//        case .size(let sizeValue):
//        case .barcode(let barcodeValue):
        default:
            return nil
        }
    }
}

extension Field {
    var isDiscardable: Bool {
        switch fill {
        case .scanned, .prefill, .discardable:
            return true
        case .userInput:
            return value.isEmpty
        case .selection:
            return false
        case .barcodeScanned:
            return true
        }
    }
}

extension FieldValue {
    /**
     Returns `true` if there can only be one of this field for any given food.
     
     This returns `true` for `.macro` and `.macro` as it considers them along with their `Macro` or `NutrientType` identifiers.
     */
    var isOneToOne: Bool {
        switch self {
        case .name, .emoji, .brand, .detail, .amount, .serving, .density, .energy, .macro, .micro:
            return true
        case .size, .barcode:
            return false
        }
    }
    
    var isOneToMany: Bool {
        !isOneToOne
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
}
