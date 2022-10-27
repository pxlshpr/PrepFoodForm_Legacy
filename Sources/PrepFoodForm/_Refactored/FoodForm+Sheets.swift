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

    @ViewBuilder
    var textPicker: some View {
        if let columnSelectionInfo = sources.columnSelectionInfo {
            TextPicker(
                imageViewModels: sources.imageViewModels(for: columnSelectionInfo),
                mode: .columnSelection(
                    column1: columnSelectionInfo.column1,
                    column2: columnSelectionInfo.column2,
                    selectedColumn: columnSelectionInfo.bestColumn,
                    dismissHandler: {
                        //                    viewModel.removeUnprocessedImageViewModels()
                    },
                    selectionHandler: { pickedColumn in
                        Task {
                            let fieldValues = await sources.extractFieldsFrom(
                                columnSelectionInfo.candidates,
                                at: pickedColumn
                            )
                            didExtractFieldValues(fieldValues)
                        }
                        return true
                    })
            )
        }
    }

}
