import SwiftUI
import SwiftHaptics
import SwiftUISugar

struct SourceForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingRemoveAllImagesConfirmation = false
    
    var body: some View {
        form
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
    
    var form: some View {
        FormStyledScrollView {
//        Form {
            switch viewModel.sourceType {
            case .images:
                imageSections
//                emptySections
            case .link:
                linkSections
            default:
                emptySections
            }
        }
    }
    
    var imageSections: some View {
        Group {
            imagesSection
            removeAllImagesSection
        }
    }
    
    var title: String {
        viewModel.sourceType == .manualEntry ? "Add a Source" : "Source"
    }
    var linkSections: some View {
        Color.clear
    }
    
    var emptySections: some View {
        Group {
            FormStyledSection(
                horizontalPadding: 0,
                verticalPadding: 15
            ) {
                VStack(spacing: 15) {
                    Button {
                        
                    } label: {
                        Label("Choose Photos", systemImage: SourceType.images.systemImage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 17)
                    }
                    Divider()
                        .padding(.leading, 50)
                    Button {
                        
                    } label: {
                        Label("Take Photos", systemImage: "camera")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 17)
                    }
                }
            }
            FormStyledSection(
                horizontalPadding: 17,
                verticalPadding: 15
            ) {
                Button {
                    
                } label: {
                    Label("Add a Link", systemImage: "link")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    var imagesSection: some View {
        FormStyledSection(
            header: Text("Images"),
            horizontalPadding: 0,
            verticalPadding: 0
        ) {
//        Section {
            SourceImagesCarousel { index in
            } didTapDeleteOnImage: { index in
                deleteImage(at: index)
            }
            .environmentObject(viewModel)
        }
    }
    
    var removeAllImagesSection: some View {
        FormStyledSection(
            horizontalPadding: 17,
            verticalPadding: 15
        ) {
            Button(role: .destructive) {
                showingRemoveAllImagesConfirmation = true
            } label: {
                Text("Remove all images")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .confirmationDialog("", isPresented: $showingRemoveAllImagesConfirmation) {
                Button("Remove all images", role: .destructive) {
                    Haptics.successFeedback()
                    withAnimation {
                        viewModel.deleteAllImages()
                    }
                }
            }
        }
    }
    
    //MARK: - Actions
    func deleteImage(at index: Int) {
        Haptics.feedback(style: .rigid)
        withAnimation {
            viewModel.deleteImage(at: index)
        }
    }
}

extension FoodFormViewModel {
    func deleteAllImages() {
        resetFillForAllFieldsUsingImages()
        imageViewModels = []
        sourceType = .manualEntry
    }
    
    func deleteImage(at index: Int) {
        /// Change all `.scanned` and `.selection` autofills that depend on this to `.userInput`
        resetFillForFieldsUsingImage(at: index)

        /// Remove the `ImageViewModel` from the array
        imageViewModels.remove(at: index)
        
        /// If this was the last item in the array, reset the `sourceType` to `manualEntry`
        if imageViewModels.isEmpty {
            sourceType = .manualEntry
        }
    }
    
    func resetFillForAllFieldsUsingImages() {
        
    }
    
    func resetFillForFieldsUsingImage(at index: Int) {
        guard index < imageViewModels.count,
              let id = imageViewModels[index].scanResult?.id
        else {
            return
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
