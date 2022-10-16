import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView

extension ImageText {
    var boundingBoxWithAttribute: CGRect {
        guard let attributeText else { return text.boundingBox }
        return attributeText.boundingBox.union(text.boundingBox)
    }
    
    var boundingBox: CGRect {
        text.boundingBox
    }
}

class TextPickerConfiguration: ObservableObject {
    
    @Published var imageViewModels: [ImageViewModel]
    @Published var selectedImageTexts: [ImageText]
    
    @Published var showingBoxes: Bool
    @Published var focusedBoxes: [FocusedBox?]
    @Published var didSendAnimatedFocusMessage: [Bool]
    @Published var currentIndex: Int = 0
    @Published var hasAppeared: Bool = false
    @Published var page: Page
    
    @Published var isPaging: Bool = false
    
    let initialImageIndex: Int
    let allowsMultipleSelection: Bool
    let onlyShowTextsWithValues: Bool
    let didSelectImageTexts: (([ImageText]) -> Void)?
    let customTextFilter: ((RecognizedText) -> Bool)?
    let allowsTogglingTexts: Bool
    let deleteImageHandler: ((Int) -> ())?
    
    init(imageViewModels: [ImageViewModel],
         selectedImageTexts: [ImageText] = [],
         initialImageIndex: Int? = nil,
         allowsMultipleSelection: Bool = false,
         onlyShowTextsWithValues: Bool = false,
         allowsTogglingTexts: Bool = false,
         deleteImageHandler: ((Int) -> ())? = nil,
         didSelectImageTexts: (([ImageText]) -> Void)? = nil,
         customTextFilter: ((RecognizedText) -> Bool)? = nil)
    {
        self.imageViewModels = imageViewModels
        self.selectedImageTexts = selectedImageTexts
        self.allowsMultipleSelection = allowsMultipleSelection
        self.allowsTogglingTexts = allowsTogglingTexts
        self.deleteImageHandler = deleteImageHandler
        self.onlyShowTextsWithValues = onlyShowTextsWithValues
        self.didSelectImageTexts = didSelectImageTexts
        self.customTextFilter = customTextFilter
        
        showingBoxes = didSelectImageTexts == nil ? false : true
        focusedBoxes = Array(repeating: nil, count: imageViewModels.count)
        didSendAnimatedFocusMessage = Array(repeating: false, count: imageViewModels.count)
        
        if let initialImageIndex {
            self.initialImageIndex = initialImageIndex
        } else if let imageText = selectedImageTexts.first {
            self.initialImageIndex = imageViewModels.firstIndex(where: { $0.id == imageText.imageId }) ?? 0
        } else {
            self.initialImageIndex = 0
        }
        
        page = .withIndex(self.initialImageIndex)
    }
    
    func setInitialState() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.hasAppeared = true
            }
