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
                        Image(systemName: "checkmark.circle.fill")
                            .renderingMode(.original)
                            .imageScale(.large)
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

struct SourceImagesCarousel: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(viewModel.sourceImageViewModels.indices, id: \.self) { index in
                    sourceImage(at: index)
                        .padding(.leading, index == 0 ? 10 : 0)
                        .padding(.trailing, index ==  viewModel.sourceImageViewModels.count - 1 ? 10 : 0)
                }
            }
        }
        .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))
    }
    
    func sourceImage(at index: Int) -> some View {
        SourceImage(sourceImageViewModel: viewModel.sourceImageViewModels[index])
            .padding(.horizontal, 10)
            .padding(.vertical, 20)
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
