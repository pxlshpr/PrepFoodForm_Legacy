import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepUnits

extension FoodFormViewModel {
    func processScanResults(column pickedColumn: Int? = nil) {
        guard let relevantScanResults = scanResults.relevantScanResults else { return }
        let isUserInitiated = pickedColumn != nil
        let column = pickedColumn ?? relevantScanResults.columnWithTheMostNutrients
        
        let fieldViewModelsToExtract = [
            energyViewModel, carbViewModel, fatViewModel, proteinViewModel,
            amountViewModel, servingViewModel, densityViewModel,
            barcodeViewModel
        ] + allMicronutrientFieldViewModels
        
        for fieldViewModel in fieldViewModelsToExtract {
            extractField(for: fieldViewModel,
                         at: column,
                         from: relevantScanResults,
                         isUserInitiated: isUserInitiated
            )
        }
        
        /// For each of the size view models in ALL the scan results
        for sizeViewModel in relevantScanResults.allSizeViewModels {
            /// If we were able to add this size view model (if it wasn't a duplicate) ...
            guard add(sizeViewModel: sizeViewModel) else {
                continue
            }
            sizeViewModel.resetAndCropImage()
            /// ... then go ahead and add it to the `scannedFieldValues` array as well
            replaceOrSetScannedFieldValue(sizeViewModel.fieldValue)
        }

        //TODO: Extract Barcodes
        
        updateShouldShowDensitiesSection()

        /// Set this for the `FoodLabel`
//        energyValue = energyViewModel.fieldValue.value ?? .zero

//        extractMacro(.carb, from: scanResult, at: column)
//        extractMacro(.protein, from: scanResult, at: column)
//        extractMacro(.fat, from: scanResult, at: column)
//        for nutrient in NutrientType.allCases {
//            extractNutrient(nutrient, from: scanResult, at: column)
//        }
//
//        extractSizes(from: scanResult)
//
//        extractServing(from: scanResult, for: column)
//        extractAmount(from: scanResult, for: column)
//        extractDensity(from: scanResult)
//
//        extractBarcode(from: scanResult)
//
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            //TODO: Only do this to if we actually extract the values
//            for fieldViewModel in self.allFieldViewModels {
//                fieldViewModel.isCroppingNextImage = true
//                fieldViewModel.cropFilledImage()
//            }
//        }

    }
    func extractField(
        for existingFieldViewModel: FieldViewModel,
        at column: Int,
        from relevantScanResults: [ScanResult],
        isUserInitiated: Bool
    ) {
        guard let fieldValue = relevantScanResults.pickFieldValue(
            for: existingFieldViewModel.fieldValue,
            at: column)
        else {
            return
        }
        guard isUserInitiated || existingFieldIsDiscardable(for: existingFieldViewModel) else {
            return
        }
        fillScannedFieldValue(fieldValue)
    }
    
    func existingFieldIsDiscardable(for fieldViewModel: FieldViewModel) -> Bool {
        switch fieldViewModel.fill {
        case .scanned, .prefill, .discardedScan:
            return true
        case .userInput:
            return fieldViewModel.fieldValue.isEmpty
        case .selection:
            return false
        }
    }
    
    func fillScannedFieldValue(_ fieldValue: FieldValue) {
        switch fieldValue {
        case .amount:
            amountViewModel.fillScannedFieldValue(fieldValue)
        case .serving:
            servingViewModel.fillScannedFieldValue(fieldValue)
        case .density:
            densityViewModel.fillScannedFieldValue(fieldValue)
        case .barcode:
            barcodeViewModel.fillScannedFieldValue(fieldValue)
        case .energy:
            energyViewModel.fillScannedFieldValue(fieldValue)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: carbViewModel.fillScannedFieldValue(fieldValue)
            case .fat: fatViewModel.fillScannedFieldValue(fieldValue)
            case .protein: proteinViewModel.fillScannedFieldValue(fieldValue)
            }
        case .micro(let microValue):
            micronutrientFieldViewModel(for: microValue.nutrientType)?.fillScannedFieldValue(fieldValue)
        default:
            break
        }
        replaceOrSetScannedFieldValue(fieldValue)
    }
    
    func replaceOrSetScannedFieldValue(_ fieldValue: FieldValue) {
        switch fieldValue {
        case .amount:
            scannedFieldValues.removeAll(where: { $0.isAmount })
        case .serving:
            scannedFieldValues.removeAll(where: { $0.isServing })
        case .density:
            scannedFieldValues.removeAll(where: { $0.isDensity })
        case .barcode:
            scannedFieldValues.removeAll(where: { $0.isBarcode })
        case .energy:
            scannedFieldValues.removeAll(where: { $0.isEnergy })
        case .macro(let macroValue):
            scannedFieldValues.removeAll(where: { $0.isMacro(macroValue.macro)})
        case .micro(let microValue):
            scannedFieldValues.removeAll(where: { $0.isMicro(microValue.nutrientType)})
        case .size(let sizeValue):
            scannedFieldValues.removeAll(where: {
                guard let size = $0.size else { return false }
                return size.conflictsWith(sizeValue.size)
            })
        default:
            break
        }
        scannedFieldValues.append(fieldValue)
    }
}

extension Size {
    func conflictsWith(_ otherSize: Size) -> Bool {
        self.name.lowercased() == otherSize.name.lowercased()
        && self.volumePrefixUnit == otherSize.volumePrefixUnit
    }
}