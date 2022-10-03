import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    @State var tappedText: RecognizedText? = nil
    
    @State var page: Page = .first()
    @State var texts: [RecognizedText]

    @State var selectedViewModelIndex: Int = 0

    let selectedBoundingBox: CGRect?
    let selectedText: RecognizedText?
    let didSelectRecognizedText: (RecognizedText, UUID) -> Void
    
    init(texts: [RecognizedText] = [], selectedText: RecognizedText? = nil, selectedBoundingBox: CGRect? = nil, didSelectRecognizedText: @escaping (RecognizedText, UUID) -> Void) {
        _texts = State(initialValue: texts)
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
                ForEach(viewModel.imageViewModels.indices, id: \.self) { index in
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
              data: viewModel.imageViewModels,
              id: \.hashValue,
              content: { imageViewModel in
            zoomableScrollView(for: imageViewModel)
        })
        .sensitivity(.high)
        .pagingPriority(.high)
//        .interactive(scale: 0.7)
//        .interactive(opacity: 0.99)
        .onPageWillChange(pageWillChange(to:))
//        .onPageChanged(controller.pageChanged(to:)) //TODO: Remove this if it is not needed anymore
    }
    
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        ZoomableScrollView {
            imageView(for: imageViewModel)
        }
    }
    
    //MARK: Thumbnail
    
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            selectedViewModelIndex == index
        }
        
        return Group {
            if let image = viewModel.imageViewModels[index].image {
                Button {
                    let increment = index - selectedViewModelIndex
                    withAnimation {
                        page.update(.move(increment: increment))
                    }
                    Haptics.feedback(style: .rigid)
                    selectedViewModelIndex = index
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
    
    func boxesLayer(for imageViewModel: ImageViewModel) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(texts, id: \.self) { text in
                    if selectedText?.id != text.id {
                        boxLayer(for: text, inSize: geometry.size)
                    }
                }
                boxLayerForSelectedText(inSize: geometry.size)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    func boxLayerForSelectedText(inSize size: CGSize) -> some View {
        if let selectedBoundingBox {
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
        withAnimation {
            selectedViewModelIndex = pageIndex
        }
    }
    
    func appeared() {
        /// If we have a pre-selected text—zoom into it
        if let selectedBoundingBox, let currentImageSize {
            let userInfo: [String: Any] = [
                Notification.Keys.boundingBox: selectedBoundingBox,
                Notification.Keys.imageSize: currentImageSize,
            ]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .scrollZoomableScrollViewToRect, object: nil, userInfo: userInfo)
            }
        }
    }
    
    //MARK: - Helpers
    var currentScanResultId: UUID? {
        viewModel.imageViewModels[selectedViewModelIndex].scanResult?.id
    }
    
    var currentImage: UIImage? {
        viewModel.imageViewModels[selectedViewModelIndex].image
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
        
        let text = viewModel.texts(for: fieldValue).first(where: { $0.id == UUID(uuidString: "AC10E3D9-E7D6-4510-B555-8A3F52F7B8F2")!})!
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
        TextPicker(texts: viewModel.texts(for: fieldValue), selectedText: selectedText)
        { text, ouputId in
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
