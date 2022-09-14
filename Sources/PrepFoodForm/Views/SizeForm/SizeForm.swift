import SwiftUI
import NamePicker

struct SizeForm: View {

    @StateObject var viewModel = ViewModel()
    @State var showingVolumePrefixToggle: Bool = false
    
    init() { }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack {
                form
                if viewModel.isValid {
                    addButton
                    addAndAddAnotherButton
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Size")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: viewModel.quantityString) { newValue in
            viewModel.quantity = Double(newValue) ?? 0
        }
        .onChange(of: viewModel.quantity) { newValue in
            viewModel.quantityString = "\(newValue.cleanAmount)"
        }
        .onChange(of: showingVolumePrefixToggle) { newValue in
            withAnimation {
                viewModel.showingVolumePrefix = showingVolumePrefixToggle
            }
        }
    }
    
    var form: some View {
        Form {
            SizeField(viewModel: viewModel)
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
            
        }
    }

    var addAndAddAnotherButton: some View {
        FormSecondaryButton(title: "Add and Add Another") {
            
        }
    }
}
