import SwiftUI
import ActivityIndicatorView
import PhotosUI
import SwiftHaptics
import SwiftUISugar

struct SourceSection: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingPhotosPicker = false
    
    var body: some View {
        FormStyledSection(header: header, footer: footer) {
            if viewModel.sourceType == .manualEntry {
                notChosenContent
            } else {
                chosenContent
            }
        }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: 5,
            matching: .images
        )
    }
    
    var notChosenContent: some View {
        Button {
            viewModel.showingSourceMenu = true
        } label: {
            Text("Select a source")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var chosenContent: some View {
        NavigationLink {
            SourceForm()
                .environmentObject(viewModel)
        } label: {
            switch viewModel.sourceType {
            case .images:
                VStack(alignment: .leading, spacing: 15) {
                    imagesGrid
                    imageSetStatus
                }
            case .link(let url):
                HStack {
                    Label(url.absoluteString, systemImage: "link")
                        .foregroundColor(.accentColor)
                    Spacer()
                }
            default:
                Text("Not handled")
            }
//            HStack(alignment: .top) {
//                Text(viewModel.sourceType.description)
//                    .foregroundColor(.primary)
//                Spacer()
//                Group {
//                    if viewModel.sourceType == .images {
//                        Text("17 nutrition facts extracted")
//                            .multilineTextAlignment(.trailing)
//                    } else if viewModel.sourceType == .link {
//                        Text(verbatim: "https://www.myfitnesspal.com/food/calories/banan-1511734581")
//                            .lineLimit(1)
////                            .frame(maxWidth: 200, alignment: .trailing)
//                    }
//                }
//                .foregroundColor(.secondary)
//            }
        }
    }
    
    var photosPickerButton: some View {
        Button {
            showingPhotosPicker = true
        } label: {
            Label("Choose Photos", systemImage: SourceType.images.systemImage)
        }
    }
    
    var cameraButton: some View {
        Button {
            viewModel.showingCamera = true
        } label: {
            Label("Take Photos", systemImage: "camera")
        }
    }
    
    var addALinkButton: some View {
        Button {
            
        } label: {
            Label("Add a Link", systemImage: "link")
        }
    }
    
    var imagesGrid: some View {
//        GeometryReader { geometry in
            HStack {
                ForEach(viewModel.imageViewModels, id: \.self.hashValue) { imageViewModel in
                    SourceImage(imageViewModel: imageViewModel, width: 55, height: 55)
                }
            }
//        }
    }
    
    var imageSetStatus: some View {
        func numberView(_ int: Int) -> some View {
            Text("\(int)")
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
        }
        return HStack {
            Group {
                if viewModel.imageSetStatus == .scanned {
                    Text("Scanned")
                    numberView(viewModel.scannedNutrientCount)
                    Text("nutrition facts")
                } else {
                    Text(viewModel.imageSetStatusString)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            if viewModel.imageSetStatus.isWorking {
                ActivityIndicatorView(
                    isVisible: .constant(true),
                    type: .arcs(count: 3, lineWidth: 1)
                )
                    .frame(width: 12, height: 12)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color(.secondarySystemFill))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var header: some View {
        Text("Source")
    }
    
    @ViewBuilder
    var footer: some View {
        if viewModel.sourceType == .manualEntry {
            Button {
                
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Provide a source if you want this food to be eligible for the public database and earn member points.")
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.leading)
                    Label("Learn more", systemImage: "info.circle")
                        .foregroundColor(.accentColor)
                }
                .font(.footnote)
            }
        }
    }
}

public struct SourceCellPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        FoodFormViewModel.shared = FoodFormViewModel()
        let viewModel = FoodFormViewModel.shared
        viewModel.simulateImageSelection()
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            FormStyledScrollView {
                SourceSection()
                    .environmentObject(viewModel)
            }
            .navigationTitle("Source Cell Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SourceCell_Previews: PreviewProvider {
    static var previews: some View {
        SourceCellPreview()
    }
}

extension ImageStatus {
    var isWorking: Bool {
        switch self {
        case .loading, .scanning:
            return true
        default:
            return false
        }
    }
}
