import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
//import ZoomableScrollView
import ActivityIndicatorView

class TextPickerViewModel: ObservableObject {
    
    @Published var showingMenu = false
    @Published var showingAutoFillConfirmation = false
    @Published var imageViewModels: [ImageViewModel]
    @Published var showingBoxes: Bool
    @Published var selectedImageTexts: [ImageText]
    @Published var focusedBoxes: [FocusedBox?]
    @Published var zoomBoxes: [FocusedBox?]
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
        focusedBoxes = Array(repeating: nil, count: imageViewModels.count)
        zoomBoxes = Array(repeating: nil, count: imageViewModels.count)

        initialImageIndex = mode.initialImageIndex(from: imageViewModels)
        page = .withIndex(initialImageIndex)
        currentIndex = initialImageIndex
        selectedColumn = mode.selectedColumnIndex ?? 1
    }
    
    func setInitialState() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.hasAppeared = true
            }
//        }
        for i in imageViewModels.indices {
            setInitialFocusBox(forImageAt: i)
        }
        removeFocusedBoxAfterDelay(forImageAt: initialImageIndex)
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
    
    var columnCountForCurrentImage: Int {
        currentImageViewModel?.scanResult?.columnCount ?? 0
    }
    
    var currentImageViewModel: ImageViewModel? {
        guard currentIndex < imageViewModels.count else { return nil }
        return imageViewModels[currentIndex]
    }
    
    func pickedColumn(_ index: Int) {
        mode.selectedColumnIndex = index
        withAnimation {
            selectedImageTexts = mode.selectedImageTexts
        }
    }
    
    var currentScanResult: ScanResult? {
        currentImageViewModel?.scanResult
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
    
    func removeFocusedBoxAfterDelay(forImageAt index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) {
            self.focusedBoxes[index] = nil
        }
    }
    
    var singleSelectedImageText: ImageText? {
        guard selectedImageTexts.count == 1 else {
            return nil
        }
        return selectedImageTexts.first
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
    
    func pageWillChange(to index: Int) {
        withAnimation {
            currentIndex = index
        }
    }
    
    func pageDidChange(to index: Int) {
        /// Do this so that the focused box doesn't keep resetting
        removeFocusedBoxAfterDelay(forImageAt: index)
        
        /// Now reset the focus box for all the other images
        for i in imageViewModels.indices {
            guard i != index else { continue }
            setInitialFocusBox(forImageAt: i)
        }
    }
    
    func boundingBox(forImageAt index: Int) -> CGRect {
        if mode.isColumnSelection {
            return mode.boundingBox(forImageWithId: imageViewModels[index].id) ?? .zero
        } else {
            return selectedBoundingBox(forImageAt: index) ?? imageViewModels[index].relevantBoundingBox
        }
    }
    
    func setInitialFocusBox(forImageAt index: Int) {
        /// Make sure we're not already focused on an area of this image
//        let index = initialImageIndex
        guard let imageSize = imageSize(at: index), focusedBoxes[index] == nil else {
            return
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.0)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            let boundingBox = self.boundingBox(forImageAt: index)
            
            self.focusedBoxes[index] = FocusedBox(
                boundingBox: boundingBox,
                animated: false,
                imageSize: imageSize
            )
            self.zoomBoxes[index] = FocusedBox(
                boundingBox: boundingBox,
                animated: true,
                padded: true,
                imageSize: imageSize
            )
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
            let column1 = TextPickerColumn(
                column: 1,
                name: scanResult.headerTitle1,
                imageTexts: FoodFormViewModel.shared.columnImageTexts(at: 1, from: scanResult)
            )
            let column2 = TextPickerColumn(
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
    
    func shouldDismissAfterTappingDone() -> Bool {
        if case .multiSelection(_, _, let handler) = mode {
            handler(selectedImageTexts)
            return true
        } else if case .columnSelection(_, _, let selectedColumn, _, let selectionHandler) = mode {
            return selectionHandler(selectedColumn)
        }
        return true
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
            Haptics.transientHaptic()
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
    
    func page(toImageAt index: Int) {
        let increment = index - currentIndex
        withAnimation {
            page.update(.move(increment: increment))
            currentIndex = index
        }
        /// Call this manually as it won't be called on our end
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pageDidChange(to: index)
        }
    }
    
    func barcodes(for imageViewModel: ImageViewModel) -> [RecognizedBarcode] {
        guard mode.filter?.includesBarcodes == true else {
            return []
        }
        return imageViewModel.barcodeTexts
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
    
    var columns: [TextPickerColumn]? {
        guard case .columnSelection(let column1, let column2, _, _, _) = mode else {
            return nil
        }
        return [column1, column2]
    }
}

extension ImageText {
    var boundingBoxWithAttribute: CGRect {
        guard let attributeText else { return text.boundingBox }
        return attributeText.boundingBox.union(text.boundingBox)
    }
    
    var boundingBox: CGRect {
        text.boundingBox
    }
}

//MARK: - TextPicker

import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var textPickerViewModel: TextPickerViewModel
    
    init(imageViewModels: [ImageViewModel], mode: TextPickerMode) {
        let viewModel = TextPickerViewModel(
            imageViewModels: imageViewModels,
            mode: mode
        )
        _textPickerViewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Views
    
    var body: some View {
        ZStack {
            pagerLayer
                .edgesIgnoringSafeArea(.all)
            buttonsLayer
        }
        .onAppear(perform: appeared)
        .onChange(of: textPickerViewModel.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .bottomMenu(isPresented: $textPickerViewModel.showingMenu, actionGroups: menuActions)
        .bottomMenu(isPresented: $textPickerViewModel.showingAutoFillConfirmation,
                    actionGroups: [autoFillConfirmActionGroup])
    }
    
    //MARK:  Pager Layer
    
    var pagerLayer: some View {
        Pager(
            page: textPickerViewModel.page,
            data: textPickerViewModel.imageViewModels,
            id: \.hashValue,
            content: { imageViewModel in
                zoomableScrollView(for: imageViewModel)
                    .background(.black)
            })
        .sensitivity(.high)
        .pagingPriority(.high)
        .onPageWillChange { index in
            textPickerViewModel.pageWillChange(to: index)
        }
        .onPageChanged { index in
            textPickerViewModel.pageDidChange(to: index)
        }
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = textPickerViewModel.imageViewModels.firstIndex(of: imageViewModel),
           index < textPickerViewModel.focusedBoxes.count,
           index < textPickerViewModel.zoomBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(focusedBox: $textPickerViewModel.focusedBoxes[index],
                               zoomBox: $textPickerViewModel.zoomBoxes[index],
                               backgroundColor: .black)
            {
                ZStack {
                    imageView(image)
                        .overlay(textBoxesLayer(for: imageViewModel))
                    //                    textBoxesLayer(for: imageViewModel)
                }
            }
        }
    }
    
    @ViewBuilder
    func textBoxesLayer(for imageViewModel: ImageViewModel) -> some View {
//        if config.showingBoxes {
            TextBoxesLayer(textBoxes: textPickerViewModel.textBoxes(for: imageViewModel))
                .opacity((textPickerViewModel.hasAppeared && textPickerViewModel.showingBoxes) ? 1 : 0)
                .animation(.default, value: textPickerViewModel.hasAppeared)
                .animation(.default, value: textPickerViewModel.showingBoxes)
//        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.black)
            .opacity(textPickerViewModel.showingBoxes ? 0.7 : 1)
            .animation(.default, value: textPickerViewModel.showingBoxes)
    }
    
    //MARK: ButtonsLayer
    
    var buttonsLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            if textPickerViewModel.shouldShowBottomBar {
                bottomBar
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    var topBar: some View {
        ZStack {
            HStack {
                dismissButton
                Spacer()
            }
            HStack {
                Spacer()
                if let title {
                    titleView(for: title)
                        .transition(.scale)
                }
                Spacer()
            }
            HStack {
                Spacer()
                if textPickerViewModel.shouldShowMenuInTopBar {
                    topMenuButton
                        .transition(.move(edge: .trailing))
                } else {
                    doneButton
                }
            }
        }
        .frame(height: 64)
    }
    
    var bottomBar: some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                if textPickerViewModel.shouldShowSelectedTextsBar {
                    selectedTextsBar
                }
                if textPickerViewModel.shouldShowColumnPickerBar {
                    columnPickerBar
                }
                if textPickerViewModel.showShowImageSelector {
                    actionBar
                }
            }
        }
        .frame(height: bottomBarHeight)
        .background(.ultraThinMaterial)
    }
    
    var bottomBarHeight: CGFloat {
        var height: CGFloat = 0
        if textPickerViewModel.showShowImageSelector {
            height += actionBarHeight
        }
        if textPickerViewModel.shouldShowSelectedTextsBar {
            height += selectedTextsBarHeight
        }
        if textPickerViewModel.shouldShowColumnPickerBar {
            height += columnPickerBarHeight
        }

        return height
    }
    
    var actionBarHeight: CGFloat { 70 }
    var selectedTextsBarHeight: CGFloat { 60 }
    var columnPickerBarHeight: CGFloat { 60 }

    var actionBar: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(textPickerViewModel.imageViewModels.indices, id: \.self) { index in
                    thumbnail(at: index)
                }
            }
            .padding(.leading, 20)
            .padding(.top, 15)
            Spacer()
//            if config.shouldShowMenu {
//                menuButton
//                    .padding(.top, 15)
//            }
        }
        .frame(height: 70)
    }
    
    var selectedTextsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(textPickerViewModel.selectedImageTexts, id: \.self) { imageText in
                    selectedTextButton(for: imageText)
                }
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        //        .background(.green)
    }

    @State var pickedColumn: Int = 1
    
    @ViewBuilder
    var columnPickerBar: some View {
        if let columns = textPickerViewModel.columns {
            Picker("", selection: $textPickerViewModel.selectedColumn) {
                ForEach(columns.indices, id: \.self) { i in
//                    selectedTextButton(for: columns[i])
                    Text(columns[i].name)
                        .tag(i+1)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .onChange(of: textPickerViewModel.selectedColumn) { newValue in
                Haptics.feedback(style: .soft)
                textPickerViewModel.pickedColumn(newValue)
            }
        }
    }

    func selectedTextButton(for column: TextPickerColumn) -> some View {
        Button {
            withAnimation {
                textPickerViewModel.pickedColumn(column.column)
            }
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color.accentColor)
                HStack(spacing: 5) {
                    Text(column.name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
            .transition(.move(edge: .leading))
        }
        .frame(height: 40)
    }
    
    func selectedTextButton(for imageText: ImageText) -> some View {
        Button {
            withAnimation {
                textPickerViewModel.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color.accentColor)
                HStack(spacing: 5) {
                    Text(imageText.text.string.capitalizedIfUppercase)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
            .transition(.move(edge: .leading))
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    var doneButton: some View {
        if textPickerViewModel.shouldShowDoneButton {
            Button {
                if textPickerViewModel.shouldDismissAfterTappingDone() {
                    Haptics.successFeedback()
                    dismiss()
                }
            } label: {
                Text("Done")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.accentColor.opacity(0.8))
                            .background(.ultraThinMaterial)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15)
                    )
                    .shadow(radius: 3, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .disabled(textPickerViewModel.selectedImageTexts.isEmpty)
            .transition(.scale)
        }
    }
    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            textPickerViewModel.tappedDismiss()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                )
                .clipShape(Circle())
                .shadow(radius: 3, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
    }
    
    var title: String? {
        textPickerViewModel.mode.prompt
    }
    
    func titleView(for title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
//            .padding(12)
            .padding(.horizontal, 12)
            .frame(height: 45)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
    }
    
    var topMenuButton: some View {
        Button {
            Haptics.transientHaptic()
            textPickerViewModel.showingMenu = true
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 40, height: 40)
                .foregroundColor(.primary)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                )
                .clipShape(Circle())
                .shadow(radius: 3, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())

        }
    }
    
    var autoFillConfirmActionGroup: [BottomMenuAction] {
        [
            BottomMenuAction(
                title: "This will replace any existing data."
            ),
            BottomMenuAction(
                title: "AutoFill",
                tapHandler: {
                    textPickerViewModel.tappedConfirmAutoFill()
                }
            )
        ]
    }
    
    var autoFillLinkAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            linkedActionGroups: [autoFillConfirmActionGroup]
        )
    }
    
    var autoFillButtonAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            tapHandler: {
                textPickerViewModel.tappedAutoFill()
            }
        )
    }
    
    var autoFillAction: BottomMenuAction? {
        switch textPickerViewModel.columnCountForCurrentImage {
        case 2: return autoFillButtonAction
        case 1: return autoFillLinkAction
        default: return nil
        }
    }
    
    var showHideAction: BottomMenuAction {
        BottomMenuAction(
            title: "\(textPickerViewModel.showingBoxes ? "Hide" : "Show") Texts",
            systemImage: "eye\(textPickerViewModel.showingBoxes ? ".slash" : "")",
            tapHandler: {
                withAnimation {
                    textPickerViewModel.showingBoxes.toggle()
                }
            })
    }
    
    var topActionSections: [BottomMenuAction] {
        if let autoFillAction {
            return [autoFillAction, showHideAction]
        } else {
            return [showHideAction]
        }
    }
    
    var menuActions: [[BottomMenuAction]] {
        [
            topActionSections,
            [
                BottomMenuAction(
                    title: "Delete Photo",
                    systemImage: "trash",
                    role: .destructive,
                    linkedActionGroups: [[
                        BottomMenuAction(
                            title: "This photo will be deleted while the data you filled from it will remain."
                        ),
                        BottomMenuAction(
                            title: "Delete Photo",
                            role: .destructive,
                            tapHandler: {
                                textPickerViewModel.deleteCurrentImage()
                            })
                    ]]
                ),

            ]
        ]
    }
    
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            textPickerViewModel.currentIndex == index
        }
        
        return Group {
            if let image = textPickerViewModel.imageViewModels[index].image {
                Button {
                    textPickerViewModel.didTapThumbnail(at: index)
                } label: {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.accentColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                        .foregroundColor(.primary)
                                        .padding(-0.5)
                                )
                                .opacity(isSelected ? 1.0 : 0.0)
                        )
                }
            }
        }
    }
    
    //MARK: - Actions
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            textPickerViewModel.setInitialState()
        }
    }
    
    //MARK: - User Actions
    func toggleSelection(of imageText: ImageText) {
        if textPickerViewModel.selectedImageTexts.contains(imageText) {
            Haptics.feedback(style: .light)
            withAnimation {
                textPickerViewModel.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } else {
            Haptics.transientHaptic()
            withAnimation {
                textPickerViewModel.selectedImageTexts.append(imageText)
            }
        }
    }    
}

