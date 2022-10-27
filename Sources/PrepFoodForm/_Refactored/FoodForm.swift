import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    let didSave: (FoodFormData) -> ()
    
    @State var emoji: String = ""
    @State var name: String = ""
    @State var detail: String = ""
    @State var brand: String = ""
    
    /// Fields
    @StateObject var fieldsViewModel = FieldsViewModel()
    
    /// Sources
    @StateObject var sourcesViewModel = SourcesViewModel()

    /// Sheets
    @State var showingEmojiPicker = false
    @State var showingCamera = false
    @State var showingFoodLabelCamera = false
    @State var showingPhotosPicker = false
    @State var showingPrefill = false
    @State var showingPrefillInfo = false
    @State var showingColumnPicker = false

    /// Menus
    @State var showingSourcesMenu = false
    @State var showingPhotosMenu = false
    @State var showingAddLinkMenu = false
    @State var showingConfirmRemoveLinkMenu = false

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
                .fullScreenCover(isPresented: $showingColumnPicker) { columnPicker }
                .photosPicker(
                    isPresented: $showingPhotosPicker,
                    selection: $sourcesViewModel.selectedPhotos,
                    maxSelectionCount: sourcesViewModel.availableImagesCount,
                    matching: .images
                )
                .onChange(of: sourcesViewModel.columnSelectionInfo) { columnSelectionInfo in
                    if columnSelectionInfo != nil {
                        self.showingColumnPicker = true
                    }
                }
        }
        .bottomMenu(isPresented: $showingSourcesMenu, menu: sourcesMenu)
        .bottomMenu(isPresented: $showingPhotosMenu, menu: photosMenu)
        .bottomMenu(isPresented: $showingAddLinkMenu, menu: addLinkMenu)
        .bottomMenu(isPresented: $showingConfirmRemoveLinkMenu, menu: confirmRemoveLinkMenu)
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
