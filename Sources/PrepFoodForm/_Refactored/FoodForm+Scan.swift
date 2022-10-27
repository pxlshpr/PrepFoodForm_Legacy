import SwiftUI
import FoodLabelScanner
import PrepDataTypes

extension FoodForm {
    
    @ViewBuilder
    var columnPicker: some View {
        if let columnSelectionInfo = sourcesViewModel.columnSelectionInfo {
            TextPicker(
                imageViewModels: sourcesViewModel.imageViewModels(for: columnSelectionInfo),
                mode: .columnSelection(
                    column1: columnSelectionInfo.column1,
                    column2: columnSelectionInfo.column2,
                    selectedColumn: columnSelectionInfo.bestColumn,
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
    }

}
