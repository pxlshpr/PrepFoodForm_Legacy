import SwiftUI
import NamePicker
import SwiftUISugar
import SwiftHaptics
import VisionSugar
import PrepDataTypes

struct SizeForm: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    let existingSizeViewModel: Field?
    
    /// This stores a copy of the data from fieldViewModel until we're ready to persist the change
    @StateObject var sizeViewModel: Field
    
    @StateObject var formViewModel: SizeFormViewModel
    @State var showingVolumePrefixToggle: Bool

    @State var shouldAnimateOptions = false
    @State var doNotRegisterUserInput: Bool = true

    @State var refreshBool = false

    var didAddSizeViewModel: ((Field) -> ())?

    init(fieldViewModel: Field? = nil,
         includeServing: Bool = true,
         allowAddSize: Bool = true,
         didAddSizeViewModel: ((Field) -> ())? = nil
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
            _sizeViewModel = StateObject(wrappedValue: Field.emptySize)
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
                sizeViewModel.registerUserInput()
                formViewModel.showingVolumePrefix = showingVolumePrefixToggle
                /// If we've turned it on and there's no volume prefix for the size—set it to cup
                if showingVolumePrefixToggle {
                    if sizeViewModel.value.size?.volumePrefixUnit == nil {
                        sizeViewModel.value.size?.volumePrefixUnit = .volume(.cup)
                    }
                } else {
                    sizeViewModel.value.size?.volumePrefixUnit = nil
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
//        .sheet(isPresented: $formViewModel.showingQuantityForm) { quantityForm }
//        .sheet(isPresented: $formViewModel.showingNamePicker) { nameForm }
//        .sheet(isPresented: $formViewModel.showingAmountForm) { amountForm }
//        .sheet(isPresented: $formViewModel.showingUnitPickerForVolumePrefix) { unitPickerForVolumePrefix }
//        .presentationDetents([.height(detentHeight), .large])
//        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(isDirty && !isEmpty)
        .onChange(of: sizeViewModel.sizeAmountUnit) { newValue in
            if !sizeViewModel.sizeAmountIsValid || !newValue.isWeightBased {
                sizeViewModel.value.size?.volumePrefixUnit = nil
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
    
    //MARK: - Actions
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .select:
            break
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            switch fill {
            case .prefill(let info):
                guard let size = info.size else { return }
                setSize(size)
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
    
    func setSize(_ size: FormSize) {
        sizeViewModel.value.size?.quantity = size.quantity
        sizeViewModel.value.size?.volumePrefixUnit = size.volumePrefixUnit
        sizeViewModel.value.size?.name = size.name
        sizeViewModel.value.size?.amount = size.amount
        sizeViewModel.value.size?.unit = size.unit
        showingVolumePrefixToggle = sizeViewModel.value.size?.volumePrefixUnit != nil
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
            get: { sizeViewModel.value.string },
            set: {
                if $0 != sizeViewModel.value.string {
                    withAnimation {
                        sizeViewModel.registerUserInput()
                    }
                }
                sizeViewModel.value.string = $0
            }
        )

        return NavigationView {
            NamePicker(
                name: binding,
                showClearButton: true,
                focusOnAppear: true,
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
            sizeViewModel.value.size?.volumePrefixUnit = unit
        }
        .environmentObject(viewModel)
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    //MARK: - Helpers
    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.id == sizeViewModel.fill.imageId })
    }

    var detentHeight: CGFloat {
        viewModel.shouldShowFillOptions(for: sizeViewModel.value) ? 600 : 400
    }
    
    var isEmpty: Bool {
        sizeViewModel.value.isEmpty
    }
    
    var isEditing: Bool {
        existingSizeViewModel != nil
    }
    
    var isDirty: Bool {
        existingSizeViewModel?.value != sizeViewModel.value
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
