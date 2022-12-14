import SwiftUI
import SwiftHaptics
import SwiftUISugar

struct SourceForm: View {

    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingRemoveAllImagesConfirmation = false
    @State var showingPhotosPicker = false
    @State var showingTextPicker: Bool = false
    
    var body: some View {
        form
        .navigationTitle("Sources")
        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: $showingTextPicker) { textPicker }
//        .fullScreenCover(item: $imageIdToShowTextPickerFor) { imageIdContainer in
//            textPicker(for: imageIdContainer.id)
//        }
        .fullScreenCover(isPresented: $showingTextPicker) {
            textPicker
        }

        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: viewModel.availableImagesCount,
            matching: .images
        )
    }
    
    var form: some View {
        FormStyledScrollView {
            if viewModel.hasSourceImages {
                imagesSection
            } else {
                addImagesSection
            }
            if let linkInfo = viewModel.linkInfo {
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
                    WebView(urlString: linkInfo.urlString)
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
//        Button {
            viewModel.showingRemoveLinkConfirmation = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "trash")
                    .frame(width: LabelImageWidth)
                Text("Remove Link")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
//            .foregroundColor(.secondary)
        }
    }
    
    var addLinkSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            Button {
                viewModel.showingAddLinkMenu = true
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
//                Divider()
////                    .padding(.leading, 17)
//                autofillButton
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 15)
//                Divider()
//                    .padding(.leading, 50)
                if viewModel.availableImagesCount > 0 {
                    Divider()
                    addImagesButton
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                }
//                Divider()
//                    .padding(.leading, 50)
//                removeAllImagesButton
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 15)
            }

        }
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: viewModel.imageViewModels,
            mode: .imageViewer(
                initialImageIndex: viewModel.selectedImageIndex,
                deleteHandler: { deletedImageIndex in
                    viewModel.removeImage(at: deletedImageIndex)
                },
                columnSelectionHandler: { selectedColumn, scanResultToAutofill in
                    //TODO: Handle this
                }
            )
        )
//        TextPicker(
//            config: TextPickerViewModel(
//                imageViewModels: viewModel.imageViewModels,
//                initialImageIndex: viewModel.selectedImageIndex,
//                allowsTogglingTexts: true,
//                deleteImageHandler: { index in
//                    viewModel.removeImage(at: index)
////                    currentIndex -= 1
////                    Haptics.successFeedback()
////                    if viewModel.imageViewModels.isEmpty {
////                        dismiss()
////                    }
//                }
//            )
//        )
    }
    
    var imagesCarousel: some View {
        SourceImagesCarousel(imageViewModels: $viewModel.imageViewModels) { index in
            viewModel.selectedImageIndex = index
            print("???? viewModel.selectedImageIndex is now: \(viewModel.selectedImageIndex)")
            showingTextPicker = true
        } didTapDeleteOnImage: { index in
            removeImage(at: index)
        }
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
            viewModel.showingCamera = true
        } label: {
            Label("Take Photo", systemImage: "camera")
        }
    }

    var foodLabelScannerButton: some View {
        Button {
            viewModel.showingFoodLabelCamera = true
        } label: {
            Label("Scan a Food Label", systemImage: "text.viewfinder")
        }
    }

    var addImagesButton: some View {
        Button {
            viewModel.showingPhotosMenu = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "plus")
                    .frame(width: LabelImageWidth)
                Text("Add Photo\(viewModel.availableImagesCount == 1 ? "" : "s")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }

    var autofillButton: some View {
        Button {
            viewModel.showingAutofillMenu = true
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
//        Button(role: .destructive) {
        Button(role: .destructive) {
            viewModel.showingRemoveImagesConfirmation = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "trash")
                    .frame(width: LabelImageWidth)
                Text("Remove All Photos")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
//            .foregroundColor(.secondary)
//            .foregroundColor(.red)
        }
    }
    
    //MARK: - Actions
    func removeImage(at index: Int) {
        Haptics.feedback(style: .rigid)
        withAnimation {
            viewModel.removeImage(at: index)
        }
    }
}

extension FoodFormViewModel {
    func removeSourceLink() {
        linkInfo = nil
    }
    
    func removeAllImages() {
        resetFillForAllFieldsUsingImages()
        imageViewModels = []
    }
    
    func removeUnprocessedImageViewModels() {
        imageViewModels.removeAll(where: { !$0.isProcessed })
    }
    
    func removeImage(at index: Int) {
        /// Change all `.scanned` and `.selection` autofills that depend on this to `.userInput`
        resetFillForFieldsUsingImage(at: index)

        /// Remove the `ImageViewModel` from the array
        imageViewModels.remove(at: index)
        
        /// If this was the last item in the array, reset the `sourceType` to `manualEntry`
//        if imageViewModels.isEmpty {
//            sourceType = .manualEntry
//        }
    }
    
    func resetFillForAllFieldsUsingImages() {
        for fieldViewModel in allFieldViewModels {
            fieldViewModel.registerDiscardedScan()
        }
        scannedFieldValues = []
    }
    
    func resetFillForFieldsUsingImage(at index: Int) {
        guard index < imageViewModels.count else {
            return
        }
        
        let id = imageViewModels[index].id
        
        /// Selectively reset fills for fields that are using this image
        for fieldViewModel in allFieldViewModels {
            fieldViewModel.registerDiscardScanIfUsingImage(withId: id)
        }
        
        /// Now remove the saved scanned field values that are also using this image
        scannedFieldValues = scannedFieldValues.filter {
            !$0.fill.usesImage(with: id)
        }
    }
}

struct SourceFormPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .pumpkinSeeds)
        FoodFormViewModel.shared = viewModel
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            SourceForm()
                .environmentObject(viewModel)
        }
    }
}

struct SourceForm_Previews: PreviewProvider {
    static var previews: some View {
        SourceFormPreview()
    }
}