//MARK: - Preview

public struct TextPickerPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    //    @State var fieldValue: FieldValue
    
//    @State var text_4percent: ImageText
//    @State var text_nutritionInformation: ImageText
//    @State var text_servingSize: ImageText
//    @State var text_servingsPerPackage: ImageText
//    @State var text_allNatural: ImageText
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .pumpkinSeeds)
        //        let viewModel = FoodFormViewModel.mockWith5Images
        _viewModel = StateObject(wrappedValue: viewModel)
        
//        _text_4percent = State(initialValue: ImageText(
//            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "57710D30-C601-4F36-8A10-62C8C2674702")!})!,
//            imageId: viewModel.imageViewModels.first!.id)
//        )
//
//        _text_allNatural = State(initialValue: ImageText(
//            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "939BB79B-612E-459E-A6B6-C6AD739F382F")!})!,
//            imageId: viewModel.imageViewModels.first!.id)
//        )
//
//        _text_nutritionInformation = State(initialValue: ImageText(
//            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "2D44204B-DD7E-41FC-B807-C10DEB86B8F8")!})!,
//            imageId: viewModel.imageViewModels.first!.id)
//        )
//
//        _text_servingSize = State(initialValue: ImageText(
//            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "8229CEAC-9AC4-432B-8D1D-0073A6208E14")!})!,
//            imageId: viewModel.imageViewModels.first!.id)
//        )
//
//        _text_servingsPerPackage = State(initialValue: ImageText(
//            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "00EECEEC-5D78-4DD4-BFF1-4B259296FE06")!})!,
//            imageId: viewModel.imageViewModels.first!.id)
//        )
        
    }
    
    public var body: some View {
        NavigationView {
            Text("")
                .fullScreenCover(isPresented: .constant(true)) {
                    TextPicker(imageViewModels: viewModel.imageViewModels,
                               mode: .imageViewer(initialImageIndex: 0, deleteHandler: { deletedIndex in
                        
                    }))
                }
                .navigationTitle("Text Picker")
        }
    }
}

