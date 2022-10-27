import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView
import SwiftUISugar

class TextPickerViewModel: ObservableObject {
    
    @Published var showingMenu = false
    @Published var showingAutoFillConfirmation = false
    @Published var imageViewModels: [ImageViewModel]
    @Published var showingBoxes: Bool
    @Published var selectedImageTexts: [ImageText]
    @Published var zoomBoxes: [ZoomBox?]
    @Published var page: Page
    
    @Published var currentIndex: Int = 0
    @Published var hasAppeared: Bool = false
    @Published var shouldDismiss: Bool = false
    
    let initialImageIndex: Int
    @Published var mode: TextPickerMode
    @Published var selectedColumn: Int
    
    init(imageViewModels: [ImageViewModel], mode: TextPickerMode ){
        self.imageViewModels = imageViewModels
        self.mode = mode
        self.selectedImageTexts = mode.selectedImageTexts
        showingBoxes = !mode.isImageViewer
        zoomBoxes = Array(repeating: nil, count: imageViewModels.count)
        
        initialImageIndex = mode.initialImageIndex(from: imageViewModels)
        page = .withIndex(initialImageIndex)
        currentIndex = initialImageIndex
        selectedColumn = mode.selectedColumnIndex ?? 1
    }
}

//MARK: - Actions
extension TextPickerViewModel {
    
    func setInitialState() {
        withAnimation {
            self.hasAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for i in self.imageViewModels.indices {
                self.setDefaultZoomBox(forImageAt: i)
                self.setZoomFocusBox(forImageAt: i)
            }
        }
    }
    
    func deleteCurrentImage() {
        guard let deleteImageHandler = mode.deleteImageHandler else { return }
        withAnimation {
            let _ = imageViewModels.remove(at: currentIndex)
            deleteImageHandler(currentIndex)
            if imageViewModels.isEmpty {
                shouldDismiss = true
            } else if currentIndex != 0 {
                currentIndex -= 1
            }
        }
    }
    
    func pickedColumn(_ index: Int) {
        mode.selectedColumnIndex = index
        withAnimation {
            selectedImageTexts = mode.selectedImageTexts
        }
    }
    
    func tappedConfirmAutoFill() {
        guard let currentScanResult else { return }
        FoodFormViewModel.shared.processScanResults(
            column: selectedColumn,
            from: [currentScanResult],
            isUserInitiated: true
        )
        shouldDismiss = true
    }
    
    func selectedBoundingBox(forImageAt index: Int) -> CGRect? {
        guard let singleSelectedImageText, singleSelectedImageText.imageId == imageViewModels[index].id else {
            return nil
        }
        
        let texts = textsForCurrentImage
        
        /// Only show the union of the attribute and selected texts if the union of them both does not entirely cover any other texts we will be displaying.
        if !texts.contains(where: { singleSelectedImageText.boundingBoxWithAttribute.contains($0.boundingBox)}) {
            return singleSelectedImageText.boundingBoxWithAttribute
        } else {
            return singleSelectedImageText.boundingBox
        }
    }
    
    func setDefaultZoomBox(forImageAt index: Int) {
        guard let imageSize = imageSize(at: index) else {
            return
        }
        
        let initialZoomBox = ZoomBox(
            boundingBox: boundingBox(forImageAt: index),
            animated: true,
            padded: true,
            imageSize: imageSize,
            imageId: imageViewModels[index].id
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let userInfo = [Notification.ZoomableScrollViewKeys.zoomBox: initialZoomBox]
            NotificationCenter.default.post(name: .zoomZoomableScrollView, object: nil, userInfo: userInfo)
        }
    }

    func setZoomFocusBox(forImageAt index: Int) {
        guard let imageSize = imageSize(at: index), zoomBoxes[index] == nil else {
            return
        }
        
        let zoomFocusedBox = ZoomBox(
            boundingBox: boundingBox(forImageAt: index),
            animated: true,
            padded: true,
            imageSize: imageSize,
            imageId: imageViewModels[index].id
        )
        zoomBoxes[index] = zoomFocusedBox
    }
    func tapHandler(for barcode: RecognizedBarcode) -> (() -> ())? {
        nil
    }

    func tapHandlerForColumnSelection(for text: RecognizedText) -> (() -> ())? {
        guard !mode.selectedColumnContains(text),
              let selectedColumnIndex = mode.selectedColumnIndex
        else {
            return nil
        }
        return {
            Haptics.feedback(style: .heavy)
            withAnimation {
                self.selectedColumn = selectedColumnIndex == 1 ? 2 : 1
            }
        }
    }

