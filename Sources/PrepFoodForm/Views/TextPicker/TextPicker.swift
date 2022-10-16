import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @State var imageViewModels: [ImageViewModel]
    @State var selectedImageTexts: [ImageText] = []
    
    @State var page: Page = .first()
//    @State var texts: [RecognizedText]

    @State var focusedBoxes: [FocusedBox?] = []
    @State var didSendAnimatedFocusMessage: [Bool] = []

    @State var currentIndex: Int = 0

    @State var hasAppeared: Bool = false
    
    @State var showingBoxes: Bool

//    @State var selectedBoundingBox: CGRect? = nil

    let allowsMultipleSelection: Bool
    let onlyShowTextsWithValues: Bool
    let selectedText: RecognizedText?
    let selectedImageIndex: Int?
    let selectedAttributeText: RecognizedText?
    let didSelectImageTexts: (([ImageText]) -> Void)?
    
    let customTextFilter: ((RecognizedText) -> Bool)?
    
    init(
        imageViewModels: [ImageViewModel],
        allowsMultipleSelection: Bool = false,
        selectedText: RecognizedText? = nil,
        selectedAttributeText: RecognizedText? = nil,
        selectedImageIndex: Int? = nil,
        onlyShowTextsWithValues: Bool = false,
        customTextFilter: ((RecognizedText) -> Bool)? = nil,
        didSelectImageTexts: (([ImageText]) -> Void)? = nil
    ) {
        _imageViewModels = State(initialValue: imageViewModels)
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onlyShowTextsWithValues = onlyShowTextsWithValues
        self.customTextFilter = customTextFilter
        self.selectedText = selectedText
        self.selectedAttributeText = selectedAttributeText
        self.selectedImageIndex = selectedImageIndex
        self.didSelectImageTexts = didSelectImageTexts
        _showingBoxes = State(initialValue: didSelectImageTexts == nil ? false : true)
        _focusedBoxes = State(initialValue: Array(repeating: nil, count: imageViewModels.count))
        _didSendAnimatedFocusMessage = State(initialValue: Array(repeating: false, count: imageViewModels.count))
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
    
    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .padding(15)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                )
                .clipShape(Circle())
                .padding(.horizontal, 15)
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
                .imageScale(.large)
                .padding(40)
                .frame(height: 55)
//                .background(.green)
                .contentShape(Rectangle())
        }
    }
    var buttonsLayer: some View {
        VStack {
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
            Spacer()
            ZStack {
                Color.clear
                HStack {
                    HStack(spacing: 5) {
                        ForEach(imageViewModels.indices, id: \.self) { index in
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
    }
    
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            currentIndex == index
        }
        
        return Group {
            if let image = imageViewModels[index].smallThumbnail {
                Button {
                    didTapThumbnail(at: index)
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
    
    var pagerLayer: some View {
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
        if let index = imageViewModels.firstIndex(of: imageViewModel),
           index < focusedBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(focusedBox: $focusedBoxes[index]) {
                imageView(image)
                    .overlay(
                        TextBoxesLayer(textBoxes: textBoxes(for: imageViewModel))
//                        boxesLayer(for: imageViewModel)
                    )
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
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .opacity(0.7)
    }
    
    //MARK: - Actions
    
    func appeared() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                hasAppeared = true
            }
//            if let selectedImageIndex {
//                pageToImage(at: selectedImageIndex)
//            }
//
            
            sendFocusMessage(to: selectedImageIndex ?? 0, animated: false)
        }
    }
    
    //MARK: - User Actions
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
    
    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        if text == selectedText {
            return {
                
            }
        } else {
            return nil
        }
    }
    
    //MARK: - Internal Actions
    
    func pageToImage(at index: Int) {
        let increment = index - currentIndex
        withAnimation {
            page.update(.move(increment: increment))
        }
        currentIndex = index
        
        /// Reset the focusedAreas of the other images (after waiting for half a second for the paging animation to complete)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.1)) {
                focusedBoxes[index] = nil
            }
        }
    }
    
    //MARK: - Events
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
    
    
    //MARK: - Helpers
    var selectedBoundingBox: CGRect? {
        guard let selectedAttributeText, let selectedText, let selectedImageIndex else {
            return selectedText?.boundingBox
        }
        let union = selectedAttributeText.boundingBox.union(selectedText.boundingBox)
        let ivm = imageViewModels[selectedImageIndex]

        let texts: [RecognizedText]
        if let customTextFilter {
            texts = ivm.texts.filter(customTextFilter)
        } else {
            texts = onlyShowTextsWithValues ? ivm.textsWithValues : ivm.texts
        }

        /// Only show the union of the attribute and selected texts if the union of them both does not entirely cover any other texts we will be displaying.
        //TODO: This can slow stuff down tremendously—revisit this
        if !texts.contains(where: { union.contains($0.boundingBox )}) {
            return union
        } else {
            return selectedText.boundingBox
        }
    }
    
    func texts(for imageViewModel: ImageViewModel) -> [RecognizedText] {
        if let customTextFilter {
            return imageViewModel.texts.filter(customTextFilter)
        } else {
            return onlyShowTextsWithValues ? imageViewModel.textsWithValues : imageViewModel.texts
        }
    }
    
    func color(for text: RecognizedText) -> Color {
        if text == selectedText || selectedImageTexts.contains(where: { $0.text == text }) {
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
                    TextBoxView(textBox: textBoxes[i], size: geometry.size)
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
    }
    
}

//MARK: - Preview

public struct TextPickerPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    //    @State var fieldValue: FieldValue
    @State var selectedText: RecognizedText

    public init() {
//        let viewModel = FoodFormViewModel.mock(for: .phillyCheese)
        let viewModel = FoodFormViewModel.mockWith5Images
        _viewModel = StateObject(wrappedValue: viewModel)

//        let fieldValue = FieldValue.energy()
//        _fieldValue = State(initialValue: fieldValue)
//
        let text = viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "57710D30-C601-4F36-8A10-62C8C2674702")!})!
        _selectedText = State(initialValue: text)
    }
    
    public var body: some View {
        NavigationView {
            Text("")
                .sheet(isPresented: .constant(true)) {
                    TextPicker(
                        imageViewModels: viewModel.imageViewModels
                        , selectedText: selectedText
                        , selectedImageIndex: 0
                    )
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

