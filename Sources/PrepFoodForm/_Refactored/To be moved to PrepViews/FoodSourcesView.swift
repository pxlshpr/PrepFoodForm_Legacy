import SwiftUI
import ActivityIndicatorView
import PhotosUI
import SwiftHaptics
import SwiftUISugar

struct FoodSourcesView: View {
    
    @ObservedObject var sourcesViewModel: FoodForm.SourcesViewModel
    @State var showingPhotosPicker = false
    
    let didTapAddSource: () -> ()
    
    var body: some View {
        Group {
            if sourcesViewModel.isEmpty {
                emptyContent
            } else {
                content
            }
        }
//        .photosPicker(
//            isPresented: $showingPhotosPicker,
//            selection: $viewModel.selectedPhotos,
//            maxSelectionCount: viewModel.availableImagesCount,
//            matching: .images
//        )
    }
    
    var emptyContent: some View {
        FormStyledSection(header: header, footer: footer) {
            Button {
                didTapAddSource()
            } label: {
                Text("Add a source")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
    
    var content: some View {
        FormStyledSection(header: header, horizontalPadding: 0, verticalPadding: 0) {
            navigationLink
        }
    }
    
    var navigationLink: some View {
        NavigationLink {
            FoodForm.Sources(sourcesViewModel: sourcesViewModel)
        } label: {
            VStack(spacing: 0) {
                imagesRow
                linkRow
            }
        }
    }
    
    @ViewBuilder
    var linkRow: some View {
        if let linkInfo = sourcesViewModel.linkInfo {
            LinkCell(linkInfo, titleColor: .secondary, imageColor: .secondary, detailColor: Color(.tertiaryLabel))
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
        }
    }
    
    @ViewBuilder
    var imagesRow: some View {
        if !sourcesViewModel.imageViewModels.isEmpty {
            HStack(alignment: .top, spacing: LabelSpacing) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.secondary)
                    .frame(width: LabelImageWidth)
                VStack(alignment: .leading, spacing: 15) {
                    imagesGrid
                    imageSetSummary
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 15)
            if sourcesViewModel.linkInfo != nil {
                Divider()
                    .padding(.leading, 50)
            }
        }
    }

    var imagesGrid: some View {
        HStack {
            ForEach(sourcesViewModel.imageViewModels, id: \.self.hashValue) { imageViewModel in
                SourceImage(
                    imageViewModel: imageViewModel,
                    imageSize: .small
                )
            }
        }
    }
    
    var imageSetSummary: some View {
//        Color.green
        ImageSetSummary(imageSetStatus: $sourcesViewModel.imageSetStatus)
    }

    var header: some View {
        Text("Sources")
    }
    
    @ViewBuilder
    var footer: some View {
        Button {
            
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                Text("Provide a source if you want this food to be eligible for the public database and generate subscription tokens.")
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)
                Label("Learn more", systemImage: "info.circle")
                    .foregroundColor(.accentColor)
            }
            .font(.footnote)
        }
    }
}