    func tapHandlerForTextSelection(for text: RecognizedText) -> (() -> ())? {
        guard let currentImageId else {
            return nil
        }
        
        let imageText = ImageText(text: text, imageId: currentImageId)

        if mode.isMultiSelection {
            return {
                self.toggleSelection(of: imageText)
            }
        } else {
            guard let singleSelectionHandler = mode.singleSelectionHandler else {
                return nil
            }
            return {
                singleSelectionHandler(imageText)
                self.shouldDismiss = true
            }
        }
    }
    
    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        if mode.isColumnSelection {
            return tapHandlerForColumnSelection(for: text)
        } else if mode.supportsTextSelection {
            return tapHandlerForTextSelection(for: text)
        } else {
            return nil
        }
    }
    
    func tappedAutoFill() {
        guard let scanResult = imageViewModels[currentIndex].scanResult else {
            return
        }
        if scanResult.columnCount == 1 {
            
            FoodFormViewModel.shared.processScanResults(
                column: 1,
                from: [scanResult],
                isUserInitiated: true
            )
            
            shouldDismiss = true

        } else if scanResult.columnCount == 2 {
            let column1 = TextColumn(
                column: 1,
                name: scanResult.headerTitle1,
                imageTexts: FoodFormViewModel.shared.columnImageTexts(at: 1, from: scanResult)
            )
            let column2 = TextColumn(
                column: 2,
                name: scanResult.headerTitle2,
                imageTexts: FoodFormViewModel.shared.columnImageTexts(at: 2, from: scanResult)
            )
            withAnimation {
                let bestColumn = scanResult.bestColumn
                self.selectedColumn = bestColumn
                mode = .columnSelection(
                    column1: column1,
                    column2: column2,
                    selectedColumn: bestColumn,
                    dismissHandler: {
                        self.shouldDismiss = true
                    },
                    selectionHandler: { selectedColumn in
                        self.showingAutoFillConfirmation = true
                        return false
                    }
                )
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    self.showingBoxes = true
                    self.selectedImageTexts = self.mode.selectedImageTexts
                }
            }
        } else {
            shouldDismiss = true
        }
    }
    
    func tappedDismiss() {
        if case .columnSelection(_, _, _, let dismissHandler, _) = mode {
            dismissHandler()
        }
    }
    
    func toggleSelection(of imageText: ImageText) {
        if selectedImageTexts.contains(imageText) {
            Haptics.feedback(style: .light)
            withAnimation {
                selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } else {
            Haptics.feedback(style: .soft)
            withAnimation {
                selectedImageTexts.append(imageText)
            }
        }
    }

    func didTapThumbnail(at index: Int) {
        Haptics.feedback(style: .rigid)
        page(toImageAt: index)
        
        /// wait till the page animation completes
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//
//            /// send the focus message to this page if we haven't sent the animated one yet
//            if !self.didSendAnimatedFocusMessage[index] {
//                self.setFocusBoxForImage(at: index, animated: true)
//            }
//
//            /// send a (non-animated) focus message to all *other* pages that have already received an animated focus message
//            for i in 0..<self.imageViewModels.count {
//                guard i != index,
//                      self.didSendAnimatedFocusMessage[index]
//                else {
//                    continue
//                }
//
//                self.setFocusBoxForImage(at: i, animated: false)
//            }
//        }
    }
    
}

//MARK: - Pager Related
extension TextPickerViewModel {
    func pageWillChange(to index: Int) {
        withAnimation {
            currentIndex = index
        }
    }
    
    func pageDidChange(to index: Int) {
        /// Now reset the focus box for all the other images
        for i in imageViewModels.indices {
            guard i != index else { continue }
            setDefaultZoomBox(forImageAt: i)
        }
    }
    
    func page(toImageAt index: Int) {
        /// **We can't do this here, because it doesn't exist yet**
//        setDefaultZoomBox(forImageAt: index)

        let increment = index - currentIndex
        withAnimation {
            /// **This causes the `ZoomableScrollView` at `index` to be recreated if its outside the 3-item window kept in memory**
            page.update(.move(increment: increment))
            currentIndex = index
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setDefaultZoomBox(forImageAt: index)
        }
        
        /// Call this manually as it won't be called on our end
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            /// **Doing this here is too late**
//            self.setDefaultZoomBox(forImageAt: index)
            self.pageDidChange(to: index)
        }
    }
    
}

//MARK: - Convenience
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
