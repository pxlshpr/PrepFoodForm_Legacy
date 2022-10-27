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
//    @Published var focusedBoxes: [FocusedBox?]
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
//        focusedBoxes = Array(repeating: nil, count: imageViewModels.count)
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
    
//    func removeFocusedBoxAfterDelay(forImageAt index: Int) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) {
//            self.focusedBoxes[index] = nil
//        }
//    }
    
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
        
//        for i in imageViewModels.indices {
//            setDefaultZoomBox(forImageAt: i)
//        }
    }
    
    func pageDidChange(to index: Int) {
        /// Now reset the focus box for all the other images
        for i in imageViewModels.indices {
            guard i != index else { continue }
            setDefaultZoomBox(forImageAt: i)
        }
    }
    
    func boundingBox(forImageAt index: Int) -> CGRect {
        if mode.isColumnSelection {
            return mode.boundingBox(forImageWithId: imageViewModels[index].id) ?? .zero
        } else {
            return selectedBoundingBox(forImageAt: index) ?? imageViewModels[index].relevantBoundingBox
//            return selectedBoundingBox(forImageAt: index) ?? .zero
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
//                .edgesIgnoringSafeArea(.all)
            buttonsLayer
        }
        .onAppear(perform: appeared)
        .onChange(of: textPickerViewModel.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .bottomMenu(isPresented: $textPickerViewModel.showingMenu, menu: bottomMenu)
        .bottomMenu(isPresented: $textPickerViewModel.showingAutoFillConfirmation,
                    menu: confirmAutoFillMenu)
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
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = textPickerViewModel.imageViewModels.firstIndex(of: imageViewModel),
           index < textPickerViewModel.zoomBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(
                id: textPickerViewModel.imageViewModels[index].id,
                zoomBox: $textPickerViewModel.zoomBoxes[index],
                backgroundColor: .black
            ) {
                imageView(image)
                    .overlay(textBoxesLayer(for: imageViewModel))
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

    func selectedTextButton(for column: TextColumn) -> some View {
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
                    DispatchQueue.main.async {
                        dismiss()
                    }
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
            .buttonStyle(.borderless)
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
            Haptics.feedback(style: .soft)
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
    
    var confirmAutoFillMenu: BottomMenu {
        let group = BottomMenuActionGroup(actions: [
            BottomMenuAction(
                title: "This will replace any existing data."
            ),
            BottomMenuAction(
                title: "AutoFill",
                tapHandler: {
                    textPickerViewModel.tappedConfirmAutoFill()
                }
            )
        ])
        return BottomMenu(group: group)
    }
    
    var autoFillLinkAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            linkedMenu: confirmAutoFillMenu
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
    
    var firstMenuGroup: BottomMenuActionGroup {
        let actions: [BottomMenuAction]
        if let autoFillAction {
            actions = [autoFillAction, showHideAction]
        } else {
            actions = [showHideAction]
        }
        return BottomMenuActionGroup(actions: actions)
    }
    
    var confirmDeleteMenu: BottomMenu {
        let title = BottomMenuAction(
            title: "This photo will be deleted while the data you filled from it will remain."
        )
        let deleteAction = BottomMenuAction(
            title: "Delete Photo",
            role: .destructive,
            tapHandler: {
                textPickerViewModel.deleteCurrentImage()
            })
        return BottomMenu(actions: [title, deleteAction])
    }
    
    var deletePhotoAction: BottomMenuAction {
        BottomMenuAction(
            title: "Delete Photo",
            systemImage: "trash",
            role: .destructive,
            linkedMenu: confirmDeleteMenu
        )
    }
    
    var bottomMenu: BottomMenu {
        BottomMenu(groups: [
            firstMenuGroup,
            BottomMenuActionGroup(action: deletePhotoAction)]
        )
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
//                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                                        .foregroundColor(.accentColor)
//                                        .padding(-0.5)
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
            Haptics.feedback(style: .soft)
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
