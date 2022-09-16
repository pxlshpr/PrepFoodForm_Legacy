import SwiftUI
import NamePicker

struct SizeForm: View {
    
    @EnvironmentObject var viewModel: FoodForm.ViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var sizeFormViewModel: ViewModel
    @State var showingVolumePrefixToggle: Bool = false
    
    var didAddSize: ((Size) -> ())?
    
    init(includeServing: Bool = true, allowAddSize: Bool = true, didAddSize: ((Size) -> ())? = nil) {
        self.didAddSize = didAddSize
        _sizeFormViewModel = StateObject(wrappedValue: ViewModel(includeServing: includeServing, allowAddSize: allowAddSize))
    }
    
    var body: some View {
        NavigationStack(path: $sizeFormViewModel.path) {
            VStack {
                form
                if sizeFormViewModel.isValid {
                    addButton
                    if didAddSize == nil {
                        addAndAddAnotherButton
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Size")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { navigationLeadingContent }
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
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Fill") {
                sizeFormViewModel.amountString = "5"
                sizeFormViewModel.amountUnit = .weight(.g)
                sizeFormViewModel.name = "cookie"
            }
        }
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
    
    var addButton: some View {
        let title = didAddSize == nil ? "Add" : "Add and Choose"
        return FormPrimaryButton(title: title) {
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
