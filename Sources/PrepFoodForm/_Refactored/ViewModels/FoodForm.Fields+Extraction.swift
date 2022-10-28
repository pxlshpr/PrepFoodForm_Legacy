import Foundation

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
    
}
