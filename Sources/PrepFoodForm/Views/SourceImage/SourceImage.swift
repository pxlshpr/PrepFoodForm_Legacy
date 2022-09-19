import SwiftUI
import ActivityIndicatorView

struct SourceImage: View {
    
    @ObservedObject var sourceImageViewModel: SourceImageViewModel
    
    init(sourceImageViewModel: SourceImageViewModel) {
        _sourceImageViewModel = ObservedObject(wrappedValue: sourceImageViewModel)
    }
    
    var body: some View {
        Image(uiImage: sourceImageViewModel.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(overlay)
            .clipShape(
                RoundedRectangle(cornerRadius: 10,
                                 style: .continuous))
            .frame(maxWidth: 120, maxHeight: 120)
            .shadow(radius: sourceImageViewModel.status == .processing ? 0 : 3, x: 0, y: 3)
            .animation(.default, value: sourceImageViewModel.status)
    }
    
    var overlay: some View {
        @ViewBuilder
        var color: some View {
            switch sourceImageViewModel.status {
            case .processing:
                Color(.darkGray)
                    .opacity(0.5)
            case .processed:
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(.darkGray).opacity(0.9), location: 0),
                        .init(color: Color.clear, location: 0.3),
                        .init(color: Color.clear, location: 1)
                    ]),
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
            default:
                Color.clear
            }
        }
        
        @ViewBuilder
        var activityView: some View {
            if sourceImageViewModel.status == .processing {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
//                ActivityIndicatorView(isVisible: .constant(true), type: .flickeringDots(count: 8))
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
        }
        
        @ViewBuilder
        var checkmark: some View {
            if sourceImageViewModel.status == .processed {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "text.viewfinder")
                            .renderingMode(.original)
                            .imageScale(.large)
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .foregroundColor(.accentColor)
                                    .opacity(0.7)
                            )
                            .padding(5)
                    }
                }
            }
        }
        
        return ZStack {
            color
            activityView
            checkmark
        }
    }
}

public struct SourceImagePreview: View {
        
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        
        let viewModel = FoodFormViewModel()
        viewModel.setSampleImages()        
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    SourceImagesCarousel()
                        .environmentObject(viewModel)
                }
            }
            .navigationTitle("Source Image")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.simulateScan()
        }
    }
}

struct SourceImage_Previews: PreviewProvider {
    static var previews: some View {
        SourceImagePreview()
    }
}
