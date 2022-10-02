import SwiftUI
import PrepUnits
import SwiftHaptics

struct CroppedImageButton: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var fieldFormViewModel: FieldFormViewModel
//    @Binding var image: UIImage?

    var body: some View {
        Button {
            fieldFormViewModel.showingImageTextPicker = true
        } label: {
            VStack {
                HStack {
                    Spacer()
                    imageView
                        .frame(maxWidth: 350, maxHeight: 150, alignment: .bottom)
                    Spacer()
                }
            }
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var imageView: some View {
        if let image = sampleImage {
            imageView(for: image)
        }
    }
    
    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.top, 5)
            .padding(.bottom, 8)
            .padding(.horizontal, 3)
//            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    var sampleImage: UIImage? {
        PrepFoodForm.sampleImage(4)
    }
}
