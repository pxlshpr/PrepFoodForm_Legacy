import SwiftUI
import SwiftHaptics
import SwiftUISugar

let LabelSpacing: CGFloat = 10
let LabelImageWidth: CGFloat = 20

extension String {
    
    var htmlTitle: String? {
        let openGraphPattern = #"og:title\"[^\"]*\"([^\"]*)"#
        let htmlTitlePattern = #"<title>(.*)<\/title>"#
        
        return self.secondCapturedGroup(using: openGraphPattern) ?? self.secondCapturedGroup(using: htmlTitlePattern)
    }
}

struct LinkCell: View {
    
    @ObservedObject var linkInfo: LinkInfo
    let customTitle: String?
    let includeSymbol: Bool
    let alwaysIncludeUrl: Bool
    let titleColor: Color
    let imageColor: Color
    let detailColor: Color

    init(_ linkInfo: LinkInfo,
         title: String? = nil,
         alwaysIncludeUrl: Bool = false,
         includeSymbol: Bool = true,
         titleColor: Color = Color.accentColor,
         imageColor: Color = Color.accentColor,
         detailColor: Color = Color(.secondaryLabel)
    ) {
        self.linkInfo = linkInfo
        self.customTitle = title
        self.includeSymbol = includeSymbol
        self.alwaysIncludeUrl = alwaysIncludeUrl
        self.titleColor = titleColor
        self.imageColor = imageColor
        self.detailColor = detailColor
    }
    
    var title: String {
        guard let customTitle else {
            return linkInfo.title ?? linkInfo.urlString
        }
        return customTitle
    }
    var haveTitle: Bool {
        customTitle != nil || linkInfo.title != nil
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Group {
                    if includeSymbol {
                        HStack(alignment: .top, spacing: LabelSpacing) {
                            Image(systemName: "link")
                                .frame(width: LabelImageWidth)
                                .foregroundColor(imageColor)
                            Text(title)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(titleColor)
                            
                        }
//                        Label(title, systemImage: "link")
                    } else {
                        Text(title)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(titleColor)
                    }
                }
                .foregroundColor(.accentColor)
//                if alwaysIncludeUrl, haveTitle {
                    Text(linkInfo.urlDisplayString)
                        .font(.footnote)
                        .foregroundColor(detailColor)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, LabelSpacing + LabelImageWidth)
//                }
            }
            Spacer()
            if let image = linkInfo.faviconImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 21, height: 21)
                    .transition(.opacity)
            }
        }
    }
}

extension ImageViewModel: Identifiable {
    var id: UUID {
        scanResult?.id ?? UUID()
    }
}

struct SourceForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingRemoveAllImagesConfirmation = false
    @State var showingPhotosPicker = false
    @State var imageViewModelToShowTextPickerFor: ImageViewModel? = nil
    
    var body: some View {
        form
        .navigationTitle("Sources")
        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: $showingTextPicker) { textPicker }
        .sheet(item: $imageViewModelToShowTextPickerFor) { imageViewModel in
            textPicker(for: imageViewModel)
        }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: 5,
            matching: .images
        )
    }
    
    var form: some View {
        FormStyledScrollView {
            if viewModel.hasSourceImages {
                imageSections
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
    
    var imageSections: some View {
//        Group {
            imagesSection
//            imagesActionsSection
//        }
    }
    
    var imagesActionsSection: some View {
        FormStyledSection(horizontalPadding: 0, verticalPadding: 0) {
            VStack(spacing: 0) {
                addImagesButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                Divider()
                    .padding(.leading, 17)
                removeAllImagesButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
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
                    .padding(.leading, 17)
                removeLinkButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
            }
        }
    }
    
    var removeLinkButton: some View {
//        Button(role: .destructive) {
        Button {
            viewModel.showingRemoveLinkConfirmation = true
        } label: {
            HStack(spacing: LabelSpacing) {
                Image(systemName: "trash")
                    .frame(width: LabelImageWidth)
                Text("Remove Link")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.secondary)
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
                Divider()
//                    .padding(.leading, 17)
                addImagesButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                Divider()
                    .padding(.leading, 17)
                removeAllImagesButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
            }

        }
    }
    
    @ViewBuilder
    func textPicker(for imageViewModel: ImageViewModel) -> some View {
        if let index = viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == imageViewModel.scanResult?.id})
        {
            TextPicker(
                viewModel: viewModel,
                selectedImageIndex: index
            )
        }
    }
    
    var imagesCarousel: some View {
        SourceImagesCarousel { index in
            imageViewModelToShowTextPickerFor = viewModel.imageViewModels[index]
        } didTapDeleteOnImage: { index in
            removeImage(at: index)
        }
        .environmentObject(viewModel)
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
    
    var addImagesButton: some View {
        Button {
            viewModel.showingPhotosMenu = true
        } label: {
//            Text("Add Images")
            HStack(spacing: LabelSpacing) {
                Image(systemName: "plus")
                    .frame(width: LabelImageWidth)
                Text("Add Images")
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
                Text("Remove All Images")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.secondary)
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
            fieldViewModel.resetFill()
        }
        scannedFieldValues = []
    }
    
    func resetFillForFieldsUsingImage(at index: Int) {
        guard index < imageViewModels.count,
              let id = imageViewModels[index].scanResult?.id
        else {
            return
        }
        /// Selectively reset fills for fields that are using this image
        for fieldViewModel in allFieldViewModels {
            fieldViewModel.resetFillIfUsingImage(withId: id)
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
