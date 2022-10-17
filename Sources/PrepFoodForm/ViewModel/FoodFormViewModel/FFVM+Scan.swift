import SwiftUI
import FoodLabelScanner
import SwiftHaptics
import PrepUnits

extension ScanResult {
    var headerTitle1: String {
        guard let headerType = headers?.header1Type else {
            return "Column 1"
        }
        return headerType.description
    }
    var headerTitle2: String {
        guard let headerType = headers?.header2Type else {
            return "Column 2"
        }
        return headerType.description
    }
}
extension FoodFormViewModel {
    
    func processScanResults() {
        relevantScanResults = scanResults.relevantScanResults ?? []
        if let bestScanResult = relevantScanResults.bestScanResult,
            bestScanResult.columnCount == 2
        {
            textPickerColumn1 = TextPickerColumn(
                column: 1,
                name: bestScanResult.headerTitle1,
                imageTexts: bestColumnImageTexts(at: 1, from: relevantScanResults)
            )

            textPickerColumn2 = TextPickerColumn(
                column: 2,
                name: bestScanResult.headerTitle2,
                imageTexts: bestColumnImageTexts(at: 2, from: relevantScanResults)
            )
            
            pickedColumn = bestScanResult.bestColumn
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showingColumnPicker = true
            }
        } else {
            processScanResults(column: 1, from: relevantScanResults)
        }
    }

    func bestColumnImageTexts(at column: Int, from relevantScanResults: [ScanResult]) -> [ImageText] {
        
        //TODO: Do this before hand in processScanResults once and pass it into both this and processScanResults(column:isUserInitiated:)
        let fieldViewModelsToExtract = [
            energyViewModel, carbViewModel, fatViewModel, proteinViewModel
        ] + allMicronutrientFieldViewModels
        
        let fieldValues = fieldViewModelsToExtract.compactMap {
            relevantScanResults.pickFieldValue(for: $0.fieldValue, at: column)
        }
        return fieldValues.compactMap { $0.fill.imageText }
    }
    
    func processScanResults(
        column pickedColumn: Int,
        from relevantScanResults: [ScanResult],
        isUserInitiated: Bool = false
    ) {
//        Task {
//            let isUserInitiated = pickedColumn != nil
            let column = pickedColumn
            
            let fieldViewModelsToExtract = [
                energyViewModel, carbViewModel, fatViewModel, proteinViewModel,
                amountViewModel, servingViewModel, densityViewModel
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
            
            /// Get Barcodes from all images
            for barcodeViewModel in scanResults.allBarcodeViewModels {
                guard add(barcodeViewModel: barcodeViewModel) else {
                    continue
                }
                barcodeViewModel.resetAndCropImage()
                replaceOrSetScannedFieldValue(barcodeViewModel.fieldValue)
            }
            
//            await MainActor.run {
                updateShouldShowDensitiesSection()
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

extension Size {
    func conflictsWith(_ otherSize: Size) -> Bool {
        self.name.lowercased() == otherSize.name.lowercased()
        && self.volumePrefixUnit == otherSize.volumePrefixUnit
    }
}