struct TextPicker_Previews: PreviewProvider {
    static var previews: some View {
        TextPickerPreview()
    }
}


//MARK: - ZoomableScrollView

import UIKit

extension UIScrollView {
    
    func zoomToScale(_ newZoomScale: CGFloat, on point: CGPoint) {
        let scaleChange = newZoomScale / zoomScale
        let rect = zoomRect(forFactorChangeInZoomScaleOf: scaleChange, on: point)
        zoom(to: rect, animated: true)
    }
    
    func zoomRect(forFactorChangeInZoomScaleOf factor: CGFloat, on point: CGPoint) -> CGRect {
        let size = CGSize(width: frame.size.width / factor,
                          height: frame.size.height / factor)
        let zoomSize = CGSize(width: size.width / zoomScale,
                              height: size.height / zoomScale)
        
        let origin = CGPoint(x: point.x - (zoomSize.width / factor),
                             y: point.y - (zoomSize.height / factor))
        return CGRect(origin: origin, size: zoomSize)
    }
    func focus(on focusedBox: FocusedBox, animated: Bool = true) {
        zoomIn(
            boundingBox: focusedBox.boundingBox,
            padded: focusedBox.padded,
            imageSize: focusedBox.imageSize,
            animated: focusedBox.animated
        )
    }
    
