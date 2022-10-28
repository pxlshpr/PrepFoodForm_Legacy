import SwiftUI
import FoodLabel
import PrepDataTypes

extension FoodForm {
    class Fields: ObservableObject {
        
        static let shared = Fields()
        
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
    
    func updateShouldShowFoodLabel() {
        shouldShowFoodLabel = (
            !energy.value.isEmpty
            && !carb.value.isEmpty
            && !fat.value.isEmpty
            && !protein.value.isEmpty
        )
    }
}

extension FoodForm.Fields {
    
    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []

        fillOptions.append(contentsOf: scannedFillOptions(for: fieldValue))
//        fillOptions.append(contentsOf: selectionFillOptions(for: fieldValue))
//        fillOptions.append(contentsOf: prefillOptions(for: fieldValue))
//
////        fillOptions.removeFillOptionValueDuplicates()
//
//        if let selectFillOption = selectFillOption(for: fieldValue) {
//            fillOptions .append(selectFillOption)
//        }
//
        return fillOptions
    }
    

    func scannedFillOptions(for fieldValue: FieldValue) -> [FillOption] {
        let extractedFieldValues = extractedFieldValues(for: fieldValue)
        var fillOptions: [FillOption] = []
        
        for scannedFieldValue in extractedFieldValues {
            guard case .scanned(let info) = scannedFieldValue.fill else {
                continue
            }
            
            fillOptions.append(
                FillOption(
                    string: fillButtonString(for: scannedFieldValue),
                    systemImage: Fill.SystemImage.scanned,
                    isSelected: fieldValue.equalsScannedFieldValue(scannedFieldValue),
                    type: .fill(scannedFieldValue.fill)
                )
            )
            
            /// Show alts if selected (only check the text because it might have a different value attached to it)
            for altValue in scannedFieldValue.altValues {
                fillOptions.append(
                    FillOption(
                        string: altValue.fillOptionString,
                        systemImage: Fill.SystemImage.scanned,
                        isSelected: fieldValue.value == altValue && fieldValue.fill.isImageAutofill,
                        type: .fill(.scanned(info.withAltValue(altValue)))
                    )
                )
            }
        }
                
        return fillOptions
    }
    
    func extractedFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        switch fieldValue {
        case .energy:
            return extractedFieldValues.filter({ $0.isEnergy })
        case .macro(let macroValue):
            return extractedFieldValues.filter({ $0.isMacro && $0.macroValue.macro == macroValue.macro })
        case .micro(let microValue):
            return extractedFieldValues.filter({ $0.isMicro && $0.microValue.nutrientType == microValue.nutrientType })
        case .amount:
            return extractedFieldValues.filter({ $0.isAmount })
        case .serving:
            return extractedFieldValues.filter({ $0.isServing })
        case .density:
            return extractedFieldValues.filter({ $0.isDensity })
//        case .size:
//            return extractedSizeFieldValues(for: fieldValue)
        default:
            return []
        }
    }
    
    func fillButtonString(for fieldValue: FieldValue) -> String {
        switch fieldValue {
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.description
        case .energy(let energyValue):
            return energyValue.description
        case .macro(let macroValue):
            return macroValue.description
        case .micro(let microValue):
            return microValue.description
        case .density(let densityValue):
            return densityValue.description(weightFirst: isWeightBased)
        case .size(let sizeValue):
            return sizeValue.size.fullNameString
        default:
            return "(not implemented)"
        }
    }
    
    var isWeightBased: Bool {
        true
        //TODO: Do this once amountViewModel is brought in
//        amountViewModel.value.doubleValue.unit.isWeightBased || servingViewModel.value.doubleValue.unit.isWeightBased
    }
}
