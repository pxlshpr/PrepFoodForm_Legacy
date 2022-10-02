import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager

struct ImageTextPicker: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel

    @State var tappedText: RecognizedText? = nil
    
    @State var page: Page = .first()
    
    //TODO: this needs to be provided
    @State var texts: [RecognizedText] = []

    let selectedTextId: UUID?
    let selectedImageScanResultId: UUID?
    let didSelectRecognizedText: (RecognizedText, UUID) -> Void
    
    init(fillType: FillType, didSelectRecognizedText: @escaping (RecognizedText, UUID) -> Void) {
        
        switch fillType {
        case .imageSelection(let recognizedText, let scanResultId, _):
            self.selectedTextId = recognizedText.id
            self.selectedImageScanResultId = scanResultId
        case .imageAutofill(let valueText, let scanResultId, _):
            self.selectedTextId = valueText.text.id
            self.selectedImageScanResultId = scanResultId
        default:
            self.selectedTextId = nil
            self.selectedImageScanResultId = nil
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
    }
    
    var content: some View {
        ZStack {
            pager
//                .edgesIgnoringSafeArea(.bottom)
            selectedText
        }
//        .background(Color(.systemGroupedBackground))
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
    
    @State var selectedViewModelIndex: Int = 0
    
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
    
    func pageWillChange(to pageIndex: Int) {
        withAnimation {
            selectedViewModelIndex = pageIndex
        }
    }
    
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        ZoomableScrollView {
            imageView(for: imageViewModel)
        }
    }

    @ViewBuilder
    var selectedText: some View {
        if let tappedText {
            VStack {
                Spacer()
                Text(tappedText.string)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(Color.accentColor.opacity(0.8))
                    )
                    .padding(.bottom)
            }
        }
    }
    
    @ViewBuilder
    func imageView(for imageViewModel: ImageViewModel) -> some View {
        if let image = imageViewModel.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .overlay {
                    boxesLayer(for: imageViewModel)
                        .transition(.opacity)
                }
        }
    }
    
    func boxesLayer(for imageViewModel: ImageViewModel) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(texts, id: \.self) { text in
                    boxLayer(for: text, inSize: geometry.size)
                    .offset(x: text.boundingBox.rectForSize(geometry.size).minX,
                            y: text.boundingBox.rectForSize(geometry.size).minY)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var currentScanResultId: UUID? {
        viewModel.imageViewModels[selectedViewModelIndex].scanResult?.id
    }
    
    func boxLayer(for text: RecognizedText, inSize size: CGSize) -> some View {
        var boxView: some View {
            Button {
                Haptics.feedback(style: .rigid)
                didSelectRecognizedText(text, currentScanResultId ?? UUID())
            } label: {
                RoundedRectangle(cornerRadius: 3)
                    .foregroundStyle(
                        Color.accentColor.gradient.shadow(
                            .inner(color: .black, radius: 3)
                        )
                    )
                    .opacity(0.3)
                    .frame(width: text.boundingBox.rectForSize(size).width,
                           height: text.boundingBox.rectForSize(size).height)
                
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.accentColor, lineWidth: 1)
                            .opacity(0.8)
                    )
                    .shadow(radius: 3, x: 0, y: 2)
            }
        }
        
        return HStack {
            VStack(alignment: .leading) {
                boxView
                Spacer()
            }
            Spacer()
        }
    }
}

public struct ImageTextPickerPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        let viewModel = FoodFormViewModel()
        viewModel.populateWithSampleImages([7, 8])
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    imageTextPicker
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
        }
    }
    
    var imageTextPicker: some View {
        ImageTextPicker(fillType: .userInput) { text, ouputId in
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