    func zoomIn(boundingBox: CGRect, padded: Bool, imageSize: CGSize, animated: Bool = true) {
        
        let zoomRect = boundingBox.zoomRect(forImageSize: imageSize, fittedInto: frame.size, padded: padded)
//        var zoomRect = boundingBox.rectForSize(imageSize, fittedInto: frame.size)
//        if padded {
//            let ratio = min(frame.size.width / (zoomRect.size.width * 5), 3.5)
//            zoomRect.pad(within: frame.size, ratio: ratio)
//        }
        
        print("🔍 zoomIn on: \(zoomRect) within \(frame.size), contentSize \(contentSize), contentOffset \(contentOffset)")
        let zoomScaleX = frame.size.width / zoomRect.width
//        print("🔍 zoomScaleX is \(zoomScaleX)")
        let zoomScaleY = frame.size.height / zoomRect.height
//        print("🔍 zoomScaleY is \(zoomScaleY)")

//        print("🔍 🤖 calculated zoomScale is: \(zoomRect.zoomScale(within: frame.size))")

        zoom(to: zoomRect, animated: animated)
    }
}

extension CGRect {
    
    func zoomRect(forImageSize imageSize: CGSize, fittedInto frameSize: CGSize, padded: Bool) -> CGRect {
        var zoomRect = rectForSize(imageSize, fittedInto: frameSize)
        if padded {
            let ratio = min(frameSize.width / (zoomRect.size.width * 5), 3.5)
            zoomRect.pad(within: frameSize, ratio: ratio)
        }
        return zoomRect
    }
    func zoomScale(within parentSize: CGSize) -> CGFloat {
        let xScale = parentSize.width / width
        let yScale = parentSize.height / height
        return min(xScale, yScale)
    }
    
