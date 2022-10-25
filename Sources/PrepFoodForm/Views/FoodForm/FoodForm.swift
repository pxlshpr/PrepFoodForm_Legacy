import SwiftUI
import SwiftHaptics
import PrepDataTypes
import PhotosUI
import Camera
import EmojiPicker
import SwiftUISugar
import FoodLabelCamera
import RSBarcodes_Swift

//let WizardAnimation = Animation.interpolatingSpring(mass: 0.5, stiffness: 120, damping: 10, initialVelocity: 2)
let WizardAnimation = Animation.easeIn(duration: 0.2)

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FoodFormViewModel
    @State var showingThirdPartyInfo = false
    @State var showingPhotosPicker = false
    
    public init() {
        _viewModel = StateObject(wrappedValue: FoodFormViewModel.shared)
    }
    
    public var body: some View {
        NavigationView {
            content
                .navigationTitle("New Food")
                .toolbar { navigationLeadingContent }
                .interactiveDismissDisabled(disableDismiss)
                .onAppear(perform: appeared)
                .onChange(of: viewModel.selectedPhotos, perform: viewModel.selectedPhotosChanged)
                .sheet(isPresented: $viewModel.showingCamera) { cameraSheet }
                .sheet(isPresented: $viewModel.showingBarcodeScanner) { barcodeScannerSheet }
                .sheet(isPresented: $viewModel.showingFoodLabelCamera) { foodLabelCameraSheet }
                .sheet(isPresented: $viewModel.showingEmojiPicker) { emojiPickerSheet }
                .photosPicker(
                    isPresented: $showingPhotosPicker,
                    selection: $viewModel.selectedPhotos,
                    maxSelectionCount: viewModel.availableImagesCount,
                    matching: .images
                )
        }
        .bottomMenu(isPresented: $viewModel.showingSourceMenu, actionGroups: sourceMenuActionGroups)
        .bottomMenu(isPresented: $viewModel.showingPhotosMenu, actionGroups: photosActionGroups)
        .bottomMenu(isPresented: $viewModel.showingAddLinkMenu, actionGroups: addLinkActionGroups)
        .bottomMenu(isPresented: $viewModel.showingRemoveLinkConfirmation, actionGroups: removeLinkActionGroups)
        .bottomMenu(isPresented: $viewModel.showingRemoveImagesConfirmation, actionGroups: removeAllImagesActionGroups)
        .bottomMenu(isPresented: $viewModel.showingAutofillMenu, actionGroups: autofillActionGroups)
        .bottomMenu(isPresented: $viewModel.showingAddBarcodeMenu, actionGroups: addBarcodeActionGroups)
        .fullScreenCover(isPresented: $viewModel.showingColumnPicker) { columnPicker }
    }
    
    //MARK: - Main Content
    
    var content: some View {
        ZStack {
            form
                .safeAreaInset(edge: .bottom) {
                    //TODO: Programmatically get this inset (67516AA6)
                    Spacer().frame(height: 150)
                }
                .overlay(
                    Color(.quaternarySystemFill)
                        .opacity(viewModel.showingWizardOverlay ? 0.3 : 0)
//                        .onTapGesture {
//                            Haptics.successFeedback()
//                            withAnimation(wizardAnimation) {
//                                showingWizard = false
//                            }
//                        }
                )
                .blur(radius: viewModel.showingWizardOverlay ? 5 : 0)
                .disabled(viewModel.formDisabled)
            wizard
            VStack {
                Spacer()
                saveButtons
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $viewModel.showingThirdPartySearch) {
            MFPSearch()
                .environmentObject(viewModel)
        }
    }
    
    @ViewBuilder
    var form: some View {
        FormStyledScrollView {
            detailsSection
            servingSection
            foodLabelSection
            barcodesSection
            sourceSection
            prefillSection
        }
    }
    
    //MARK: - Views
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
    }
    
    @ViewBuilder
    var saveButtons: some View {
        if viewModel.shouldShowSaveButtons {
            VStack(spacing: 0) {
                Divider()
                VStack {
                    if viewModel.shouldShowSavePublicButton {
                        FormPrimaryButton(title: "Add to Public Database") {
                            FoodFormData.save(viewModel)
                            dismiss()
                        }
                        .padding(.top)
                        FormSecondaryButton(title: "Add to Private Database") {
                            dismiss()
                        }
                    } else {
                        FormSecondaryButton(title: "Add to Private Database") {
//                        FormPrimaryButton(title: "Add to Private Database") {
                            dismiss()
                        }
                        .padding(.vertical)
                    }
                }
                /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
                .padding(.bottom, 30)
            }
            .background(.thinMaterial)
        }
    }
    
    //MARK: - Actions
    func appeared() {
        if viewModel.shouldShowWizard {
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0) {
                Haptics.transientHaptic()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                if viewModel.shouldShowWizard {
                    withAnimation(WizardAnimation) {
                        viewModel.formDisabled = true
                        viewModel.showingWizard = true
                        viewModel.shouldShowWizard = false
                    }
                } else {
                    viewModel.showingWizard = false
                    viewModel.showingWizardOverlay = false
                    viewModel.formDisabled = false
                }
//                        withAnimation(.easeOut(duration: 0.1)) {
//                            viewModel.showingWizardOverlay = true
//                        }
        }
    }
    
    func startWithEmptyFood() {
        Haptics.transientHaptic()
        viewModel.dismissWizard()
    }
    
    //MARK: - Helpers
    func isValidBarcode(_ string: String) -> Bool {
        let isValid = RSUnifiedCodeValidator.shared.isValid(
            string,
            machineReadableCodeObjectType: AVMetadataObject.ObjectType.ean13.rawValue)
        let exists = viewModel.contains(barcode: string)
        return isValid && !exists
    }
    
    func textInputIsValidHandler(_ string: String) -> Bool {
        string.isValidUrl
    }

    var disableDismiss: Bool {
        viewModel.hasSomeData || viewModel.showingSourceMenu
    }
}
