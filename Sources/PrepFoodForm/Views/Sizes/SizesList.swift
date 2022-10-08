import SwiftUI

struct SizesList: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    @State var showingEditSizeForm: Bool = false
    @State var showingAddSizeForm = false
    
    @State var sizeToEdit: FieldViewModel?
//    @State var standardSizeIndexToEdit: Int? = nil
//    @State var volumePrefixedSizeIndexToEdit: Int? = nil

    var body: some View {
        list
//            .toolbar { bottomBarContents }
            .toolbar { navigationTrailingContent }
            .sheet(isPresented: $showingAddSizeForm) {
                SizeForm()
                    .environmentObject(viewModel)
            }
            .navigationTitle("Sizes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditSizeForm) {
                editSizeForm
            }
            .sheet(item: $sizeToEdit) { sizeViewModel in
                SizeForm(fieldViewModel: sizeViewModel) { sizeViewModel in
                    
                }
            }
    }
    
//    var sizeToEdit: FieldViewModel? {
//        if let standardSizeIndexToEdit {
//            return viewModel.standardSizeViewModels[standardSizeIndexToEdit]
//        } else if let volumePrefixedSizeIndexToEdit {
//            return viewModel.volumePrefixedSizeViewModels[volumePrefixedSizeIndexToEdit]
//        } else {
//            return nil
//        }
//    }
    
    @ViewBuilder
    var editSizeForm: some View {
        if let sizeToEdit {
            SizeForm(fieldViewModel: sizeToEdit) { sizeViewModel in
                
            }
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            EditButton()
        }
    }
    
    var bottomBarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                showingAddSizeForm = true
            } label: {
                Image(systemName: "plus")
            }
            Spacer()
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
            addButtonSection
        }
    }
    
    var addButtonSection: some View {
        Section {
            Button {
                showingAddSizeForm = true
            } label: {
                Text("Add a size")
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
//            .sheet(isPresented: $showingAddSizeForm) {
//                SizeForm()
//                    .environmentObject(viewModel)
//            }
        }
    }

    var standardSizesSection: some View {
        Section {
            ForEach(viewModel.standardSizeViewModels.indices, id: \.self) { index in
                Button {
                    sizeToEdit = viewModel.standardSizeViewModels[index]
                } label: {
                    Cell(fieldViewModel: viewModel.standardSizeViewModels[index])
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
                    sizeToEdit = viewModel.volumePrefixedSizeViewModels[index]
                } label: {
                    Cell(fieldViewModel: viewModel.volumePrefixedSizeViewModels[index])
                }
            }
            .onDelete(perform: deleteVolumePrefixedSizes)
            .onMove(perform: moveVolumePrefixedSizes)
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
        viewModel.standardSizeViewModels = mockStandardSizes.fieldViewModels
        viewModel.volumePrefixedSizeViewModels = mockVolumePrefixedSizes.fieldViewModels
    }
}

struct SizesList_Previews: PreviewProvider {
    static var previews: some View {
        SizesListPreview()
    }
}