    mutating func pad(within parentSize: CGSize, ratio: CGFloat) {
        padX(withRatio: ratio, withinParentSize: parentSize)
        padY(withRatio: ratio, withinParentSize: parentSize)
    }

}

extension CGRect {

    mutating func padX(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padX(withRatioOfWidth: paddingRatio)
        origin.x = max(padding, origin.x)
        if maxX > parentSize.width {
            size.width = parentSize.width - origin.x - padding
        }
    }

    mutating func padY(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padY(withRatioOfHeight: paddingRatio)
        origin.y = max(padding, origin.y)
        if maxY > parentSize.height {
            size.height = parentSize.height - origin.y - padding
        }
    }
    
    mutating func padX(withRatioOfWidth ratio: CGFloat) {
        let padding = size.width * ratio
        padX(with: padding)
    }
    
    mutating func padX(with padding: CGFloat) {
        origin.x -= (padding / 2.0)
        size.width += padding
    }
    
    mutating func padY(withRatioOfHeight ratio: CGFloat) {
        let padding = size.height * ratio
        padY(with: padding)
    }
    
    mutating func padY(with padding: CGFloat) {
        origin.y -= (padding / 2.0)
        size.height += padding
    }
    
    func rectForSize(_ size: CGSize, fittedInto frameSize: CGSize) -> CGRect {
        let sizeFittingFrame = size.sizeFittingWithin(frameSize)
        var rect = rectForSize(sizeFittingFrame)

        let paddingLeft: CGFloat?
        let paddingTop: CGFloat?
        if size.widthToHeightRatio < frameSize.widthToHeightRatio {
            paddingLeft = (frameSize.width - sizeFittingFrame.width) / 2.0
            paddingTop = nil
        } else {
            paddingLeft = nil
            paddingTop = (frameSize.height - sizeFittingFrame.height) / 2.0
        }

        if let paddingLeft {
            rect.origin.x += paddingLeft
        }
        if let paddingTop {
            rect.origin.y += paddingTop
        }

        return rect
    }
}

