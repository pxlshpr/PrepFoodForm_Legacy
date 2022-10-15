import SwiftUI
import SwiftHaptics
import PrepUnits
import PhotosUI
import Camera
import EmojiPicker
import SwiftUISugar
import FoodLabelCamera

let WizardAnimation = Animation.interpolatingSpring(mass: 0.5, stiffness: 120, damping: 10, initialVelocity: 2)

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingThirdPartyInfo = false
    @State var showingPhotosPicker = false
    
    public init() {
        _viewModel = StateObject(wrappedValue: FoodFormViewModel.shared)
    }
    
    public var body: some View {
        NavigationView {
            content
                .navigationTitle("New Food")
                .interactiveDismissDisabled(disableDismiss)
                .onAppear {
                    if viewModel.shouldShowWizard {
                        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.6) {
                            Haptics.transientHaptic()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(WizardAnimation) {
                            if viewModel.shouldShowWizard {
                                viewModel.showingWizard = true
                                viewModel.shouldShowWizard = false
                            }
                        }
                    }
                }
                .onChange(of: viewModel.selectedPhotos) { newValue in
                    viewModel.selectedPhotosChanged(to: newValue)
                    withAnimation {
                        viewModel.showingWizard = false
                    }
                }
                .sheet(isPresented: $viewModel.showingCamera) {
                    Camera { image in
                        viewModel.didCapture(image)
                    }
                }
                .sheet(isPresented: $viewModel.showingFoodLabelCamera) {
                    FoodLabelCamera { scanResult, image in
                        viewModel.didScan(image, scanResult: scanResult)
                    }
                }
                .sheet(isPresented: $viewModel.showingEmojiPicker) {
                    EmojiPicker(
                        categories: [.foodAndDrink, .animalsAndNature],
                        focusOnAppear: true
                    ) { emoji in
                        Haptics.feedback(style: .rigid)
                        viewModel.emojiViewModel.fieldValue.stringValue.string = emoji
                        viewModel.showingEmojiPicker = false
                    }
                }
            /// These are requird to update the `FoodLabel` as a view update isn't triggered otherwise
                .onReceive(viewModel.energyViewModel.$fieldValue) { publisher in
                    viewModel.energyValue = viewModel.energyViewModel.fieldValue.value ?? .zero
                }
                .photosPicker(
                    isPresented: $showingPhotosPicker,
                    selection: $viewModel.selectedPhotos,
                    maxSelectionCount: 5,
                    matching: .images
                )
        }
        .bottomMenu(isPresented: $viewModel.showingSourceMenu, actionGroups: sourceMenuActionGroups)
        .bottomMenu(isPresented: $viewModel.showingPhotosMenu, actionGroups: photosActionGroups)
        .bottomMenu(isPresented: $viewModel.showingAddLinkMenu, actionGroups: addLinkActionGroups)
        .bottomMenu(isPresented: $viewModel.showingRemoveLinkConfirmation, actionGroups: removeLinkActionGroups)
        .bottomMenu(isPresented: $viewModel.showingRemoveImagesConfirmation, actionGroups: removeAllImagesActionGroups)
    }
    
    var photosActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(title: "Scan a Food Label", systemImage: "text.viewfinder", tapHandler: {
                viewModel.showingFoodLabelCamera = true
            }),
            BottomMenuAction(title: "Take Photos", systemImage: "camera", tapHandler: {
                viewModel.showingCamera = true
            }),
            BottomMenuAction(title: "Choose Photos", systemImage: SourceType.images.systemImage, tapHandler: {
                showingPhotosPicker = true
            }),
        ]]
    }
    
    var addLinkActionGroups: [[BottomMenuAction]] {
        [[addLinkMenuAction]]
    }

    var removeAllImagesActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "Remove All Images",
                role: .destructive,
                tapHandler: {
                    withAnimation {
                        viewModel.removeAllImages()
                    }
                }
            )
        ]]
    }

    var removeLinkActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "Remove Link",
                role: .destructive,
                tapHandler: {
                    withAnimation {
                        viewModel.removeSourceLink()
                    }
                }
            )
        ]]
    }

    var addLinkMenuAction: BottomMenuAction {
        BottomMenuAction(
            title: "Add a Link",
            systemImage: "link",
            placeholder: "https://fastfood.com/nutrition-facts.pdf",
            keyboardType: .URL,
            submitString: "Add Link",
            autocapitalization: .never,
            textInputIsValid: textInputIsValidHandler,
            textInputHandler:
                { string in
                    viewModel.submittedSourceLink(string)
                }
        )
    }
    
    func textInputIsValidHandler(_ string: String) -> Bool {
        string.isValidURL
    }

    var sourceMenuActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Scan a Food Label", systemImage: "text.viewfinder", tapHandler: {
                    viewModel.showingFoodLabelCamera = true
                }),
                BottomMenuAction(title: "Take Photos", systemImage: "camera", tapHandler: {
                    viewModel.showingCamera = true
                }),
                BottomMenuAction(title: "Choose Photos", systemImage: "photo.on.rectangle", tapHandler: {
                    showingPhotosPicker = true
                }),
            ],
            [addLinkMenuAction]
        ]
    }

    
    var disableDismiss: Bool {
        viewModel.hasEnoughData || viewModel.showingSourceMenu
    }
    
    var content: some View {
        ZStack {
            form
                .safeAreaInset(edge: .bottom) {
                    //TODO: Programmatically get this inset (67516AA6)
                    Spacer().frame(height: 150)
                }
                .overlay(
                    Color(.quaternarySystemFill)
                        .opacity(viewModel.showingWizard ? 0.3 : 0)
                    //                        .onTapGesture {
                    //                            Haptics.successFeedback()
                    //                            withAnimation(wizardAnimation) {
                    //                                showingWizard = false
                    //                            }
                    //                        }
                )
                .blur(radius: viewModel.showingWizard ? 5 : 0)
                .disabled(viewModel.showingWizard)
            //            dismissTapGesture
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
    var wizard: some View {
        if viewModel.showingWizard {
            VStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        startWithEmptyFood()
                    }
                Form {
                    manualEntrySection
                    imageSection
                    //                    simulateSection
                    thirdPartyFoodSection
                }
                //                .scrollContentBackground(.hidden)
                //                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .frame(height: 420)
                .frame(maxWidth: 350)
                .padding(.horizontal, 30)
                .shadow(color: colorScheme == .dark ? .black : .gray, radius: 30, x: 0, y: 0)
                .opacity(viewModel.showingWizard ? 1 : 0)
                //            .padding(.bottom)
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        startWithEmptyFood()
                    }
            }
            .zIndex(1)
            .transition(.move(edge: .bottom))
        }
    }
    
    @ViewBuilder
    var saveButtons: some View {
        if viewModel.hasEnoughData {
            VStack(spacing: 0) {
                Divider()
                VStack {
                    if viewModel.shouldShowSavePublicButton {
                        FormPrimaryButton(title: "Add to Public Database") {
                            dismiss()
                        }
                        .padding(.top)
                        FormSecondaryButton(title: "Add to Private Database") {
                            dismiss()
                        }
                    } else {
                        FormPrimaryButton(title: "Add to Private Database") {
                            dismiss()
                        }
                        .padding(.top)
                    }
                }
                /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
                .padding(.bottom, 30)
            }
            //            .background(Color(.systemGroupedBackground))
            .background(.thinMaterial)
        }
    }
    
    @ViewBuilder
    var form: some View {
        FormStyledScrollView {
            detailsSection
            servingSection
            foodLabelSection
            sourceSection
            prefillSection
        }
    }
    
    func startWithEmptyFood() {
        Haptics.transientHaptic()
        withAnimation(WizardAnimation) {
            viewModel.showingWizard = false
        }
    }
    
    //MARK: - Wizard Contents
    var manualEntrySection: some View {
        Section("Start with an empty food") {
            Button {
                startWithEmptyFood()
            } label: {
                Label("Empty Food", systemImage: "square.and.pencil")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var imageSection: some View {
        var header: some View {
            Text("Scan food labels")
        }
        var footer: some View {
            Text("Provide images of nutrition fact labels or screenshots of other apps. These will be processed to extract any data from them. They will also be used to verify this food.")
        }
        
        return Section(header: header) {
            foodLabelCameraButton
            cameraButton
            photosPickerButton
        }
    }
    
    var cameraButton: some View {
        Button {
            viewModel.showingCamera = true
        } label: {
            Label("Take Photos", systemImage: "camera")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
    }

    var foodLabelCameraButton: some View {
        Button {
            viewModel.showingFoodLabelCamera = true
        } label: {
            Label("Scan a Food Label", systemImage: "text.viewfinder")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
    }

    var simulateSection: some View {
        Section {
            simulateButton
        }
    }
    
    var simulateButton: some View {
        Button {
            //            viewModel.simulateImageSelection()
            viewModel.simulateImageScanning([9])
        } label: {
            Label("Mock Photos", systemImage: "wand.and.rays")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
    }
    
    var photosPickerButton: some View {
        Button {
            showingPhotosPicker = true
        } label: {
            Label("Choose Photos", systemImage: SourceType.images.systemImage)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var thirdPartyFoodSection: some View {
        var header: some View {
            Text("Prefill a third-party food")
        }
        var footer: some View {
            Button {
                showingThirdPartyInfo = true
            } label: {
                Label("Learn more", systemImage: "info.circle")
                    .font(.footnote)
            }
            .sheet(isPresented: $showingThirdPartyInfo) {
                MFPInfoSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        return Section(header: header, footer: footer) {
            Button {
                viewModel.showingThirdPartySearch = true
                //                viewModel.simulateThirdPartyImport()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
        }
    }
    
    //MARK: - FoodForm Contents
    
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                DetailsForm()
                .environmentObject(viewModel)
            } label: {
                DetailsCell()
                    .environmentObject(viewModel)
                    .buttonStyle(.borderless)
            }
        }
    }
    
    var servingSection: some View {
        FormStyledSection(header: Text("Amount Per")) {
            NavigationLink {
                AmountPerForm()
                    .environmentObject(viewModel)
            } label: {
                NutrientsPerCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var foodLabelSection: some View {
        @ViewBuilder
        var header: some View {
            if !viewModel.hasNutritionFacts {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
                NutritionFactsList()
                    .environmentObject(viewModel)
            } label: {
                NutritionFactsCell()
                    .environmentObject(viewModel)
                    .buttonStyle(.borderless)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var sourceSection: some View {
        SourceSection()
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var prefillSection: some View {
        if let url = viewModel.prefilledFood?.sourceUrl {
            FormStyledSection(header: Text("Prefilled Food")) {
                NavigationLink {
                    SourceWebView(urlString: url)
                } label: {
                    LinkCell(LinkInfo("https://myfitnesspal.com")!, title: "MyFitnessPal")
                }
            }
        }
    }
    
    var servingCell: some View {
        Text("Set serving")
    }
    
    var nutrientsCell: some View {
        FoodForm.NutrientsCell()
    }
    
    var foodLabelScanCell: some View {
        //        Label("Scan food label", systemImage: "text.viewfinder")
        HStack {
            Text("Scan food label")
            Spacer()
            Image(systemName: "text.viewfinder")
        }
    }
    
    var sourceCell: some View {
        Text("Add source")
    }
}
