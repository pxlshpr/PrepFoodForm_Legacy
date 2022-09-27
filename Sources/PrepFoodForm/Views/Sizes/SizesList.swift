import SwiftUI

struct SizesList: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingSizeForm = false
    
    var body: some View {
        list
        .toolbar { navigationTrailingContent }
        .toolbar { bottomBar }
        .sheet(isPresented: $showingSizeForm) {
            SizeForm()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .navigationTitle("Sizes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            EditButton()
        }
    }

    var bottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            HStack {
                addButton
                Spacer()
            }
        }
    }

    var list: some View {
        List {
            if !viewModel.standardNewSizes.isEmpty {
                standardSizesSection
            }
            if !viewModel.volumePrefixedNewSizes.isEmpty {
                volumePrefixedSizesSection
            }
        }
    }
    
    var standardSizesSection: some View {
        Section {
            ForEach(viewModel.standardNewSizes.indices, id: \.self) { index in
                Cell(size: $viewModel.standardNewSizes[index])
            }
            .onDelete(perform: deleteStandardSizes)
            .onMove(perform: moveStandardSizes)
        }
    }
    
    var volumePrefixedSizesSection: some View {
        var header: some View {
            Text("Volume-prefixed")
        }
        
        var footer: some View {
            Text("These let you log this food in volumes of different densities or thicknesses.")
                .foregroundColor(viewModel.volumePrefixedSizes.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return Section(header: header, footer: footer) {
            ForEach(viewModel.volumePrefixedNewSizes.indices, id: \.self) { index in
                Cell(size: $viewModel.volumePrefixedNewSizes[index])
            }
            .onDelete(perform: deleteVolumePrefixedSizes)
            .onMove(perform: moveVolumePrefixedSizes)
        }
    }
    
    var addButton: some View {
        Section {
            Button {
                showingSizeForm = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    func deleteStandardSizes(at offsets: IndexSet) {
        viewModel.standardSizes.remove(atOffsets: offsets)
    }

    func deleteVolumePrefixedSizes(at offsets: IndexSet) {
        viewModel.volumePrefixedSizes.remove(atOffsets: offsets)
    }

    func moveStandardSizes(from source: IndexSet, to destination: Int) {
        viewModel.standardSizes.move(fromOffsets: source, toOffset: destination)
    }

    func moveVolumePrefixedSizes(from source: IndexSet, to destination: Int) {
        viewModel.volumePrefixedSizes.move(fromOffsets: source, toOffset: destination)
    }
    
    enum SizesSection: String {
        case standard
        case volumePrefixed
    }
}


public struct SizesListPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            SizesList()
                .environmentObject(viewModel)
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.standardSizes = mockStandardSizes
        viewModel.volumePrefixedSizes = mockVolumePrefixedSizes
    }
}
struct SizesList_Previews: PreviewProvider {
    static var previews: some View {
        SizesListPreview()
    }
}
