import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var viewModel: FoodFormViewModel
    
    var imageViewModels: [ImageViewModel]
    
    @State var tappedText: RecognizedText? = nil
    
    @State var page: Page = .first()
//    @State var texts: [RecognizedText]

    @State var focusMessages: [FocusOnAreaMessage?] = []

    @State var selectedViewModelIndex: Int = 0

    let selectedBoundingBox: CGRect?
    let onlyShowTextsWithValues: Bool
    let selectedImageIndex: Int?
    let selectedText: RecognizedText?
    let didSelectRecognizedText: (RecognizedText, UUID) -> Void
    
    init(imageViewModels: [ImageViewModel],
         selectedText: RecognizedText? = nil,
         selectedImageIndex: Int? = nil,
         selectedBoundingBox: CGRect? = nil,
         onlyShowTextsWithValues: Bool = false,
         didSelectRecognizedText: @escaping (RecognizedText, UUID) -> Void
    ) {
        self.imageViewModels = imageViewModels
        _focusMessages = State(initialValue: Array(repeating: nil, count: imageViewModels.count))
        self.onlyShowTextsWithValues = onlyShowTextsWithValues
        self.selectedImageIndex = selectedImageIndex
        self.selectedText = selectedText
        if let selectedBoundingBox {
            self.selectedBoundingBox = selectedBoundingBox
        } else {
            self.selectedBoundingBox = selectedText?.boundingBox
        }
        self.didSelectRecognizedText = didSelectRecognizedText
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Select a text")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { bottomToolbar }
                .toolbar(.visible, for: .bottomBar)
                .toolbarBackground(.visible, for: .bottomBar)
        }
        .onAppear(perform: appeared)
    }
}

extension TextPicker {
    
    //MARK: - Components
    
    var content: some View {
        pager
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
            ZoomableScrollView(focusOnAreaMessage: $focusMessages[index]) {
                imageView(for: imageViewModel)
            }
        }
    }
    
    //MARK: Thumbnail
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            selectedViewModelIndex == index
        }
        
        return Group {
            if let image = imageViewModels[index].image {
                Button {
                    pageToImage(at: index)
                    Haptics.feedback(style: .rigid)
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
        if onlyShowTextsWithValues {
            return imageViewModel.textsWithValues
        } else {
            return imageViewModel.texts
        }
    }
    func boxesLayer(for imageViewModel: ImageViewModel) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(texts(for: imageViewModel), id: \.self) { text in
                    if selectedText?.id != text.id {
                        boxLayer(for: text, inSize: geometry.size)
                    }
                }
                boxLayerForSelectedText(inSize: geometry.size, for: imageViewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
    
    func boxLayer(for text: RecognizedText, inSize size: CGSize) -> some View {
        boxLayer(boundingBox: text.boundingBox, inSize: size, color: .primary) {
            didSelectRecognizedText(text, currentScanResultId ?? UUID())
            dismiss()
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
                button
                Spacer()
            }
            Spacer()
        }
        .offset(x: boundingBox.rectForSize(size).minX,
                y: boundingBox.rectForSize(size).minY)
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
        let increment = index - selectedViewModelIndex
        withAnimation {
            page.update(.move(increment: increment))
        }
        selectedViewModelIndex = index
        
        /// Reset the focusedAreas of the other images (after waiting for half a second for the paging animation to complete)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            for i in 0..<imageViewModels.count {
//                guard i != index else { continue }
//                focusMessages[i] = nil
//                sendZoomMessage(to: i)
//            }
//            sendZoomMessageToCurrentImage()
//        }
    }
    
    func appeared() {
        if let selectedImageIndex {
            pageToImage(at: selectedImageIndex)
        }

        sendZoomMessage(to: selectedImageIndex ?? 0, animated: true)
    }
    
    func sendZoomMessage(to index: Int, animated: Bool) {
        /// Make sure we're not already focused on an area of this image
        guard let imageSize = imageSize(at: index), focusMessages[index] == nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.0)) {
            /// If we have a pre-selected text—zoom into it
            if let selectedBoundingBox, index == selectedImageIndex {
                focusMessages[index] = FocusOnAreaMessage(boundingBox: selectedBoundingBox, imageSize: imageSize)
            } else {
                focusMessages[index] = FocusOnAreaMessage(
                    boundingBox: texts(at: index).boundingBox,
                    animated: animated,
                    padded: false,
                    imageSize: imageSize
                )
            }
        }
    }
    
    var textsForCurrentImage: [RecognizedText] {
        if onlyShowTextsWithValues {
            return imageViewModels[selectedViewModelIndex].textsWithValues
        } else {
            return imageViewModels[selectedViewModelIndex].texts
        }
    }
    
    //MARK: - Helpers
    var currentScanResultId: UUID? {
        imageViewModels[selectedViewModelIndex].scanResult?.id
    }
    
    func imageSize(at index: Int) -> CGSize? {
        imageViewModels[index].image?.size
    }
    
    var currentImage: UIImage? {
        imageViewModels[selectedViewModelIndex].image
    }
    var currentImageSize: CGSize? {
        currentImage?.size
    }
}

//MARK: - Preview

public struct ImageTextPickerPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        let viewModel = FoodFormViewModel()
        viewModel.populateWithSampleImages([10])
        _viewModel = StateObject(wrappedValue: viewModel)
        
        let fieldValue = FieldValue.energy()
        _fieldValue = State(initialValue: fieldValue)
        
        let text = viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "AC10E3D9-E7D6-4510-B555-8A3F52F7B8F2")!})!
        _selectedText = State(initialValue: text)
    }
    
    public var body: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    imageTextPicker
//                        .presentationDetents([.medium, .large])
//                        .presentationDragIndicator(.hidden)
                }
        }
    }
    
    @State var fieldValue: FieldValue
    @State var selectedText: RecognizedText
    
    var imageTextPicker: some View {
        TextPicker(imageViewModels: viewModel.imageViewModels, selectedText: selectedText) { text, ouputId in
        }
        .environmentObject(viewModel)
    }
}

struct ImageTextPicker_Previews: PreviewProvider {
    static var previews: some View {
        ImageTextPickerPreview()
    }
}

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
