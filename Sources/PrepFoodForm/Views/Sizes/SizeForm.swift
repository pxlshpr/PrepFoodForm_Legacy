import SwiftUI
import NamePicker
import SwiftUISugar
import SwiftHaptics

struct SizeForm: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    let existingSizeViewModel: FieldViewModel?
    
    /// This stores a copy of the data from fieldViewModel until we're ready to persist the change
    @StateObject var sizeViewModel: FieldViewModel
    
    @StateObject var formViewModel: SizeFormViewModel
    @State var showingVolumePrefixToggle: Bool

    @State var shouldAnimateOptions = false
    @State var showingTextPicker = false
    @State var doNotRegisterUserInput: Bool = true

    @State var refreshBool = false

    var didAddSizeViewModel: ((FieldViewModel) -> ())?

    init(fieldViewModel: FieldViewModel? = nil,
         includeServing: Bool = true,
         allowAddSize: Bool = true,
         didAddSizeViewModel: ((FieldViewModel) -> ())? = nil
    ) {
        let formViewModel = SizeFormViewModel(
            includeServing: includeServing,
            allowAddSize: allowAddSize,
            formState: fieldViewModel == nil ? .empty : .noChange
        )
        _formViewModel = StateObject(wrappedValue: formViewModel)

        self.existingSizeViewModel = fieldViewModel
        
        if let fieldViewModel {
            _showingVolumePrefixToggle = State(initialValue: fieldViewModel.size?.isVolumePrefixed ?? false)
            _sizeViewModel = StateObject(wrappedValue: fieldViewModel.copy)
        } else {
            _showingVolumePrefixToggle = State(initialValue: false)
            _sizeViewModel = StateObject(wrappedValue: FieldViewModel.emptySize)
        }
        
        self.didAddSizeViewModel = didAddSizeViewModel
    }

    var body: some View {
        NavigationView {
            form
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("\(isEditing ? "Edit" : "New") Size")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { navigationTrailingContent }
            .toolbar { navigationLeadingContent }
        }
//        .onChange(of: sizeFormViewModel.quantityString) { newValue in
//            sizeFormViewModel.quantity = Double(newValue) ?? 0
//        }
//        .onChange(of: sizeFormViewModel.quantity) { newValue in
//            sizeFormViewModel.quantityString = "\(newValue.cleanAmount)"
//        }
        .onChange(of: showingVolumePrefixToggle) { newValue in
            withAnimation {
                formViewModel.showingVolumePrefix = showingVolumePrefixToggle
                /// If we've turned it on and there's no volume prefix for the size—set it to cup
                if showingVolumePrefixToggle {
                    if sizeViewModel.fieldValue.size?.volumePrefixUnit == nil {
                        sizeViewModel.fieldValue.size?.volumePrefixUnit = .volume(.cup)
                    }
                } else {
                    sizeViewModel.fieldValue.size?.volumePrefixUnit = nil
                }
//                formViewModel.updateFormState(of: sizeViewModel, comparedToExisting: existingSizeViewModel)
            }
        }
        .onAppear {
            if let existingSizeViewModel {
                viewModel.sizeBeingEdited = existingSizeViewModel.size
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shouldAnimateOptions = true
//                doNotRegisterUserInput = true
            }
        }
        .sheet(isPresented: $showingTextPicker) { textPicker }
        .sheet(isPresented: $formViewModel.showingQuantityForm) { quantityForm }
        .sheet(isPresented: $formViewModel.showingNamePicker) { nameForm }
        .sheet(isPresented: $formViewModel.showingAmountForm) { amountForm }
        .sheet(isPresented: $formViewModel.showingUnitPickerForVolumePrefix) { unitPickerForVolumePrefix }
        .presentationDetents([.height(detentHeight), .large])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(isDirty && !isEmpty)
        .onChange(of: sizeViewModel.sizeAmountUnit) { newValue in
            if !sizeViewModel.sizeAmountIsValid || !newValue.isWeightBased {
                sizeViewModel.fieldValue.size?.volumePrefixUnit = nil
            }
        }
    }
    
    //MARK: - Views
    
    var form: some View {
        FormStyledScrollView {
            FormStyledSection {
                SizeFormField(sizeViewModel: sizeViewModel, existingSizeViewModel: existingSizeViewModel)
                .environmentObject(viewModel)
                .environmentObject(formViewModel)
            }
            if sizeViewModel.sizeAmountUnit.unitType == .weight || !sizeViewModel.sizeAmountIsValid {
                volumePrefixSection
            }
            fillOptionsSections
        }
    }

    var fillOptionsSections: some View {
        FillOptionsSections(
            fieldViewModel: sizeViewModel,
            shouldAnimate: $shouldAnimateOptions,
            didTapImage: {
                showTextPicker()
            }, didTapFillOption: { fillOption in
                didTapFillOption(fillOption)
            })
        .environmentObject(viewModel)
    }
    
    var volumePrefixSection: some View {
        var footer: some View {
            Text("This will let you log this food in volumes of different densities or thicknesses, like – ‘cups shredded’, ‘cups sliced’.")
                .foregroundColor(!formViewModel.showingVolumePrefix ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return FormStyledSection(footer: footer) {
            Toggle("Volume-prefixed name", isOn: $showingVolumePrefixToggle)
        }
    }

    //TODO: Remove this after showing a warning for existing sizes
    var bottomElements: some View {
        
        @ViewBuilder
        var statusElement: some View {
            switch formViewModel.formState {
            case .okToSave:
                VStack {
//                    addButton
//                    if didAddSizeViewModel == nil && !isEditing {
//                        addAndAddAnotherButton
//                    }
                }
                .transition(.move(edge: .bottom))
            case .duplicate:
                Label("There already exists a size with this name.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(.secondaryLabel))
                    .symbolRenderingMode(.multicolor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .foregroundColor(Color(.tertiarySystemFill))
                    )
                    .padding(.top)
                    .transition(.move(edge: .bottom))
            default:
                EmptyView()
            }
        }
        
        return ZStack {
            Color(.systemGroupedBackground)
            statusElement
                .padding(.bottom, 34)
                .zIndex(1)
        }
        .edgesIgnoringSafeArea(.bottom)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }

    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    
    var saveButton: some View {
        Button(isEditing ? "Save" : "Add") {
            saveAndDismiss()
        }
        .disabled(!sizeViewModel.isValid || !isDirty)
        .id(refreshBool)
    }
    
    var textPicker: some View {
        TextPicker(
            imageViewModels: viewModel.imageViewModels,
            selectedText: sizeViewModel.fill.text,
            selectedImageIndex: selectedImageIndex
//            customTextFilter: textPickerFilter
        ) { selectedImageTexts in
            didSelectImageTexts(selectedImageTexts)
        }
        .onDisappear {
            guard sizeViewModel.isCroppingNextImage else {
                return
            }
            sizeViewModel.cropFilledImage()
            doNotRegisterUserInput = false
       }
    }
    
    //MARK: - Actions
    func didSelectImageTexts(_ imageTexts: [ImageText]) {
        
//        guard let imageText = imageTexts.first else {
//            return
//        }
//
//        guard let densityValue = imageText.text.string.detectedValues.densityValue else {
//            return
//        }
//
//        let fill = fill(for: imageText, with: densityValue)
//
//        doNotRegisterUserInput = true
//
//        //Now set this fill on the density value
//        setDensityValue(densityValue)
//        densityViewModel.fieldValue.fill = fill
//        densityViewModel.isCroppingNextImage = true
    }
    
    func showTextPicker() {
        Haptics.feedback(style: .soft)
        doNotRegisterUserInput = true
        showingTextPicker = true
    }

    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .select:
            didTapSelect()
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            switch fill {
//            case .prefill(let info):
//                guard let densityValue = info.densityValue else {
//                    return
//                }
//                setDensityValue(densityValue)
            case .scanned(let info):
                guard let size = info.size else { return }
                setSize(size)
                sizeViewModel.assignNewScannedFill(fill)
            default:
                break
            }
            doNotRegisterUserInput = false
        }
    }
    
    func setSize(_ size: Size) {
        sizeViewModel.fieldValue.size?.quantity = size.quantity
        sizeViewModel.fieldValue.size?.volumePrefixUnit = size.volumePrefixUnit
        sizeViewModel.fieldValue.size?.name = size.name
        sizeViewModel.fieldValue.size?.amount = size.amount
        sizeViewModel.fieldValue.size?.unit = size.unit
    }
    
    func didTapSelect() {
        showTextPicker()
    }

    func saveAndDismiss() {
        doNotRegisterUserInput = true
        
//        existingSizeViewModel?.copyData(from: sizeViewModel)
        
        if let existingSizeViewModel {
            viewModel.edit(existingSizeViewModel, with: sizeViewModel)
        } else {
            if viewModel.add(sizeViewModel: sizeViewModel),
               let didAddSizeViewModel = didAddSizeViewModel
            {
                didAddSizeViewModel(sizeViewModel)
            }
        }
        
        /// Call this in case a unit change changes whether we show the density or not
        viewModel.updateShouldShowDensitiesSection()
        
        dismiss()
    }

    //MARK: - Sheets
    var quantityForm: some View {
        NavigationView {
            SizeQuantityForm(sizeViewModel: sizeViewModel)
        }
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    var nameForm: some View {
        let binding = Binding<String>(
            get: { sizeViewModel.fieldValue.string },
            set: {
                if $0 != sizeViewModel.fieldValue.string {
                    withAnimation {
                        sizeViewModel.registerUserInput()
                    }
                }
                sizeViewModel.fieldValue.string = $0
            }
        )

        return NavigationView {
            NamePicker(
                name: binding,
                showClearButton: true,
                focusImmediately: true,
                lowercased: true,
                title: "Size Name",
                titleDisplayMode: .large,
                presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
            )
        }
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    var amountForm: some View {
        NavigationView {
            SizeAmountForm(sizeViewModel: sizeViewModel)
                .environmentObject(viewModel)
                .environmentObject(formViewModel)
        }
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    var unitPickerForVolumePrefix: some View {
        UnitPicker(
            pickedUnit: sizeViewModel.sizeVolumePrefixUnit,
            filteredType: .volume)
        { unit in
            sizeViewModel.fieldValue.size?.volumePrefixUnit = unit
        }
        .environmentObject(viewModel)
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    //MARK: - Helpers
    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == sizeViewModel.fill.resultId })
    }

    var detentHeight: CGFloat {
        viewModel.shouldShowFillOptions(for: sizeViewModel.fieldValue) ? 600 : 400
    }
    
    var isEmpty: Bool {
        sizeViewModel.fieldValue.isEmpty
    }
    
    var isEditing: Bool {
        existingSizeViewModel != nil
    }
    
    var isDirty: Bool {
        existingSizeViewModel?.fieldValue != sizeViewModel.fieldValue
    }

}

struct SizeForm_NewPreview: View {
    @StateObject var viewModel = FoodFormViewModel.shared
    var body: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    SizeForm()
                        .environmentObject(viewModel)
                }
        }
    }
}

struct SizeForm_New_Previews: PreviewProvider {
    static var previews: some View {
        SizeForm_NewPreview()
    }
}