extension CGSize {
    /// Returns a size that fits within the parent size
    func sizeFittingWithin(_ size: CGSize) -> CGSize {
        let newWidth: CGFloat
        let newHeight: CGFloat
        if widthToHeightRatio < size.widthToHeightRatio {
            /// height would be the same as parent
            newHeight = size.height
            
            /// we're scaling the width accordingly
            newWidth = (width * newHeight) / height
        } else {
            /// width would be the same as parent
            newWidth = size.width
            
            /// we're scaling the height accordingly
            newHeight = (height * newWidth) / width
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}

import SwiftUI
import VisionSugar
import SwiftUISugar

/// This identifies an area of the ZoomableScrollView to focus on
public struct FocusedBox {
    
    /// This is the boundingBox (in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision)
    let boundingBox: CGRect
    let padded: Bool
    let animated: Bool
    let imageSize: CGSize
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
    }
    
    public static let none = Self.init(boundingBox: .zero, imageSize: .zero)
}

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    @State var lastFocusedArea: FocusedBox? = nil
    @State var firstTime: Bool = true
    
    let backgroundColor: UIColor?
    private var content: Content
    
    var focusedBox: Binding<FocusedBox?>?
    var zoomBox: Binding<FocusedBox?>?

    public init(
        focusedBox: Binding<FocusedBox?>? = nil,
        zoomBox: Binding<FocusedBox?>? = nil,
        backgroundColor: UIColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
        self.focusedBox = focusedBox
        self.zoomBox = zoomBox
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        scrollView(context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == scrollView)
        
        if let focusedBox = focusedBox?.wrappedValue {
            
            /// If we've set it to `.zero` we're indicating that we want it to reset the zoom
            if focusedBox.boundingBox == .zero {
                scrollView.setZoomScale(1, animated: true)
            } else {
                //TODO: Clean this up—this fixes the issue we had with the initial zoom
                scrollView.layer.opacity = 0
                scrollView.setZoomScale(1, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    scrollView.setZoomScale(2, animated: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        scrollView.setZoomScale(1, animated: false)
                        scrollView.layer.opacity = 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            scrollView.focus(on: focusedBox)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        @objc func doubleTapped(recognizer:  UITapGestureRecognizer) {
            
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            print("🔍 zoomScale is \(scrollView.zoomScale), contentSize is \(scrollView.contentSize)")
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            print("🪝 scrollViewDidScroll \(scrollView.contentOffset) @ \(scrollView.zoomScale)")
        }
    }
}

import SwiftUI
import VisionSugar
import SwiftUISugar

extension ZoomableScrollView {
    
    func hostedView(context: Context) -> UIView {
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return hostedView
    }
    
    func scrollView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        
        let hosted = hostedView(context: context)
        hosted.frame = scrollView.bounds
        if let backgroundColor {
            hosted.backgroundColor = backgroundColor
        }
        scrollView.addSubview(hosted)
        
        scrollView.setZoomScale(1, animated: true)
        
        scrollView.addTapGestureRecognizer { sender in
            let hostedView = hostedView(context: context)
            let point = sender.location(in: hostedView)
            handleDoubleTap(on: point, for: scrollView)
        }
        
        return scrollView
    }
    
    //TODO: Rewrite this
    /// - Now also have a handler that can be provided to this, which overrides this default
    ///     It should provide the current zoom scale and
    ///     Get back an enum called ZoomPosition as a result
    ///         This can be either fullScale, maxScale, or rect(let CGRect) where we provide a rect
    ///         The scrollview than either zooms to full, max or the provided rect
    /// - Now have TextPicker use this to
    ///     See if the zoomScale is above or below the selected bound's scale
    ///         This can be determined by dividing the rects dimensions by the image's and returning the larger? amount
    ///     If it's greater than the selectedBoundZoomScale:
    ///         If the selectedBoundZoomScale is less than the constant MaxScale of ZoomScrollView
    ///         (by at least a minimum distance—also set by ZoomedScrollView)
    ///             Then we return MaxScale as the ZoomPosition
    ///         Else we return FullScale as the ZoomPosition (scale = 1)
    ///     Else we return rect(selectedBound) as the ZoomPosition
    func handleDoubleTap(on point: CGPoint, for scrollView: UIScrollView) {
        let maxZoomScale = 3.5
        let minDelta = 0.5

        if let zoomBox = zoomBox?.wrappedValue,
           zoomBox.boundingBox != .zero
        {
            let boundingBoxScale = zoomScaleOfBoundingBox(zoomBox.boundingBox,
                                                          forImageSize: zoomBox.imageSize,
                                                          padded: zoomBox.padded,
                                                          scrollView: scrollView)
            if scrollView.zoomScale < boundingBoxScale {
                scrollView.focus(on: zoomBox)
            } else {
                scrollView.setZoomScale(1, animated: true)
//                scrollView.zoomToScale(1, on: point)
            }
        } else {
            if scrollView.zoomScale < (maxZoomScale - minDelta) {
                let newScale = maxZoomScale
                scrollView.zoomToScale(newScale, on: point)
            } else {
                scrollView.setZoomScale(1, animated: true)
//                newScale = 1
            }
//            scrollView.zoomToScale(newScale, on: point)
        }
    }

    func zoomRectForDoubleTap(on point: CGPoint, for scrollView: UIScrollView) -> CGRect {
        return scrollView.zoomRect(forFactorChangeInZoomScaleOf: 5, on: point)
    }
    
    func zoomRectForDoubleTap_legacy(on point: CGPoint, for scrollView: UIScrollView) -> CGRect {
        let sizeToBaseRectOn = scrollView.frame.size
        
        let size = CGSize(width: sizeToBaseRectOn.width / 2,
                          height: sizeToBaseRectOn.height / 2)
        let zoomSize = CGSize(width: size.width / scrollView.zoomScale,
                              height: size.height / scrollView.zoomScale)
        
        let origin = CGPoint(x: point.x - zoomSize.width / 2,
                             y: point.y - zoomSize.height / 2)
        return CGRect(origin: origin, size: zoomSize)
    }
    
    func zoomScaleOfBoundingBox(_ boundingBox: CGRect, forImageSize imageSize: CGSize, padded: Bool, scrollView: UIScrollView) -> CGFloat {
        let zoomRect = boundingBox.zoomRect(forImageSize: imageSize,
                                            fittedInto: scrollView.frame.size,
                                            padded: padded)
        return zoomRect.zoomScale(within: scrollView.frame.size)
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint, scrollView: UIScrollView, context: Context) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = hostedView(context: context).frame.size.height / scale
        zoomRect.size.width  = hostedView(context: context).frame.size.width  / scale
        let newCenter = scrollView.convert(center, from: hostedView(context: context))
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    //    func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
    //        if (zoomScale > minimumZoomScale) {
    //            setZoomScale(minimumZoomScale, animated: true)
    //        }
    //        else {
    //            //(I divide by 3.0 since I don't wan't to zoom to the max upon the double tap)
    //            let zoomRect = zoomRectForScale(scale: maximumZoomScale / 3.0, center: recognizer.location(in: recognizer.view))
    //            zoom(to: zoomRect, animated: true)
    //        }
    //    }
    //
    //    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
    //        var zoomRect = CGRect.zero
    //        if let imageV = self.viewForZooming {
    //            zoomRect.size.height = imageV.frame.size.height / scale;
    //            zoomRect.size.width  = imageV.frame.size.width  / scale;
    //            let newCenter = imageV.convert(center, from: self)
    //            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
    //            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
    //        }
    //        return zoomRect;
    //    }
}
