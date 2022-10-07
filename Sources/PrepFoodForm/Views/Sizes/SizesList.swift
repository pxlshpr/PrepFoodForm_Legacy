import SwiftUI

//MARK: - SizesList.Cell

extension SizesList {
    struct Cell: View {
        @ObservedObject var fieldValueViewModel: FieldValueViewModel
    }
}

extension SizesList.Cell {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                if let volumePrefixString {
                    Text(volumePrefixString)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(", ")
                        .foregroundColor(Color(.quaternaryLabel))
                }
                Text(name)
                    .foregroundColor(.primary)
            }
            Spacer()
            Text(amountString)
                .foregroundColor(Color(.secondaryLabel))
            //            Button {
            //
            //            } label: {
            //                Image(systemName: size.fillType.buttonSystemImage)
            //                    .imageScale(.large)
            //            }
            //            .buttonStyle(.borderless)
        }
    }
    
    var size: Size? {
        fieldValueViewModel.fieldValue.size
    }
    
    var volumePrefixString: String? {
        size?.volumePrefixString
    }
    
    var name: String {
        size?.name ?? ""
    }
    
    var amountString: String {
        size?.scaledAmountString ?? ""
    }
}

//MARK: - SizesList

struct SizesList: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    @State var standardSizeIndexToEdit: Int? = nil
    @State var volumePrefixedSizeIndexToEdit: Int? = nil
    @State var showingEditSizeForm: Bool = false
    @State var showingAddSizeForm = false

    var body: some View {
        list
        .toolbar { navigationTrailingContent }
        .toolbar { bottomBar }
        .sheet(isPresented: $showingAddSizeForm) {
            SizeForm()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .navigationTitle("Sizes")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSizeForm) {
            //TODO: SizeValue
            Color.blue
//            SizeForm(existingSize: sizeToEdit) { newSize in
//
//            }
//            .presentationDetents([.medium, .large])
//            .presentationDragIndicator(.hidden)
        }
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
            if !viewModel.standardSizeViewModels.isEmpty {
                standardSizesSection
            }
            if !viewModel.volumePrefixedSizeViewModels.isEmpty {
                volumePrefixedSizesSection
            }
        }
    }
    
    var standardSizesSection: some View {
        Section {
            ForEach(viewModel.standardSizeViewModels.indices, id: \.self) { index in
                Button {
                    standardSizeIndexToEdit = index
                    volumePrefixedSizeIndexToEdit = nil
                    showingEditSizeForm = true
                } label: {
                    Cell(fieldValueViewModel: viewModel.standardSizeViewModels[index])
                }
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
                .foregroundColor(viewModel.volumePrefixedSizeViewModels.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return Section(header: header, footer: footer) {
            ForEach(viewModel.volumePrefixedSizeViewModels.indices, id: \.self) { index in
                Button {
                    volumePrefixedSizeIndexToEdit = index
                    standardSizeIndexToEdit = nil
                    showingEditSizeForm = true
                } label: {
                    Cell(fieldValueViewModel: viewModel.volumePrefixedSizeViewModels[index])
                }
            }
            .onDelete(perform: deleteVolumePrefixedSizes)
            .onMove(perform: moveVolumePrefixedSizes)
        }
    }
    
    var addButton: some View {
        Section {
            Button {
                showingAddSizeForm = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    func deleteStandardSizes(at offsets: IndexSet) {
        viewModel.standardSizeViewModels.remove(atOffsets: offsets)
    }

    func deleteVolumePrefixedSizes(at offsets: IndexSet) {
        viewModel.volumePrefixedSizeViewModels.remove(atOffsets: offsets)
    }

    func moveStandardSizes(from source: IndexSet, to destination: Int) {
        viewModel.standardSizeViewModels.move(fromOffsets: source, toOffset: destination)
    }

    func moveVolumePrefixedSizes(from source: IndexSet, to destination: Int) {
        viewModel.volumePrefixedSizeViewModels.move(fromOffsets: source, toOffset: destination)
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
        viewModel.standardSizeViewModels = mockStandardSizes.fieldValueViewModels
        viewModel.volumePrefixedSizeViewModels = mockVolumePrefixedSizes.fieldValueViewModels
    }
}

struct SizesList_Previews: PreviewProvider {
    static var previews: some View {
        SizesListPreview()
    }
}
