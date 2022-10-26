import SwiftUI
import FoodLabelScanner
import PrepDataTypes

extension FoodForm {
    func processScanResults() {
        imageSetStatus = .scanned
        
        Task {
            guard let output = await ScanResultsProcessor.shared.process(allScanResults) else {
                return
            }
            await MainActor.run {
                switch output {
                case .twoColumns(let twoColumnOutput):
                    print("🍩 Setting twoColumnOutput")
                    self.twoColumnOutput = twoColumnOutput
                case .oneColumn:
                    break
                }
            }
        }
    }
    
    @ViewBuilder
    func columnPicker(_ twoColumnOutput: ScanResultsTwoColumnOutput) -> some View {
        TextPicker(
            imageViewModels: imageViewModels.containingTexts(in: twoColumnOutput),
            mode: .columnSelection(
                column1: twoColumnOutput.column1,
                column2: twoColumnOutput.column2,
                selectedColumn: twoColumnOutput.bestColumn,
                dismissHandler: {
//                    viewModel.removeUnprocessedImageViewModels()
                },
                selectionHandler: { pickedColumn in
//                    viewModel.processScanResults(
//                        column: pickedColumn,
//                        from: viewModel.candidateScanResults
//                    )
                    return true
                })
        )
    }

    var allScanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }
}

extension Array where Element == ImageViewModel {
    func containingTexts(in output: ScanResultsTwoColumnOutput) -> [ImageViewModel] {
        filter {
            output.column1.containsTexts(from: $0) || output.column2.containsTexts(from: $0)
        }
    }
}


struct ScanResultsTwoColumnOutput: Identifiable {
    let id = UUID()
    let column1: TextColumn
    let column2: TextColumn
    let bestColumn: Int
}

enum ScanResultsOutput {
    case twoColumns(ScanResultsTwoColumnOutput)
    case oneColumn
}

class ScanResultsProcessor {
    
    static let shared = ScanResultsProcessor()
    
    func process(_ scanResults: [ScanResult]) async -> ScanResultsOutput? {
        
        let candidates = scanResults.candidateScanResults
        guard let best = candidates.bestScanResult else {
            return nil
        }
        
        if candidates.minimumNumberOfColumns == 2 {
            let column1 = TextColumn(
                column: 1,
                name: best.headerTitle1,
                imageTexts: candidates.bestImageTexts(forColumn: 1)
            )
            let column2 = TextColumn(
                column: 2,
                name: best.headerTitle2,
                imageTexts: candidates.bestImageTexts(forColumn: 2)
            )
            let bestColumn = best.bestColumn
            
            let twoColumnOutput = ScanResultsTwoColumnOutput(
                column1: column1,
                column2: column2,
                bestColumn: bestColumn
            )
            return .twoColumns(twoColumnOutput)
        } else {
//            processScanResults(column: 1, from: candidateScanResults)
            return .oneColumn
        }
    }
}

extension Array where Element == ScanResult {
    
    func bestImageTexts(forColumn column: Int) -> [ImageText] {
        var fieldValues: [FieldValue?] = []
        fieldValues.append(bestEnergyFieldValue(at: column))
        for macro in Macro.allCases {
            fieldValues.append(bestMacroFieldValue(macro, at: column))
        }
        for nutrientType in NutrientType.allCases {
            fieldValues.append(bestMicroFieldValue(nutrientType, at: column))
        }
        return fieldValues.compactMap({ $0?.fill.imageText })
    }
    
    /** Minimum number of columns */
    var minimumNumberOfColumns: Int {
        allSatisfy({ $0.columnCount == 2 }) ? 2 : 1
    }
}
