import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView

class TextPickerViewModel: ObservableObject {
    
    /// ViewModel stuff
    @Published var imageViewModels: [ImageViewModel]
    @Published var showingBoxes: Bool
    @Published var selectedImageTexts: [ImageText]
    @Published var focusedBoxes: [FocusedBox?]
    @Published var zoomBoxes: [FocusedBox?]
    @Published var page: Page
    
    @Published var currentIndex: Int = 0
    @Published var hasAppeared: Bool = false
    @Published var shouldDismiss: Bool = false
    @Published var selectedColumn = 1
    
    let initialImageIndex: Int
    let mode: TextPickerMode
    
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
    
    func setInitialFocusBox(forImageAt index: Int) {
        /// Make sure we're not already focused on an area of this image
//        let index = initialImageIndex
        guard let imageSize = imageSize(at: index), focusedBoxes[index] == nil else {
            return
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.0)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            let boundingBox = self.selectedBoundingBox(forImageAt: index) ?? self.imageViewModels[index].relevantBoundingBox
            
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
    
    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        guard let currentScanResultId, mode.supportsTextSelection else {
            return nil
        }
        
        let imageText = ImageText(text: text, imageId: currentScanResultId)

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
    
    func tappedDone() {
        guard let multiSelectionHandler = mode.multiSelectionHandler else {
            return
        }
        multiSelectionHandler(selectedImageTexts)
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
        imageViewModel.barcodeTexts
    }
    
    func texts(for imageViewModel: ImageViewModel) -> [RecognizedText] {
        
        let filter: TextPickerFilter
        if mode.isColumnSelection {
            filter = selectedColumn == 1 ? .textsInColumn1 : .textsInColumn2
        } else {
            filter = mode.filter ?? .allTextsAndBarcodes
        }
        
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
            return Color.yellow
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
    
    var currentScanResultId: UUID? {
        imageViewModels[currentIndex].scanResult?.id
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

    var shouldShowActionsBar: Bool {
        shouldShowActions || imageViewModels.count > 1
    }

    var shouldShowSelectedTextsBar: Bool {
        mode.isMultiSelection
//        allowsMultipleSelection
    }
    
    var shouldShowBottomBar: Bool {
        shouldShowActionsBar || shouldShowSelectedTextsBar
    }
    
    var shouldShowMenuInTopBar: Bool {
        shouldShowActions
//        imageViewModels.count == 1 && shouldShowActions && allowsMultipleSelection == false
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
                }
                Spacer()
            }
            HStack {
                Spacer()
                if textPickerViewModel.shouldShowMenuInTopBar {
                    topMenuButton
                } else {
                    doneButton
                }
            }
        }
    }
    
    var bottomBar: some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                if textPickerViewModel.shouldShowSelectedTextsBar {
                    selectedTextsBar
                }
                if textPickerViewModel.shouldShowActionsBar {
                    actionBar
                }
            }
        }
        .frame(height: bottomBarHeight)
        .background(.ultraThinMaterial)
    }
    
    var bottomBarHeight: CGFloat {
        var height: CGFloat = 0
        if textPickerViewModel.shouldShowActionsBar {
            height += actionBarHeight
        }
        if textPickerViewModel.shouldShowSelectedTextsBar {
            height += selectedTextsBarHeight
        }
        return height
    }
    
    var actionBarHeight: CGFloat {
        70
    }
    
    var selectedTextsBarHeight: CGFloat {
        textPickerViewModel.shouldShowActions ? 60 : 60
    }
    
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
                    Text(imageText.text.string.capitalized)
                        .font(.title3)
                        .bold()
                    //                        .foregroundColor(.primary)
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
        if textPickerViewModel.mode.isMultiSelection {
            Button {
                Haptics.successFeedback()
                textPickerViewModel.tappedDone()
                dismiss()
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
        }
    }
    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
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
        Menu {
            menuContents
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
    
    var menuContents: some View {
        Group {
            if textPickerViewModel.mode.isImageViewer {
                Button {
                    withAnimation {
                        textPickerViewModel.showingBoxes.toggle()
                    }
                } label: {
                    Label("\(textPickerViewModel.showingBoxes ? "Hide" : "Show") Texts", systemImage: "text.viewfinder")
                }
                Button(role: .destructive) {
                    textPickerViewModel.deleteCurrentImage()
                } label: {
                    Label("Remove Photo", systemImage: "trash")
                }
            }
        }
    }
    
    var menuButton: some View {
        Menu {
            menuContents
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.primary)
                .imageScale(.large)
                .padding(40)
                .frame(height: 55)
            //                .background(.green)
                .contentShape(Rectangle())
        }
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
