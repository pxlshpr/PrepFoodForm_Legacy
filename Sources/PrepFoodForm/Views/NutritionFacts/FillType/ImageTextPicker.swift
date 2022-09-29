import SwiftUI
import SwiftHaptics
import NutritionLabelClassifier
import VisionSugar

struct ImageTextPicker: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel

    @State var tappedText: RecognizedText? = nil
    
    @State var texts: [RecognizedText] = []
    @State var currentImageViewModel: ImageViewModel?
    
    let selectedTextId: UUID?
    let selectedImageOutputId: UUID?
    let didSelectRecognizedText: (RecognizedText, UUID) -> Void
    
    init(fillType: FillType, didSelectRecognizedText: @escaping (RecognizedText, UUID) -> Void) {
        
        switch fillType {
        case .imageSelection(let recognizedText, let outputId):
            self.selectedTextId = recognizedText.id
            self.selectedImageOutputId = outputId
        case .imageAutofill(let valueText, let outputId):
            self.selectedTextId = valueText.text.id
            self.selectedImageOutputId = outputId
        default:
            self.selectedTextId = nil
            self.selectedImageOutputId = nil
        }
        
        self.didSelectRecognizedText = didSelectRecognizedText
        
        self.currentImageViewModel = nil
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Select a text")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var content: some View {
        ZStack {
            zoomableScrollView
            selectedText
        }
        .task {
            await MainActor.run {
                if let selectedImageOutputId {
                    self.currentImageViewModel = viewModel.imageViewModel(forOutputId: selectedImageOutputId)
                } else {
                    self.currentImageViewModel = viewModel.imageViewModels.first
                }
            }
            
            let texts = viewModel.imageViewModels.first!.output!.texts.accurate.filter { text in
                text.string.matchesRegex(#"(^|[ ]+)[0-9]+"#)
            }
            await MainActor.run {
                self.texts = texts
            }
        }
    }
    
    var zoomableScrollView: some View {
        ZoomableScrollView {
            if let image = viewModel.imageViewModels.first!.image {
                imageView(with: image)
            }
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
    
    func imageView(with image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .overlay {
                boxesLayer
                    .transition(.opacity)
            }
    }
    
    @ViewBuilder
    var boxesLayer: some View {
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
    
    func boxLayer(for text: RecognizedText, inSize size: CGSize) -> some View {
        var boxView: some View {
            Button {
                Haptics.feedback(style: .rigid)
                didSelectRecognizedText(text, currentImageViewModel?.output?.id ?? UUID())
//                        tappedText = text
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
        viewModel.populateWithSampleImages()
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
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
    
    func populateWithSampleImages() {
        populateWithSampleImage(8)
    }
    
    func populateWithSampleImage(_ number: Int) {
        guard let image = sampleImage(number), let output = sampleOutput(number) else {
            fatalError("Couldn't populate sample image: \(number)")
        }
        imageViewModels.append(ImageViewModel(image: image, output: output))
    }
    
}
