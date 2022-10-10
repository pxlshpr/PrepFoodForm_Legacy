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

    /// We're using this to delay animations to the `FlowLayout` used in the `FillOptionsGrid` until after the view appears—otherwise, we get a noticeable animation of its height expanding to fit its contents during the actual presentation animation—which looks a bit jarring.
    @State var shouldAnimateOptions = false

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { bottomToolbarContent }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shouldAnimateOptions = true
            }
        }
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
    
    var detentHeight: CGFloat {
        viewModel.shouldShowFillOptions(for: sizeViewModel.fieldValue) ? 600 : 400
    }
    
    var isEmpty: Bool {
        sizeViewModel.fieldValue.isEmpty
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }

    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Button(isEditing ? "Save" : "Add") {
                if let existingSizeViewModel {
                    viewModel.edit(existingSizeViewModel, with: sizeViewModel)
                } else {
                    viewModel.add(sizeViewModel: sizeViewModel)
                    if let didAddSizeViewModel = didAddSizeViewModel {
                        didAddSizeViewModel(sizeViewModel)
                    }
                }
                
                /// Call this in case a unit change changes whether we show the density or not
                viewModel.updateShouldShowDensitiesSection()
                
                dismiss()
            }
            .disabled(!sizeViewModel.isValid || !isDirty)
            .id(refreshBool)
        }
    }
    
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
//                showTextPicker()
            }, didTapFillOption: { fillOption in
//                didTapFillOption(fillOption)
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
    
    var isEditing: Bool {
        existingSizeViewModel != nil
    }
    
    var isDirty: Bool {
        existingSizeViewModel?.fieldValue != sizeViewModel.fieldValue
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
        NavigationView {
            NamePicker(
                name: $sizeViewModel.fieldValue.string,
                showClearButton: true,
                focusImmediately: true,
                lowercased: true,
                presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
            )
            .navigationTitle("Size Name")
            .navigationBarTitleDisplayMode(.inline)
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
