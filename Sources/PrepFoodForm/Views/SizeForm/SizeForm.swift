import SwiftUI
import NamePicker
import SwiftUISugar
import SwiftHaptics

extension FieldValueViewModel {
    static var emptySize: FieldValueViewModel {
        .init(fieldValue: .size(.init(size: Size(), fillType: .userInput)))
    }
}

class SizeFormViewModel: ObservableObject {
    @Published var includeServing: Bool
    @Published var allowAddSize: Bool
    @Published var showingVolumePrefix: Bool
    @Published var formState: FormState
    
    init(includeServing: Bool, allowAddSize: Bool, formState: FormState) {
        self.includeServing = includeServing
        self.allowAddSize = allowAddSize
        self.formState = formState
        self.showingVolumePrefix = false
    }
    
    func updateFormState(of sizeViewModel: FieldValueViewModel, comparedToExisting existingSizeViewModel: FieldValueViewModel? = nil) {
        let newFormState = sizeViewModel.formState(existingFieldValueViewModel: existingSizeViewModel)
        guard self.formState != newFormState else {
            return
        }
        
        let animation = Animation.interpolatingSpring(
            mass: 0.5,
            stiffness: 220,
            damping: 10,
            initialVelocity: 2
        )

        withAnimation(animation) {
//        withAnimation(.easeIn(duration: 4)) {
            self.formState = newFormState
            print("Updated form state from \(self.formState) to \(newFormState)")

            switch formState {
            case .okToSave:
                Haptics.successFeedback()
            case .invalid:
                Haptics.errorFeedback()
            case .duplicate:
                Haptics.warningFeedback()
            default:
                break
            }
        }
    }
}

struct SizeForm: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    let existingSizeViewModel: FieldValueViewModel?
    
    /// This stores a copy of the data from fieldValueViewModel until we're ready to persist the change
    @StateObject var sizeViewModel: FieldValueViewModel
    
    @StateObject var formViewModel: SizeFormViewModel
    @State var showingVolumePrefixToggle: Bool = false

    var didAddSizeViewModel: ((FieldValueViewModel) -> ())?

    init(fieldValueViewModel: FieldValueViewModel? = nil,
         includeServing: Bool = true,
         allowAddSize: Bool = true,
         didAddSizeViewModel: ((FieldValueViewModel) -> ())? = nil
    ) {
        let formViewModel = SizeFormViewModel(
            includeServing: includeServing,
            allowAddSize: allowAddSize,
            formState: fieldValueViewModel == nil ? .empty : .noChange
        )
        _formViewModel = StateObject(wrappedValue: formViewModel)

        self.existingSizeViewModel = fieldValueViewModel
        
        if let fieldValueViewModel {
            _sizeViewModel = StateObject(wrappedValue: fieldValueViewModel.copy)
        } else {
            _sizeViewModel = StateObject(wrappedValue: FieldValueViewModel.emptySize)
        }
        
        self.didAddSizeViewModel = didAddSizeViewModel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                form
                bottomElements
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("\(isEditing ? "Edit" : "Add") Size")
            .navigationBarTitleDisplayMode(.inline)
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
                if showingVolumePrefixToggle, sizeViewModel.fieldValue.size?.volumePrefixUnit == nil {
                    sizeViewModel.fieldValue.size?.volumePrefixUnit = .volume(.cup)
                }
                formViewModel.updateFormState(of: sizeViewModel, comparedToExisting: existingSizeViewModel)
            }
        }
    }
    
    var form: some View {
        FormStyledScrollView {
            FormStyledSection {
                SizeFormField(sizeViewModel: sizeViewModel, existingSizeViewModel: existingSizeViewModel)
                .environmentObject(viewModel)
                .environmentObject(formViewModel)
            }
            if sizeViewModel.sizeAmountString.isEmpty || sizeViewModel.sizeAmountUnit.unitType == .weight {
                volumePrefixSection
            }
        }
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
                    addButton
                    if didAddSizeViewModel == nil && !isEditing {
                        addAndAddAnotherButton
                    }
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
    
    var addButtonTitle: String {
        guard !isEditing else {
            return "Save"
        }
        return didAddSizeViewModel == nil ? "Add" : "Add and Select"
    }
    
    var addButton: some View {
        return FormPrimaryButton(title: addButtonTitle) {
            if let didAddSizeViewModel = didAddSizeViewModel {
                didAddSizeViewModel(sizeViewModel)
            }
            if let existingSizeViewModel {
                viewModel.edit(existingSizeViewModel, with: sizeViewModel)
            } else {
                viewModel.add(sizeViewModel: sizeViewModel)
            }
            dismiss()
        }
    }

    var addAndAddAnotherButton: some View {
        FormSecondaryButton(title: "Add and Add Another") {
            
        }
    }

    var isEditing: Bool {
        existingSizeViewModel != nil
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
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.hidden)
                }
        }
    }
}

struct SizeForm_New_Previews: PreviewProvider {
    static var previews: some View {
        SizeForm_NewPreview()
    }
}
