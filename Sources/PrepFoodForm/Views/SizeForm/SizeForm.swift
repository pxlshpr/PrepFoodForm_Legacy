import SwiftUI
import NamePicker


struct SizeForm: View {

    enum Route: Hashable {
        case quantity
        case name
        case amount
        case volumePrefix
        case amountUnit
    }

    @StateObject var viewModel = ViewModel()
    
    @State var showingUnitSelector = false
    
    init() {
        
    }
    
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
        .sheet(isPresented: $showingUnitSelector) {
            UnitSelector(pickedUnit: viewModel.amountUnit, delegate: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: viewModel.quantityString) { newValue in
            viewModel.quantity = Double(newValue) ?? 0
        }
        .onChange(of: viewModel.quantity) { newValue in
            viewModel.quantityString = "\(newValue.cleanAmount)"
        }
    }
    
    var form: some View {
        Form {
            Field(viewModel: viewModel)
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
            Toggle("Use volume prefix", isOn: $viewModel.showingVolumePrefix)
        }
    }
    
    var addButton: some View {
        Button {
//            tappedAdd()
        } label: {
            Text("Add")
                .bold()
                .foregroundColor(.white)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.accentColor)
                )
                .padding(.horizontal)
                .padding(.horizontal)
        }
//        .disabled(name.isEmpty)
    }

    var addAndAddAnotherButton: some View {
        Button {
            
        } label: {
            Text("Add and Add Another")
                .bold()
                .foregroundColor(.accentColor)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.clear)
                )
                .padding(.horizontal)
                .padding(.horizontal)
                .contentShape(Rectangle())
        }
//        .disabled(name.isEmpty)
    }
    
    var quantitySection: some View {
        Section("Quantity") {
            HStack {
                TextField("Required", text: $viewModel.quantityString)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                Spacer()
                Stepper("", value: $viewModel.quantity, in: 1...1000)
                    .labelsHidden()
            }
        }
    }
}
