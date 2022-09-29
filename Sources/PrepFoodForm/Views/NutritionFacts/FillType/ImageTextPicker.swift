import SwiftUI
import SwiftHaptics
import NutritionLabelClassifier
import VisionSugar

struct ImageTextPicker: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    let selectedTextId: UUID?
//    let selectedImageOutputId: UUID?

    @State var tappedText: RecognizedText? = nil
    
    var body: some View {
        ZStack {
            ZoomableScrollView {
                if let image = viewModel.imageViewModels.first!.image {
                    imageView(with: image)
                }
            }
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
    
    var imageViewModel: ImageViewModel {
        viewModel.imageViewModels.first!
    }
    
    var texts: [RecognizedText] {
        imageViewModel.output?.nutrients.rows.compactMap { $0.valueText1?.text } ?? []
    }
    
    @ViewBuilder
    var boxesLayer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(texts, id: \.self) { text in
                    Button {
                        Haptics.feedback(style: .rigid)
                        tappedText = text
                    } label: {
                        boxView(for: text, inSize: geometry.size)
                    }
                    .offset(x: text.boundingBox.rectForSize(geometry.size).minX,
                            y: text.boundingBox.rectForSize(geometry.size).minY)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    func boxView(for text: RecognizedText, inSize size: CGSize) -> some View {
        HStack {
            VStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 3)
                    .foregroundStyle(
                        Color.accentColor.gradient.shadow(
                            .inner(color: .black, radius: 3)
                        )
                    )
                    .opacity(0.3)

//                Color.accentColor
//                    .cornerRadius(6.0)
//                    .opacity(0.4)
                
                    .frame(width: text.boundingBox.rectForSize(size).width,
                           height: text.boundingBox.rectForSize(size).height)
                
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.accentColor, lineWidth: 1)
                            .opacity(0.8)
                    )
                    .shadow(radius: 3, x: 0, y: 2)

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
        ImageTextPicker(selectedTextId: nil)
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
