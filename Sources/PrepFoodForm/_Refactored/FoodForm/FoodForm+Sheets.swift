import SwiftUI
import EmojiPicker
import SwiftHaptics
import FoodLabelCamera
import FoodLabelScanner
import MFPSearch
import Camera

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

    var barcodeScanner: some View {
        BarcodeScanner { barcodes, image in
            handleScannedBarcodes(barcodes, on: image)
        }
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
        MFPSearch { food in
            showingPrefill = false
            prefill(food)
        }
    }    

}
