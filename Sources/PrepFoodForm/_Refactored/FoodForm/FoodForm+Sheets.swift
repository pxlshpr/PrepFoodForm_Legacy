import SwiftUI
import EmojiPicker
import SwiftHaptics
import FoodLabelCamera
import FoodLabelScanner

extension FoodForm {
    var emojiPicker: some View {
        EmojiPicker(
            categories: [.foodAndDrink, .animalsAndNature],
            focusOnAppear: true,
            includeCancelButton: true
        ) { emoji in
            Haptics.successFeedback()
            self.emoji = emoji
            showingEmojiPicker = false
        }
    }
    
    var foodLabelCamera: some View {
        FoodLabelCamera(foodLabelScanHandler: didReceiveScanFromFoodLabelCamera)
    }

    func didDismissColumnPicker() {
        //TODO: Remove any unprocessed imageViewModels here
//        viewModel.removeUnprocessedImageViewModels()
    }
    
    func extract(column: Int, from results: [ScanResult], shouldOverwrite: Bool) {
        Task {
            let fieldValues = await sources.extractFieldsFrom(results, at: column)
            handleExtractedFieldValues(fieldValues, shouldOverwrite: shouldOverwrite)
        }
    }
    
    func autoFillColumn(_ selectedColumn: Int, from scanResult: ScanResult?) {
        guard let scanResult else {
            /// We shouldn't come here without a `ScanResult`
            return
        }
        extract(column: selectedColumn, from: [scanResult], shouldOverwrite: true)
    }
    
    @ViewBuilder
    var textPicker: some View {
        if let columnSelectionInfo = sources.columnSelectionInfo {
            TextPicker(
                imageViewModels: sources.imageViewModels(for: columnSelectionInfo),
                mode: .columnSelection(
                    column1: columnSelectionInfo.column1,
                    column2: columnSelectionInfo.column2,
                    selectedColumn: columnSelectionInfo.bestColumn,
                    requireConfirmation: false,
                    dismissHandler: didDismissColumnPicker,
                    columnSelectionHandler: { selectedColumn, _ in
                        extract(column: selectedColumn,
                                from: columnSelectionInfo.candidates,
                                shouldOverwrite: false
                        )
                    })
            )
        }
    }

    
    var mfpSearch: some View {
        MFPSearch()
    }
}