//        }
        setInitialFocusBox()
    }
    
    var singleSelectedImageText: ImageText? {
        guard selectedImageTexts.count == 1 else {
            return nil
        }
        return selectedImageTexts.first
    }
    
    var selectedBoundingBox: CGRect? {
        guard let singleSelectedImageText else {
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
    
    func setInitialFocusBox() {
        /// Make sure we're not already focused on an area of this image
        let index = initialImageIndex
        let animated = false
        
        guard let imageSize = imageSize(at: index), focusedBoxes[index] == nil else {
            return
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.0)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            if animated {
                self.didSendAnimatedFocusMessage[index] = true
            }
            
            let boundingBox: CGRect
            let paddingType: ZoomPaddingType
            if let selectedBoundingBox = self.selectedBoundingBox {
                boundingBox = selectedBoundingBox
                paddingType = .smallElement
            } else {
                boundingBox = self.imageViewModels[index].relevantBoundingBox
                paddingType = .largeSection
            }
            
            self.focusedBoxes[index] = FocusedBox(
                boundingBox: boundingBox,
                animated: animated,
                paddingType: paddingType,
                imageSize: imageSize
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.1)) {
                self.focusedBoxes[index] = nil
            }
        }
    }
    
    func textBoxes(for imageViewModel: ImageViewModel) -> [TextBox] {
        let texts = texts(for: imageViewModel)
        return texts.map {
            TextBox(
                boundingBox: $0.boundingBox,
                color: color(for: $0),
                tapHandler: tapHandler(for: $0)
            )
        }
    }
    
    func didTapThumbnail(at index: Int) {
        Haptics.feedback(style: .rigid)
        pageToImage(at: index)
        
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
    
    func pageToImage(at index: Int) {
//        withAnimation {
//            isPaging = true
//        }
        
        let increment = index - currentIndex
        withAnimation {
            page.update(.move(increment: increment))
        }
        currentIndex = index
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            withAnimation {
//                self.isPaging = false
//            }
//        }
        
        /// Reset the focusedAreas of the other images (after waiting for half a second for the paging animation to complete)
    }
    
    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        nil
//        if text == selectedText {
//            return {
//
//            }
//        } else {
//            return nil
//        }
    }
    
    func texts(for imageViewModel: ImageViewModel) -> [RecognizedText] {
        if let customTextFilter {
            return imageViewModel.texts.filter(customTextFilter)
        } else {
            return onlyShowTextsWithValues ? imageViewModel.textsWithValues : imageViewModel.texts
        }
    }
    
    func color(for text: RecognizedText) -> Color {
        if selectedImageTexts.contains(where: { $0.text == text }) {
            return Color.green
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
    
    var shouldShowBottomBar: Bool {
        allowsTogglingTexts
        || deleteImageHandler != nil
        || imageViewModels.count > 1
    }
}

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var config: TextPickerConfiguration
    
    init(config: TextPickerConfiguration) {
        _config = StateObject(wrappedValue: config)
    }
    
    //MARK: - Views
    
    var body: some View {
        //        NavigationView {
        ZStack {
            pagerLayer
                .edgesIgnoringSafeArea(.all)
            buttonsLayer
         }
        //                .navigationTitle(title)
        //                .navigationBarTitleDisplayMode(.inline)
        //                .toolbar { bottomToolbar }
        //                .toolbar(.visible, for: .bottomBar)
        //                .toolbarBackground(.visible, for: .bottomBar)
        //                .toolbar { navigationLeadingContents }
        //                .toolbar { navigationTrailingContents }
        //        }
        .onAppear(perform: appeared)
    }
    
    //MARK:  Pager Layer
    
    var pagerLayer: some View {
        Pager(
            page: config.page,
            data: config.imageViewModels,
            id: \.hashValue,
            content: { imageViewModel in
            zoomableScrollView(for: imageViewModel)
                    .background(.black)
        })
        .sensitivity(.high)
        .pagingPriority(.high)
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = config.imageViewModels.firstIndex(of: imageViewModel),
           index < config.focusedBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(focusedBox: $config.focusedBoxes[index], backgroundColor: .black) {
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
//        if config.hasAppeared {
            TextBoxesLayer(textBoxes: config.textBoxes(for: imageViewModel))
                .opacity(config.hasAppeared ? 1 : 0)
                .animation(.default, value: config.hasAppeared)
//        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.black)
            .opacity(0.7)
    }
    
    //MARK: ButtonsLayer
    
    var buttonsLayer: some View {
        VStack {
            topBar
            Spacer()
            if config.shouldShowBottomBar {
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
                titleView
                Spacer()
            }
        }
    }
    
    var bottomBar: some View {
        ZStack {
            Color.clear
            HStack {
                HStack(spacing: 5) {
                    ForEach(config.imageViewModels.indices, id: \.self) { index in
                        thumbnail(at: index)
                    }
                }
                .padding(.leading, 40)
                .padding(.top, 15)
                Spacer()
                menuButton
                    .padding(.top, 15)
            }
        }
        .frame(height: 70)
        .background(.ultraThinMaterial)
    }

    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .padding(15)
                .foregroundColor(.primary)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                )
                .clipShape(Circle())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
    }
    
    var titleView: some View {
        Text("Select a text")
            .font(.title3)
            .bold()
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
    }
    
    var menuButton: some View {
        Menu {
            Button {
                
            } label: {
                Label("Show Texts", systemImage: "text.viewfinder")
            }
            Divider()
            Button(role: .destructive) {
                
            } label: {
                Label("Remove Photo", systemImage: "trash")
            }
            Button(role: .destructive) {
                
            } label: {
                Label("Remove All Photos", systemImage: "trash")
            }
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
            config.currentIndex == index
        }
        
        return Group {
            if let image = config.imageViewModels[index].smallThumbnail {
                Button {
                    config.didTapThumbnail(at: index)
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
            config.setInitialState()
        }
    }
    
    //MARK: - User Actions
    func toggleSelection(of imageText: ImageText) {
        if config.selectedImageTexts.contains(imageText) {
            Haptics.feedback(style: .light)
            withAnimation {
                config.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } else {
            Haptics.transientHaptic()
            withAnimation {
                config.selectedImageTexts.append(imageText)
            }
        }
    }
    
    //MARK: - Events
    func pageWillChange(to pageIndex: Int) {
        print("pageWillChange to \(pageIndex)")
        //        withAnimation {
        //            selectedViewModelIndex = pageIndex
        //        }
        //        zoomIfApplicable()
    }
    
    func pageChanged(to pageIndex: Int) {
        print("pageChanged to \(pageIndex)")
        //        withAnimation {
        //            selectedViewModelIndex = pageIndex
        //        }
        //        zoomIfApplicable()
    }
    
    
    //MARK: - Helpers
    
    let texts = [
        "Here", "are", "some test", "strings to work on"
    ]
}

//MARK: - TextBox
struct TextBox {
    var boundingBox: CGRect
    var color: Color
    var tapHandler: (() -> ())?
}

//MARK: - TextBoxLayer

struct TextBoxesLayer: View {
    
    let textBoxes: [TextBox]
    
    var body: some View {
        boxesLayer
    }
    
    var boxesLayer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(textBoxes.indices, id: \.self) { i in
                    TextBoxView(textBox: textBoxes[i],
                                size: geometry.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

//MARK: - TextBoxView

struct TextBoxView: View {
    
    let textBox: TextBox
    let size: CGSize
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let tapHandler = textBox.tapHandler {
                    button(tapHandler)
                } else {
                    box
                }
                Spacer()
            }
            Spacer()
        }
        .offset(x: rect.minX, y: rect.minY)
    }
    
    var rect: CGRect {
        textBox.boundingBox.rectForSize(size)
    }
    
    func button(_ didTap: @escaping () -> ()) -> some View {
        Button {
            Haptics.feedback(style: .rigid)
            didTap()
        } label: {
            box
        }
    }
    
    var box: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(textBox.color)
            .opacity(0.3)
            .frame(width: rect.width,
                   height: rect.height)
        
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(textBox.color, lineWidth: 1)
                    .opacity(0.8)
            )
            .shadow(radius: 3, x: 0, y: 2)
//            .opacity(isPaging ? 0 : 1)
//            .animation(.default, value: isPaging)
    }
}

//MARK: - Preview

public struct TextPickerPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    //    @State var fieldValue: FieldValue
    @State var selectedImageText: ImageText
    
    public init() {
        //        let viewModel = FoodFormViewModel.mock(for: .phillyCheese)
        let viewModel = FoodFormViewModel.mockWith5Images
        _viewModel = StateObject(wrappedValue: viewModel)
        
        //        let fieldValue = FieldValue.energy()
        //        _fieldValue = State(initialValue: fieldValue)
        //
        let text = viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "57710D30-C601-4F36-8A10-62C8C2674702")!})!
        _selectedImageText = State(initialValue: ImageText(
            text: text,
            imageId: viewModel.imageViewModels.first!.id)
        )
    }
    
    public var body: some View {
        NavigationView {
            Text("")
                .fullScreenCover(isPresented: .constant(true)) {
                    TextPicker(config: textPickerConfig)
                }
                .navigationTitle("Text Picker")
        }
    }
    
    var textPickerConfig: TextPickerConfiguration {
        TextPickerConfiguration(
            imageViewModels: viewModel.imageViewModels,
            selectedImageTexts: [selectedImageText]
        )
    }
    
}

struct TextPicker_Previews: PreviewProvider {
    static var previews: some View {
        TextPickerPreview()
    }
}
