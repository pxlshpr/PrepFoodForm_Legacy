import SwiftUI

struct FillOptionSections: View {
    
    @Binding var showingImage: Bool

    var body: some View {
        Group {
            Section {
                FillOptionsGrid()
            }
            Section {
                if showingImage {
                    croppedImageButton
                }
            }
        }
    }
    
    var croppedImageButton: some View {
        Button {
//            fieldFormViewModel.showingImageTextPicker = true
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
//        if showingImage {
//        if let image = sampleImage {
            imageView(for: sampleImage!)
//        }
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

public struct FillOptionSectionsPreview: View {
    
    @State var showingImage = false
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            Form {
                FillOptionSections(showingImage: $showingImage)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Image") {
                        withAnimation {
                            showingImage.toggle()
                        }
                    }
                }
            }
        }
    }
}

struct FillOptionSections_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionSectionsPreview()
    }
}
