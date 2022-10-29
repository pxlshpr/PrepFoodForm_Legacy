import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepDataTypes

extension FoodFormViewModel {
    
    func processScanResults() {
        candidateScanResults = scanResults.candidateScanResults
        if let bestScanResult = candidateScanResults.bestScanResult,
            bestScanResult.columnCount == 2
        {
            textPickerColumn1 = TextColumn(
                column: 1,
                name: bestScanResult.headerTitle1,
                imageTexts: bestColumnImageTexts(at: 1, from: candidateScanResults)
            )

            textPickerColumn2 = TextColumn(
                column: 2,
                name: bestScanResult.headerTitle2,
                imageTexts: bestColumnImageTexts(at: 2, from: candidateScanResults)
            )
            
            pickedColumn = bestScanResult.bestColumn
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showingColumnPicker = true
            }
        } else {
            processScanResults(column: 1, from: candidateScanResults)
        }
    }

    var columnPickerImageViewModels: [ImageViewModel] {
        guard let textPickerColumn1, let textPickerColumn2 else {
            return []
        }
        return imageViewModels.filter {
            textPickerColumn1.containsTexts(from: $0)
            || textPickerColumn2.containsTexts(from: $0)
        }
    }
    
    var textPickerFieldViewModels: [Field] {
        [
            energyViewModel, carbViewModel, fatViewModel, proteinViewModel
        ] + allMicronutrientFieldViewModels
    }
    
    /// Get's the `ImageText`s for the `TextPickerColumn` at `column` of the best values picked from the provided array of `ScanResult`s.
    func bestColumnImageTexts(at column: Int, from candidateScanResults: [ScanResult]) -> [ImageText] {
        
        let fieldValues = textPickerFieldViewModels.compactMap {
            candidateScanResults.bestFieldValue(for: $0.value, at: column)
        }
        return fieldValues.compactMap { $0.fill.imageText }
    }

    /// Get's the `ImageText`s for the `TextPickerColumn` at `column` of the provided `ScanResult`.
    func columnImageTexts(at column: Int, from scanResult: ScanResult) -> [ImageText] {
        let fieldValues = textPickerFieldViewModels.compactMap {
            scanResult.fieldValue(for: $0.value, at: column)
        }
        return fieldValues.compactMap { $0.fill.imageText }
    }

    func processScanResults(
        column pickedColumn: Int,
        from candidateScanResults: [ScanResult],
        isUserInitiated: Bool = false
    ) {
        let column = pickedColumn
        
        let fieldViewModelsToExtract = [
            energyViewModel, carbViewModel, fatViewModel, proteinViewModel,
            amountViewModel, servingViewModel, densityViewModel
        ] + allMicronutrientFieldViewModels
        
        for fieldViewModel in fieldViewModelsToExtract {
            extractField(for: fieldViewModel,
                         at: column,
                         from: candidateScanResults,
                         isUserInitiated: isUserInitiated
            )
        }
        
        /// For each of the size view models in ALL the scan results
        for sizeViewModel in candidateScanResults.allSizeViewModels(at: column) {
            /// If we were able to add this size view model (if it wasn't a duplicate) ...
            guard add(sizeViewModel: sizeViewModel) else {
                continue
            }
            sizeViewModel.resetAndCropImage()
            /// ... then go ahead and add it to the `scannedFieldValues` array as well
            replaceOrSetScannedFieldValue(sizeViewModel.value)
        }
        
        /// Get Barcodes from all images
        for barcodeViewModel in scanResults.allBarcodeFields {
            guard add(barcodeViewModel: barcodeViewModel) else {
                continue
            }
            barcodeViewModel.resetAndCropImage()
            replaceOrSetScannedFieldValue(barcodeViewModel.value)
        }
        
        updateShouldShowDensitiesSection()
        
        markAllImageViewModelsAsProcessed()
        foodLabelRefreshBool.toggle()
    }
    
    /**
     This is used to know which `ImageViewModel`s should be discarded when the user dismisses the column picker—by setting a flag in the `ImageViewModel` that marks it as completed.
     
     As this only gets called when the actual processing is complete, those without the flag set will be discarded.
     */
    func markAllImageViewModelsAsProcessed() {
        for i in imageViewModels.indices {
            imageViewModels[i].isProcessed = true
        }
    }
    
    func extractField(
        for existingFieldViewModel: Field,
        at column: Int,
        from candidateScanResults: [ScanResult],
        isUserInitiated: Bool
    ) {
        guard let fieldValue = candidateScanResults.bestFieldValue(
            for: existingFieldViewModel.value,
            at: column)
        else {
            return
        }
        guard isUserInitiated || existingFieldIsDiscardable(for: existingFieldViewModel) else {
            return
        }
        fillScannedFieldValue(fieldValue)
    }
    
    func existingFieldIsDiscardable(for fieldViewModel: Field) -> Bool {
        switch fieldViewModel.fill {
        case .scanned, .prefill, .discardable:
            return true
        case .userInput:
            return fieldViewModel.value.isEmpty
        case .selection:
            return false
        case .barcodeScanned:
            return true
        }
    }
    
    func fillScannedFieldValue(_ fieldValue: FieldValue) {
        switch fieldValue {
        case .amount:
            amountViewModel.fill(with: fieldValue)
        case .serving:
            servingViewModel.fill(with: fieldValue)
        case .density:
            densityViewModel.fill(with: fieldValue)
        case .energy:
            energyViewModel.fill(with: fieldValue)
        case .macro(let macroValue):
            switch macroValue.macro {
            case .carb: carbViewModel.fill(with: fieldValue)
            case .fat: fatViewModel.fill(with: fieldValue)
            case .protein: proteinViewModel.fill(with: fieldValue)
            }
        case .micro(let microValue):
            micronutrientFieldViewModel(for: microValue.nutrientType)?.fill(with: fieldValue)
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
        case .energy:
            scannedFieldValues.removeAll(where: { $0.isEnergy })
        case .macro(let macroValue):
            scannedFieldValues.removeAll(where: { $0.isMacro(macroValue.macro)})
        case .micro(let microValue):
            scannedFieldValues.removeAll(where: { $0.isMicro(microValue.nutrientType)})
        case .size(let sizeValue):
            /// Make sure we never have two sizes with the same name and volume-prefix in the `scannedFieldValues` array at any given time
            scannedFieldValues.removeAll(where: {
                guard let size = $0.size else { return false }
                return size.conflictsWith(sizeValue.size)
            })
        case .barcode(let barcodeValue):
            /// Make sure we never have two barcodes with the same payload string in `scannedFieldValues`
            scannedFieldValues.removeAll(where: {
                guard let otherBarcodeValue = $0.barcodeValue else { return false }
                return barcodeValue.payloadString == otherBarcodeValue.payloadString
            })
        default:
            break
        }
        scannedFieldValues.append(fieldValue)
    }
}
