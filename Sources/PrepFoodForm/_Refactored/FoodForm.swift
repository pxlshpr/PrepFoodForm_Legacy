import SwiftUI
import SwiftUISugar
import Combine
import FoodLabelScanner
import PhotosUI

extension FoodForm {
    class SourcesViewModel: ObservableObject {
        @Published var imageViewModels: [ImageViewModel] = []
        @Published var imageSetStatus: ImageSetStatus = .loading()
        @Published var linkInfo: LinkInfo? = nil
        
        /// Scan Results
        @Published var twoColumnOutput: ScanResultsTwoColumnOutput? = nil
        @Published var selectedScanResultsColumn = 1
        
        @Published var selectedPhotos: [PhotosPickerItem] = []
        var presentingImageIndex: Int = 0
    }
}

extension FoodForm.SourcesViewModel {
    
    func receivedScanResult(_ scanResult: ScanResult, for image: UIImage) {
        let imageViewModel = ImageViewModel(image: image, scanResult: scanResult, delegate: self)
        imageViewModels.append(imageViewModel)
        processScanResults()
    }
    
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item, delegate: self)
            imageViewModels.append(imageViewModel)
        }
        selectedPhotos = []
    }
    
    func processScanResults() {
        let counts = DataPointsCount(imageViewModels: imageViewModels)
        imageSetStatus = .scanned(numberOfImages: imageViewModels.count, counts: counts)
        
        Task {
            guard let output = await ScanResultsProcessor.shared.process(allScanResults) else {
                return
            }
            await MainActor.run {
                switch output {
                case .twoColumns(let twoColumnOutput):
                    print("🍩 Setting twoColumnOutput")
                    self.twoColumnOutput = twoColumnOutput
                case .oneColumn:
                    break
                }
            }
        }
    }
    
    func imageViewModels(for twoColumnOutput: ScanResultsTwoColumnOutput) -> [ImageViewModel] {
        imageViewModels.containingTexts(in: twoColumnOutput)
    }
    var allScanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }

    /// Returns how many images can still be added to this food
    var availableImagesCount: Int {
        max(5 - imageViewModels.count, 0)
    }
    
    var isEmpty: Bool {
        imageViewModels.isEmpty && linkInfo == nil
    }
}
//TODO: Finish this
//Also migrate form to use this
//Also have scan results moved here possibly
extension FoodForm.SourcesViewModel: ImageViewModelDelegate {
    
    func imageDidFinishScanning(_ imageViewModel: ImageViewModel) {
        guard !imageSetStatus.isScanned else {
            return
        }
        
        if imageViewModels.allSatisfy({ $0.status == .scanned }) {
//            Haptics.successFeedback()
            withAnimation {
                processScanResults()
            }
        }
    }

    func imageDidStartScanning(_ imageViewModel: ImageViewModel) {
        withAnimation {
            self.imageSetStatus = .scanning(numberOfImages: imageViewModels.count)
        }
    }

    func imageDidFinishLoading(_ imageViewModel: ImageViewModel) {
        withAnimation {
            self.imageSetStatus = .scanning(numberOfImages: imageViewModels.count)
        }
    }
}

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    let didSave: (FoodFormData) -> ()
    
    @State var emoji: String = ""
    @State var name: String = ""
    @State var detail: String = ""
    @State var brand: String = ""
    
    /// Sources
    @StateObject var sourcesViewModel = SourcesViewModel()

    /// Sheets
    @State var showingEmojiPicker = false
    @State var showingCamera = false
    @State var showingFoodLabelCamera = false
    @State var showingPhotosPicker = false
    @State var showingPrefill = false
    @State var showingPrefillInfo = false
    
    /// Menus
    @State var showingSourcesMenu = false

    /// Wizard
    @State var shouldShowWizard = true
    @State var showingWizard = true
    @State var showingWizardOverlay = true
    @State var formDisabled = false

    public init(didSave: @escaping (FoodFormData) -> ()) {
        self.didSave = didSave
        _emoji = State(initialValue: randomFoodEmoji())
    }
    
    public var body: some View {
        let _ = Self._printChanges()
        return NavigationView {
            content
                .navigationTitle("New Food")
                .toolbar { navigationLeadingContent }
                .onAppear(perform: appeared)
                .onChange(of: sourcesViewModel.selectedPhotos, perform: sourcesViewModel.selectedPhotosChanged)
                .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
                .sheet(isPresented: $showingFoodLabelCamera) { foodLabelCamera }
                .fullScreenCover(item: $sourcesViewModel.twoColumnOutput) { columnPicker($0) }
                .photosPicker(
                    isPresented: $showingPhotosPicker,
                    selection: $sourcesViewModel.selectedPhotos,
                    maxSelectionCount: sourcesViewModel.availableImagesCount,
                    matching: .images
                )
        }
        .bottomMenu(isPresented: $showingSourcesMenu, actionGroups: sourcesMenuContents)
    }
    
    var content: some View {
        ZStack {
            formLayer
            wizardLayer
        }
    }
    
    //MARK: - Layers
    
    @ViewBuilder
    var formLayer: some View {
        FormStyledScrollView {
            detailsSection
            sourcesSection
        }
        .safeAreaInset(edge: .bottom) {
            //TODO: Programmatically get this inset (67516AA6)
            Spacer().frame(height: 150)
        }
        .overlay(
            Color(.quaternarySystemFill)
                .opacity(showingWizardOverlay ? 0.3 : 0)
        )
        .blur(radius: showingWizardOverlay ? 5 : 0)
        .disabled(formDisabled)
    }
    
    @ViewBuilder
    var wizardLayer: some View {
        if showingWizard {
            Wizard(tapHandler: tappedWizardButton)
        }
    }
    
    //MARK: - Toolbars
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
    }
}
