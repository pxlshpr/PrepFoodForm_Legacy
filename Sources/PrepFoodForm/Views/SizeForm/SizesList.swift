import SwiftUI

extension SizesList {
    struct Cell: View {
        var sizeViewModel: SizeViewModel
    }
}

extension SizesList.Cell {
    var body: some View {
        HStack {
//            Text(sizeViewModel.quantityString)
//            Text("×")
//                .foregroundColor(Color(.quaternaryLabel))
            HStack(spacing: 0) {
                if let volumePrefixString = sizeViewModel.volumePrefixString {
                    Text(volumePrefixString)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(", ")
                        .foregroundColor(Color(.quaternaryLabel))
                }
                Text(sizeViewModel.nameString)
            }
            Spacer()
            Text(sizeViewModel.scaledAmountString)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}

class SizeSet: Identifiable {
    let id = UUID()
    var sizes: [Size]
    
    init(sizes: [Size]) {
        self.sizes = sizes
    }
    
    func fancyMove(from source: IndexSet, to destination: Int) {
        sizes.move(fromOffsets: source, toOffset: destination)
    }
}

struct SizesList: View {
    
    @EnvironmentObject var viewModel: FoodForm.ViewModel
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
            if !viewModel.standardSizes.isEmpty {
                Section {
                    ForEach(viewModel.standardSizesViewModels, id: \.self) {
                        Cell(sizeViewModel: $0)
                    }
                    .onDelete(perform: deleteStandardSizes)
                    .onMove(perform: moveStandardSizes)
                }
            }
            if !viewModel.volumePrefixedSizes.isEmpty {
                Section(header: volumePrefixedHeader, footer: volumePrefixedFooter) {
                    ForEach(viewModel.volumePrefixedSizesViewModels, id: \.self) {
                        Cell(sizeViewModel: $0)
                    }
                    .onDelete(perform: deleteVolumePrefixedSizes)
                    .onMove(perform: moveVolumePrefixedSizes)
                }
            }
        }
    }
    
    var volumePrefixedHeader: some View {
        Text("Volume prefixed")
    }
    
    var volumePrefixedFooter: some View {
        Text("These let you log this food in volumes of different densities or thicknesses.")
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
    
    @StateObject var viewModel = FoodForm.ViewModel()
    
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
