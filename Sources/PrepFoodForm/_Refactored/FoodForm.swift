import SwiftUI
import SwiftUISugar
import Combine
import FoodLabelScanner


public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    let didSave: (FoodFormData) -> ()
    
    @State var emoji: String = ""
    @State var name: String = ""
    @State var detail: String = ""
    @State var brand: String = ""
    
    @State var showingEmojiPicker = false
    @State var showingCamera = false
    @State var showingFoodLabelCamera = false
    @State var showingPhotosPicker = false
    @State var showingPrefill = false
    @State var showingPrefillInfo = false

    @State var shouldShowWizard = true
    @State var showingWizard = true
    @State var showingWizardOverlay = true
    @State var formDisabled = false

    @State var imageViewModels: [ImageViewModel] = []
    @State var imageSetStatus: ImageStatus = .loading

    @State var twoColumnOutput: ScanResultsTwoColumnOutput? = nil
    @State var selectedScanResultsColumn = 1

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
                .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
                .sheet(isPresented: $showingFoodLabelCamera) { foodLabelCamera }
                .fullScreenCover(item: $twoColumnOutput) { columnPicker($0) }
        }
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
