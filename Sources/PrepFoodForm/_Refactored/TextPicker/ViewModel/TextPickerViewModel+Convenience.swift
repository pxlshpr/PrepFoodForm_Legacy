import SwiftUI
import VisionSugar
import FoodLabelScanner

extension TextPickerViewModel {
    
    var columnCountForCurrentImage: Int {
        currentImageViewModel?.scanResult?.columnCount ?? 0
    }
    
    var currentImageViewModel: ImageViewModel? {
        guard currentIndex < imageViewModels.count else { return nil }
        return imageViewModels[currentIndex]
    }
    
    var currentScanResult: ScanResult? {
        currentImageViewModel?.scanResult
    }
    
    var singleSelectedImageText: ImageText? {
        guard selectedImageTexts.count == 1 else {
            return nil
        }
        return selectedImageTexts.first
    }
    
    func boundingBox(forImageAt index: Int) -> CGRect {
        if mode.isColumnSelection {
            return mode.boundingBox(forImageWithId: imageViewModels[index].id) ?? .zero
        } else {
            return selectedBoundingBox(forImageAt: index) ?? imageViewModels[index].relevantBoundingBox
        }
    }
    
    func textBoxes(for imageViewModel: ImageViewModel) -> [TextBox] {
        let texts = texts(for: imageViewModel)
        var textBoxes: [TextBox] = []
        textBoxes = texts.map {
            TextBox(
                boundingBox: $0.boundingBox,
                color: color(for: $0),
                tapHandler: tapHandler(for: $0)
            )
        }
        
        textBoxes.append(
            contentsOf: barcodes(for: imageViewModel).map {
                TextBox(boundingBox: $0.boundingBox,
                        color: color(for: $0),
                        tapHandler: tapHandler(for: $0)
                )
        })
        return textBoxes
    }
    
    func shouldDismissAfterTappingDone() -> Bool {
        if case .multiSelection(_, _, let handler) = mode {
            handler(selectedImageTexts)
            return true
        } else if case .columnSelection(_, _, let selectedColumn, _, let selectionHandler) = mode {
            return selectionHandler(selectedColumn)
        }
        return true
    }
    


    func barcodes(for imageViewModel: ImageViewModel) -> [RecognizedBarcode] {
        guard mode.filter?.includesBarcodes == true else {
            return []
        }
        return imageViewModel.recognizedBarcodes
    }
    
    func texts(for imageViewModel: ImageViewModel) -> [RecognizedText] {
        
        guard !mode.isColumnSelection else {
            return mode.columnTexts(onImageWithId: imageViewModel.id)
        }
        
        let filter = mode.filter ?? .allTextsAndBarcodes
        let start = CFAbsoluteTimeGetCurrent()
        let texts = imageViewModel.texts(for: filter)
        print("🥸 texts took \(CFAbsoluteTimeGetCurrent()-start)s")
        return texts
    }
    
    func color(for barcode: RecognizedBarcode) -> Color {
        return Color.blue
    }
    
    func color(for text: RecognizedText) -> Color {
        if selectedImageTexts.contains(where: { $0.text == text }) {
            return Color.accentColor
        } else {
            return mode.isColumnSelection ? Color.white : Color.yellow
        }
    }
    
    func texts(at index: Int) -> [RecognizedText] {
        texts(for: imageViewModels[index])
    }
    
    var textsForCurrentImage: [RecognizedText] {
        return texts(for: imageViewModels[currentIndex])
        //        if onlyShowTextsWithValues {
        //            return imageViewModels[currentIndex].textsWithValues
        //        } else {
        //            return imageViewModels[currentIndex].texts
        //        }
    }
    
    var currentImageId: UUID? {
        imageViewModels[currentIndex].id
    }
    
    func imageSize(at index: Int) -> CGSize? {
        imageViewModels[index].image?.size
    }
    
    var currentImage: UIImage? {
        imageViewModels[currentIndex].image
    }
    var currentImageSize: CGSize? {
        currentImage?.size
    }
    
//    var shouldShowMenu: Bool {
//        allowsTogglingTexts || deleteImageHandler != nil
//    }
    
    var shouldShowActions: Bool {
//        allowsTogglingTexts || deleteImageHandler != nil
        mode.isImageViewer
    }

    var shouldShowDoneButton: Bool {
        mode.isMultiSelection || mode.isColumnSelection
    }
    
    var showShowImageSelector: Bool {
        (mode.isImageViewer || mode.isColumnSelection || mode.isMultiSelection) && imageViewModels.count > 1
    }

    var shouldShowSelectedTextsBar: Bool {
        mode.isMultiSelection
//        allowsMultipleSelection
    }
    
    var shouldShowColumnPickerBar: Bool {
        mode.isColumnSelection
    }

    var shouldShowBottomBar: Bool {
        showShowImageSelector || shouldShowSelectedTextsBar || shouldShowColumnPickerBar
    }
    
    var shouldShowMenuInTopBar: Bool {
        shouldShowActions
//        imageViewModels.count == 1 && shouldShowActions && allowsMultipleSelection == false
    }
    
    var columns: [TextColumn]? {
        guard case .columnSelection(let column1, let column2, _, _, _) = mode else {
            return nil
        }
        return [column1, column2]
    }
}
