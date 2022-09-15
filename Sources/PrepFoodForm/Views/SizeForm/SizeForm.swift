import SwiftUI
import NamePicker

struct SizeForm: View {
    
    @EnvironmentObject var viewModel: FoodForm.ViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var sizeFormViewModel: ViewModel
    @State var showingVolumePrefixToggle: Bool = false
    
    init(includeServing: Bool = true, allowAddSize: Bool = true) {
        _sizeFormViewModel = StateObject(wrappedValue: ViewModel(includeServing: includeServing, allowAddSize: allowAddSize))
    }
    
    var body: some View {
        NavigationStack(path: $sizeFormViewModel.path) {
            VStack {
                form
                if sizeFormViewModel.isValid {
                    addButton
                    addAndAddAnotherButton
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Size")
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
    
    var form: some View {
        Form {
            SizeField()
                .environmentObject(sizeFormViewModel)
            volumePrefixSection
        }
    }
    
    var previewSection: some View {
        var header: some View {
            Text("Preview")
        }
        
        var footer: some View {
            Text("This is what this size will look like.")
        }
        
        return Section(header: header) {
            Text("Size preview goes here")
                .foregroundColor(Color(.quaternaryLabel))
        }
    }
    
    var volumePrefixSection: some View {
        var footer: some View {
            Text("This will let you log this food in volumes of different densities or thicknesses, like – ‘cups shredded’, ‘cups sliced’.")
        }
        
        return Section(footer: footer) {
            Toggle("Use volume prefix", isOn: $showingVolumePrefixToggle)
        }
    }
    
    var addButton: some View {
        FormPrimaryButton(title: "Add") {
            guard let size = sizeFormViewModel.size else {
                return
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
