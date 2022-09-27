import SwiftUI
import NamePicker

struct SizeForm: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var sizeFormViewModel: SizeFormViewModel
    @State var showingVolumePrefixToggle: Bool = false
    
    var isEditing: Bool
    var didAddSize: ((NewSize) -> ())?
    
    init(includeServing: Bool = true, allowAddSize: Bool = true, existingSize: NewSize? = nil, didAddSize: ((NewSize) -> ())? = nil) {
        
        self.didAddSize = didAddSize
        
        self.isEditing = existingSize != nil
        
        let sizeFormViewModel = SizeFormViewModel(
            includeServing: includeServing,
            allowAddSize: allowAddSize,
            existingSize: existingSize
        )
        _sizeFormViewModel = StateObject(wrappedValue: sizeFormViewModel)
    }
    
    var body: some View {
        NavigationStack(path: $sizeFormViewModel.path) {
            VStack(spacing: 0) {
                form
                bottomElements
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("\(isEditing ? "Edit" : "Add") Size")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: sizeFormViewModel.quantityString) { newValue in
            sizeFormViewModel.quantity = Double(newValue) ?? 0
        }
        .onChange(of: sizeFormViewModel.quantity) { newValue in
            sizeFormViewModel.quantityString = "\(newValue.cleanAmount)"
        }
        .onChange(of: showingVolumePrefixToggle) { newValue in
            withAnimation {
                sizeFormViewModel.showingVolumePrefix = showingVolumePrefixToggle
            }
        }
    }
    
    var bottomElements: some View {
        
        @ViewBuilder
        var statusElement: some View {
            switch sizeFormViewModel.formState {
            case .okToSave:
                VStack {
                    addButton
                    if didAddSize == nil && !isEditing {
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
        
    var form: some View {
        Form {
            SizeField()
                .environmentObject(sizeFormViewModel)
            if sizeFormViewModel.amountString.isEmpty || sizeFormViewModel.amountUnit.unitType == .weight {
                volumePrefixSection
            }
        }
    }
    
    var volumePrefixSection: some View {
        var footer: some View {
            Text("This will let you log this food in volumes of different densities or thicknesses, like – ‘cups shredded’, ‘cups sliced’.")
                .foregroundColor(!sizeFormViewModel.showingVolumePrefix ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return Section(footer: footer) {
            Toggle("Volume-prefixed name", isOn: $showingVolumePrefixToggle)
        }
    }
    
    var addButtonTitle: String {
        guard !isEditing else {
            return "Save"
        }
        return didAddSize == nil ? "Add" : "Add and Select"
    }
    
    var addButton: some View {
        return FormPrimaryButton(title: addButtonTitle) {
            guard let size = sizeFormViewModel.size else {
                return
            }
            if let didAddSize = didAddSize {
                didAddSize(size)
            }
            viewModel.add(size: size)
            dismiss()
        }
    }

    var addAndAddAnotherButton: some View {
        FormSecondaryButton(title: "Add and Add Another") {
            
        }
    }
}

struct SizeFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    var body: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    SizeForm()
                        .environmentObject(viewModel)
                        .presentationDetents([.height(420), .large])
                        .presentationDragIndicator(.hidden)
                }
        }
    }
}

struct SizeForm_Previews: PreviewProvider {
    static var previews: some View {
        SizeFormPreview()
    }
}
