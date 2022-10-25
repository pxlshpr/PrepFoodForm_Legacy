import SwiftUI
import SwiftHaptics
import PrepDataTypes
import PhotosUI
import Camera
import EmojiPicker
import SwiftUISugar
import FoodLabelCamera
import RSBarcodes_Swift

extension FoodForm {
    
    var cameraSheet: some View {
        Camera { image in
            viewModel.didCapture(image)
        }
    }
    
    var barcodeScannerSheet: some View {
        BarcodeScanner { barcodes, image in
            viewModel.didScan(barcodes, on: image)
        }
    }
    
    var foodLabelCameraSheet: some View {
        FoodLabelCamera { scanResult, image in
            viewModel.didScan(image, scanResult: scanResult)
        }
    }
    
    var emojiPickerSheet: some View {
        EmojiPicker(
            categories: [.foodAndDrink, .animalsAndNature],
            focusOnAppear: true
        ) { emoji in
            Haptics.feedback(style: .rigid)
            viewModel.emojiViewModel.fieldValue.stringValue.string = emoji
            viewModel.showingEmojiPicker = false
        }
    }
    
    @ViewBuilder
    var columnPicker: some View {
        if let column1 = viewModel.textPickerColumn1,
           let column2 = viewModel.textPickerColumn2
        {
            TextPicker(
                imageViewModels: viewModel.columnPickerImageViewModels,
                mode: .columnSelection(
                    column1: column1,
                    column2: column2,
                    selectedColumn: viewModel.pickedColumn,
                    dismissHandler: {
                        viewModel.removeUnprocessedImageViewModels()
                    },
                    selectionHandler: { pickedColumn in
                        viewModel.processScanResults(
                            column: pickedColumn,
                            from: viewModel.relevantScanResults
                        )
                        return true
                    })
            )
        }
    }
}
