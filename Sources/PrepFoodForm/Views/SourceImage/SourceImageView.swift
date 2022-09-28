import SwiftUI
import ActivityIndicatorView

struct SourceImageView: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    var imageViewModel: ImageViewModel
    
    var body: some View {
        zoomableScrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { bottomToolbarContent }
    }
    
    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            HStack {
                Text("Extracting Data")
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                    .frame(width: 20.0, height: 20.0)
            }
            .foregroundColor(.secondary)
        }
    }
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Remove") {
                
            }
        }
    }
    
    var zoomableScrollView: some View {
        GeometryReader { proxy in
            ZoomableScrollView {
                if let image = imageViewModel.image {
                    imageView(with: image)
                }
            }
//            .onAppear {
//                classifierController.contentSize = proxy.size
//            }
//            .frame(maxHeight: shrinkImageView ? proxy.size.height / 2.0 : proxy.size.height)
//            .onChange(of: classifierController.selectedBox) { newValue in
//                updateSize(for: proxy.size, reduceSize: newValue != nil)
//            }
//            .onChange(of: classifierController.isPresentingList) { newValue in
//                updateSize(for: proxy.size, reduceSize: classifierController.isPresentingList)
//            }
        }
    }
    
    func imageView(with image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
//            .overlay(content: {
//                if !isHidingBoxes {
//                    boxesLayer
//                        .transition(.opacity)
//                }
//            })
    }

}
