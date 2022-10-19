import SwiftUI

struct BarcodesForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingAddMenu = false
    
    var body: some View {
        List {
            ForEach(viewModel.barcodeViewModels.indices, id: \.self) { index in
                barcodeCell(for: viewModel.barcodeViewModels[index])
            }
            .onDelete(perform: delete)
        }
        .toolbar { navigationTrailingContent }
    }
    
    @ViewBuilder
    func barcodeCell(for barcodeViewModel: FieldViewModel) -> some View {
        if let barcodeValue = barcodeViewModel.barcodeValue,
           let image = barcodeViewModel.barcodeThumbnail(asSquare: false)
        {
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100)
                    .shadow(radius: 3, x: 0, y: 3)
                    .padding()
//                Spacer()
                Text(barcodeValue.payloadString)
                Spacer()
                fillTypeIcon(for: barcodeViewModel.fieldValue)
            }
        }
    }
    
    @ViewBuilder
    func fillTypeIcon(for fieldValue: FieldValue) -> some View {
        if viewModel.hasNonUserInputFills {
            Image(systemName: fieldValue.fill.iconSystemImage)
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            addButton
            EditButton()
        }
    }
    
    var addButton: some View {
        Button {
            tappedAdd()
        } label: {
            Image(systemName: "plus")
                .padding(.vertical)
        }
        .buttonStyle(.borderless)
    }
    
    //MARK: - Actions

    func tappedAdd() {
        viewModel.showingAddBarcodeMenu = true
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.barcodeViewModels.remove(atOffsets: offsets)
    }
}
