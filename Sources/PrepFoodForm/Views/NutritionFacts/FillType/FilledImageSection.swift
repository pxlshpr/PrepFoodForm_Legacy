import SwiftUI
import PrepUnits
import SwiftHaptics

struct FilledImageSection: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Binding var fieldValue: FieldValue
    @State var imageToDisplay: UIImage? = nil

    var body: some View {
        Group {
            if fieldValue.fillType.usesImage {
                Section(header: header) {
                    NavigationLink {
                        
                    } label: {
                        image
                    }
                }
            }
        }
        .onAppear {
            //TODO: Do this on reassignments of the fillType and also when classification completes while on this page (at least with a notification as a fallback), if the user hasn't typed anything yet of course.
            getCroppedImage()
        }
    }

    
    @ViewBuilder
    var image: some View {
        if let uiImage = imageToDisplay {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .shadow(radius: 3, x: 0, y: 3)
                .padding(.top, 5)
                .padding(.bottom, 8)
                .padding(.horizontal, 3)
                .frame(maxWidth: 200, maxHeight: 150)
        }
    }
    
    var header: some View {
        var string: String {
            fieldValue.fillType.isImageAutofill ? "Detected Text" : "Selected Text"
        }
        
        var systemImage: String {
            fieldValue.fillType.isImageAutofill ? "text.viewfinder" : "hand.tap"
        }
        
        return Text(string)
    }

    var sampleImage: UIImage? {
        guard let path = Bundle.module.path(forResource: "label4", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    @ViewBuilder
    var box: some View {
        if let box = fieldValue.fillType.boundingBox {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 3)
//                        .foregroundColor(Color.accentColor)
                    .foregroundStyle(
                        Color.accentColor.gradient.shadow(
                            .inner(color: .black, radius: 3)
                        )
                    )
                    .opacity(0.3)
                    .frame(width: box.rectForSize(geometry.size).width, height: box.rectForSize(geometry.size).height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.accentColor, lineWidth: 1)
                            .opacity(0.8)
                    )
                    .shadow(radius: 3, x: 0, y: 2)
                    .offset(x: box.rectForSize(geometry.size).minX, y: box.rectForSize(geometry.size).minY)
            }
        }
    }
    
    func getCroppedImage() {
        Task {
            let croppedImage = await viewModel.croppedImage(for: fieldValue.fillType)
//            guard let outputId = fieldValue.energyValue.fillType.outputId else {
//                return
//            }
//            let image = viewModel.image(for: outputId)

            await MainActor.run {
                self.imageToDisplay = croppedImage
            }
        }
    }
}
