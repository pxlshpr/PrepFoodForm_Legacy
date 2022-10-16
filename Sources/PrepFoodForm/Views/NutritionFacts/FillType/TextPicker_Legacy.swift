import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView

struct TextPicker_Legacy: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FoodFormViewModel
    
//    var imageViewModels: [ImageViewModel]
//
    @State var selectedImageTexts: [ImageText] = []
    
    @State var page: Page = .first()
//    @State var texts: [RecognizedText]

    @State var focusedBoxes: [FocusedBox?] = []
    @State var didSendAnimatedFocusMessage: [Bool] = []

    @State var currentIndex: Int = 0

    @State var hasAppeared: Bool = false
    
    @State var showingBoxes: Bool
    
    let allowsMultipleSelection: Bool
    let onlyShowTextsWithValues: Bool
    let selectedText: RecognizedText?
    let selectedImageIndex: Int?
    let selectedAttributeText: RecognizedText?
    private let selectedBoundingBox: CGRect?
    let didSelectImageTexts: (([ImageText]) -> Void)?
    
    let customTextFilter: ((RecognizedText) -> Bool)?
    
    init(
        viewModel: FoodFormViewModel,
//        imageViewModels: [ImageViewModel],
        allowsMultipleSelection: Bool = false,
        selectedText: RecognizedText? = nil,
        selectedAttributeText: RecognizedText? = nil,
        selectedImageIndex: Int? = nil,
        onlyShowTextsWithValues: Bool = false,
        customTextFilter: ((RecognizedText) -> Bool)? = nil,
        didSelectImageTexts: (([ImageText]) -> Void)? = nil
    ) {
        self.viewModel = viewModel
//        self.imageViewModels = imageViewModels
        self.allowsMultipleSelection = allowsMultipleSelection
        _focusedBoxes = State(initialValue: Array(repeating: nil, count: viewModel.imageViewModels.count))
        _didSendAnimatedFocusMessage = State(initialValue: Array(repeating: false, count: viewModel.imageViewModels.count))
        self.onlyShowTextsWithValues = onlyShowTextsWithValues
        self.customTextFilter = customTextFilter
        self.selectedText = selectedText
        self.selectedAttributeText = selectedAttributeText
        self.selectedImageIndex = selectedImageIndex
        
        _showingBoxes = State(initialValue: didSelectImageTexts == nil ? false : true)
        //TODO: Move all these computationally intensive stuff elsewhere
        if let selectedAttributeText, let selectedText, let selectedImageIndex {
            let union = selectedAttributeText.boundingBox.union(selectedText.boundingBox)
            let ivm = viewModel.imageViewModels[selectedImageIndex]
            
            let texts: [RecognizedText]
            if let customTextFilter {
                texts = ivm.texts.filter(customTextFilter)
            } else {
                texts = onlyShowTextsWithValues ? ivm.textsWithValues : ivm.texts
            }
            

            /// Only show the union of the attribute and selected texts if the union of them both does not entirely cover any other texts we will be displaying.
            if !texts.contains(where: { union.contains($0.boundingBox )}) {
                self.selectedBoundingBox = union
            } else {
                self.selectedBoundingBox = selectedText.boundingBox
            }
        } else {
            self.selectedBoundingBox = selectedText?.boundingBox
        }
        self.didSelectImageTexts = didSelectImageTexts
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { bottomToolbar }
                .toolbar(.visible, for: .bottomBar)
                .toolbarBackground(.visible, for: .bottomBar)
                .toolbar { navigationLeadingContents }
                .toolbar { navigationTrailingContents }
        }
        .onAppear(perform: appeared)
    }
    
    var navigationLeadingContents: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Done") {
                if let didSelectImageTexts {
                    didSelectImageTexts(selectedImageTexts)
                    Haptics.successFeedback()
                }
                dismiss()
            }
            if mode == .viewing {
                Button {
                    withAnimation {
                        showingBoxes.toggle()
                    }
                } label: {
                    Image(systemName: "text.viewfinder")
                        .foregroundColor(showingBoxes ? .accentColor : .secondary)
                }
            }
        }
    }
    
    var title: String {
        switch mode {
        case .picking:
            return allowsMultipleSelection ? "Select texts" : "Select a text"
        case .viewing:
            return "Source Images"
        }
    }
    
    var navigationTrailingContents: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if mode == .viewing {
                Button {
                    viewModel.removeImage(at: currentIndex)
                    currentIndex -= 1
                    Haptics.successFeedback()
                    if viewModel.imageViewModels.isEmpty {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if hasAppeared {
            ZStack {
                pager
                if allowsMultipleSelection {
                    selectedTextsLayer
                }
            }
            .transition(.opacity)
        }
    }
    
    let texts = [
        "Here", "are", "some test", "strings to work on"
    ]
    var selectedTextsLayer: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(selectedImageTexts, id: \.self) { imageText in
                        selectedTextButton(for: imageText)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                .thickMaterial
            )
//            .cornerRadius(15)
//            .padding(.horizontal)
//            .padding(.bottom)
        }
    }
    
    func selectedTextButton(for imageText: ImageText) -> some View {
        Button {
            withAnimation {
                selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
                HStack(spacing: 5) {
                    Text(imageText.text.string)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
            .transition(.move(edge: .leading))
        }
    }
    
    var bottomToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            HStack {
                ForEach(imageViewModels.indices, id: \.self) { index in
                    thumbnail(at: index)
                }
            }
//            .frame(width: .infinity)
            Spacer()
        }
    }
    
    var imageViewModels: [ImageViewModel] {
        viewModel.imageViewModels
    }

    //MARK: Pager
    var pager: some View {
        Pager(page: page,
              data: imageViewModels,
              id: \.hashValue,
              content: { imageViewModel in
            zoomableScrollView(for: imageViewModel)
        })
        .sensitivity(.high)
        .pagingPriority(.high)
//        .interactive(scale: 0.7)
//        .interactive(opacity: 0.99)
//        .onPageWillChange(pageWillChange(to:))
        .onPageChanged(pageChanged(to:))
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = imageViewModels.firstIndex(of: imageViewModel) {
            ZoomableScrollView(focusedBox: $focusedBoxes[index]) {
                imageView(for: imageViewModel)
            }
        }
    }
    
    //MARK: Thumbnail
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            currentIndex == index
        }
        
        return Group {
            if let image = imageViewModels[index].image {
                Button {
                    didTapThumbnail(at: index)
                } label: {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.accentColor, lineWidth: 3)
                                .opacity(isSelected ? 1.0 : 0.0)
                        )
                }
            }
        }
    }

    //MARK: - Boxes
    
    func texts(at index: Int) -> [RecognizedText] {
        texts(for: imageViewModels[index])
    }
    
    func texts(for imageViewModel: ImageViewModel) -> [RecognizedText] {
        if let customTextFilter {
            return imageViewModel.texts.filter(customTextFilter)
        } else {
            return onlyShowTextsWithValues ? imageViewModel.textsWithValues : imageViewModel.texts
        }
    }
    
    @ViewBuilder
    func boxesLayer(for imageViewModel: ImageViewModel) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                boxLayerForSelectedText(inSize: geometry.size, for: imageViewModel)
                ForEach(texts(for: imageViewModel), id: \.self) { text in
                    if selectedText?.id != text.id {
                        boxLayer(for: text, inSize: geometry.size)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func color(for text: RecognizedText) -> Color {
        selectedImageTexts.contains(where: { $0.text == text }) ? Color.blue : Color.primary
    }
    
    @ViewBuilder
    func boxLayerForSelectedText(inSize size: CGSize, for imageViewModel: ImageViewModel) -> some View {
        if let selectedBoundingBox,
           let imageViewIndex = imageViewModels.firstIndex(of: imageViewModel),
           let selectedImageIndex,
           selectedImageIndex == imageViewIndex
        {
            boxLayer(boundingBox: selectedBoundingBox, inSize: size, color: .accentColor) {
                dismiss()
            }
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
    
    func boxLayer(for text: RecognizedText, inSize size: CGSize) -> some View {
        boxLayer(boundingBox: text.boundingBox, inSize: size, color: color(for: text)) {
            guard let currentScanResultId else {
                return
            }
            let imageText = ImageText(text: text, imageId: currentScanResultId)
            
            if allowsMultipleSelection {
                toggleSelection(of: imageText)
            } else {
                if let didSelectImageTexts {
                    didSelectImageTexts([imageText])
                }
                dismiss()
            }
        }
    }
    
    func boxLayer(boundingBox: CGRect, inSize size: CGSize, color: Color, didTap: @escaping () -> ()) -> some View {
        var box: some View {
            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(
                    color.gradient.shadow(
                        .inner(color: .black, radius: 3)
                    )
                )
                .opacity(0.3)
                .frame(width: boundingBox.rectForSize(size).width,
                       height: boundingBox.rectForSize(size).height)
            
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(color, lineWidth: 1)
                        .opacity(0.8)
                )
                .shadow(radius: 3, x: 0, y: 2)
                .opacity(showingBoxes ? 1 : 0)
        }
        
        var button: some View {
            Button {
                Haptics.feedback(style: .rigid)
                didTap()
            } label: {
                box
            }
        }
        
        return HStack {
            VStack(alignment: .leading) {
                if mode == .picking {
                    button
                } else {
                    box
                }
                Spacer()
            }
            Spacer()
        }
        .offset(x: boundingBox.rectForSize(size).minX,
                y: boundingBox.rectForSize(size).minY)
    }
    
    enum Mode {
        case picking, viewing
    }
    
    var mode: Mode {
        didSelectImageTexts == nil ? .viewing : .picking
    }
    
    @ViewBuilder
    func imageView(for imageViewModel: ImageViewModel) -> some View {
        if let image = imageViewModel.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .opacity(0.7)
                .overlay {
                    boxesLayer(for: imageViewModel)
                        .transition(.opacity)
                }
        }
    }

    //MARK: - Actions
    func pageWillChange(to pageIndex: Int) {
//        withAnimation {
//            selectedViewModelIndex = pageIndex
//        }
//        zoomIfApplicable()
    }
    
    func pageChanged(to pageIndex: Int) {
//        withAnimation {
//            selectedViewModelIndex = pageIndex
//        }
//        zoomIfApplicable()
    }
    
    func pageToImage(at index: Int) {
        let increment = index - currentIndex
        withAnimation {
            page.update(.move(increment: increment))
        }
        currentIndex = index
        
        /// Reset the focusedAreas of the other images (after waiting for half a second for the paging animation to complete)
    }
    
    func didTapThumbnail(at index: Int) {
        Haptics.feedback(style: .rigid)
        pageToImage(at: index)
        
        /// wait till the page animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            /// send the focus message to this page if we haven't sent the animated one yet
            if !didSendAnimatedFocusMessage[index] {
                sendFocusMessage(to: index, animated: true)
            }
            
            /// send a (non-animated) focus message to all *other* pages that have already received an animated focus message
            for i in 0..<imageViewModels.count {
                guard i != index,
                      didSendAnimatedFocusMessage[index]
                else {
                    continue
                }
                
                sendFocusMessage(to: i, animated: false)
            }
        }
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                hasAppeared = true
            }
            if let selectedImageIndex {
                pageToImage(at: selectedImageIndex)
            }

            sendFocusMessage(to: selectedImageIndex ?? 0, animated: false)
        }
    }
    
    func sendFocusMessage(to index: Int, animated: Bool) {
        /// Make sure we're not already focused on an area of this image
        guard let imageSize = imageSize(at: index), focusedBoxes[index] == nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.0)) {
            if animated {
                didSendAnimatedFocusMessage[index] = true
            }
            
            /// If we have a pre-selected text—zoom into it
            if let selectedBoundingBox, index == selectedImageIndex {
                focusedBoxes[index] = FocusedBox(
                    boundingBox: selectedBoundingBox,
                    animated: animated,
                    imageSize: imageSize
                )
            } else {
                focusedBoxes[index] = FocusedBox(
                    boundingBox: texts(at: index).boundingBox,
                    animated: animated,
                    padded: false,
                    imageSize: imageSize
                )
            }
        }
    }
    
    var textsForCurrentImage: [RecognizedText] {
        return texts(for: imageViewModels[currentIndex])
//        if onlyShowTextsWithValues {
//            return imageViewModels[currentIndex].textsWithValues
//        } else {
//            return imageViewModels[currentIndex].texts
//        }
    }
    
    //MARK: - Helpers
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
}

//MARK: - Preview

extension FoodFormViewModel {
    
    func populateWithSampleImages(_ indexes: [Int]) {
        for index in indexes {
            populateWithSampleImage(index)
        }
    }
    
    func populateWithSampleImage(_ number: Int) {
        guard let image = sampleImage(number), let scanResult = sampleScanResult(number) else {
            fatalError("Couldn't populate sample image: \(number)")
        }
        imageViewModels.append(ImageViewModel(image: image, scanResult: scanResult))
    }
    
}

extension Array where Element == RecognizedText {
    var boundingBox: CGRect {
        guard !isEmpty else { return .zero }
        return reduce(.null) { partialResult, text in
            partialResult.union(text.boundingBox)
        }
    }
    
//    var boundingBoxUsingReduction: CGRect {
//
//    }
//
//    var boundingBoxUsingCorners: CGRect {
//
//    }
//
//    var topLeft: CGRect {
//        self.so
//    }
}
