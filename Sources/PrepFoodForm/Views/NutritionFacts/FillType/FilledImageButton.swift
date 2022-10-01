import SwiftUI
import PrepUnits
import SwiftHaptics

struct FilledImageButton: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var fieldFormViewModel: FieldFormViewModel
//    @Binding var image: UIImage?

    var body: some View {
        Button {
            fieldFormViewModel.showingImageTextPicker = true
        } label: {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    imageView
                        .frame(maxWidth: 350, maxHeight: 150, alignment: .bottom)
                    Spacer()
                }
            }
            .frame(width: 350, height: 150)
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var imageView: some View {
        if let image = fieldFormViewModel.imageToDisplay {
//            if fieldFormViewModel.showAnimation {
//                imageView(for: image)
//            } else {
                imageView(for: image)
                    .transition(.move(edge: .bottom))
//            }
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
    
//    var header: some View {
//        var string: String {
//            fieldValue.fillType.isImageAutofill ? "Detected Text" : "Selected Text"
//        }
//
//        var systemImage: String {
//            fieldValue.fillType.isImageAutofill ? "text.viewfinder" : "hand.tap"
//        }
//
//        return Text(string)
//    }

    var sampleImage: UIImage? {
        PrepFoodForm.sampleImage(4)
    }
}
