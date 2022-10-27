import SwiftUI
import SwiftHaptics
import SwiftUISugar
import PhotosUI

extension FoodForm {
    struct Sources: View {
        @ObservedObject var sourcesViewModel: SourcesViewModel
        @State var showingRemoveAllImagesConfirmation = false
        @State var showingPhotosPicker = false
        @State var showingTextPicker: Bool = false        
    }
}
extension FoodForm.Sources {

    var body: some View {
        form
        .navigationTitle("Sources")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showingTextPicker) { textPicker }
//        .photosPicker(
//            isPresented: $showingPhotosPicker,
//            selection: $sourcesViewModel.selectedPhotos,
//            maxSelectionCount: sourcesViewModel.availableImagesCount,
//            matching: .images
//        )
    }
    
    var form: some View {
        FormStyledScrollView {
            if !sourcesViewModel.imageViewModels.isEmpty {
                imagesSection
            } else {
                addImagesSection
            }
            if let linkInfo = sourcesViewModel.linkInfo {
                linkSections(for: linkInfo)
            } else {
                addLinkSection
            }
        }
    }
    
    func linkSections(for linkInfo: LinkInfo) -> some View {
        FormStyledSection(header: Text("Link"), horizontalPadding: 0, verticalPadding: 0) {
            VStack(spacing: 0) {
                NavigationLink {
                    SourceWebView(urlString: linkInfo.urlString)
                } label: {
                    LinkCell(linkInfo, alwaysIncludeUrl: true, includeSymbol: true)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
                Divider()
                    .padding(.leading, 50)
                removeLinkButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
            }
        }
    }
    
    var removeLinkButton: some View {
        Button(role: .destructive) {
//            viewModel.showingRemoveLinkConfirmation = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "trash")
                    .frame(width: LabelImageWidth)
                Text("Remove Link")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var addLinkSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            Button {
//                viewModel.showingAddLinkMenu = true
            } label: {
                Label("Add a Link", systemImage: "link")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    //MARK: - Images
    
    var imagesSection: some View {
        FormStyledSection(
            header: Text("Images"),
            horizontalPadding: 0,
            verticalPadding: 0
        ) {
            VStack(spacing: 0) {
                imagesCarousel
                    .padding(.vertical, 15)
                if sourcesViewModel.availableImagesCount > 0 {
                    Divider()
                    addImagesButton
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
            }
        }
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: sourcesViewModel.imageViewModels,
            mode: .imageViewer(
                initialImageIndex: sourcesViewModel.presentingImageIndex,
                deleteHandler: { deletedImageIndex in
//                    viewModel.removeImage(at: deletedImageIndex)
                }
            )
        )
    }
    
    var imagesCarousel: some View {
        Color.blue
//        SourceImagesCarousel(imageViewModels: $sourcesViewModel.imageViewModels) { index in
//            sourcesViewModel.presentingImageIndex = index
//            showingTextPicker = true
//        } didTapDeleteOnImage: { index in
//            removeImage(at: index)
//        }
    }
    
    var addImagesSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            addImagesButton
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
//            viewModel.showingCamera = true
        } label: {
            Label("Take Photo", systemImage: "camera")
        }
    }

    var foodLabelScannerButton: some View {
        Button {
//            viewModel.showingFoodLabelCamera = true
        } label: {
            Label("Scan a Food Label", systemImage: "text.viewfinder")
        }
    }

    var addImagesButton: some View {
        Button {
//            viewModel.showingPhotosMenu = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "plus")
                    .frame(width: LabelImageWidth)
                Text("Add Photo\(sourcesViewModel.availableImagesCount == 1 ? "" : "s")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }

    var autofillButton: some View {
        Button {
//            viewModel.showingAutofillMenu = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "text.viewfinder")
                    .frame(width: LabelImageWidth)
                Text("AutoFill")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
    
    var removeAllImagesButton: some View {
        Button(role: .destructive) {
//            viewModel.showingRemoveImagesConfirmation = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "trash")
                    .frame(width: LabelImageWidth)
                Text("Remove All Photos")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    //MARK: - Actions
    func removeImage(at index: Int) {
        Haptics.feedback(style: .rigid)
        withAnimation {
//            viewModel.removeImage(at: index)
        }
    }
}

