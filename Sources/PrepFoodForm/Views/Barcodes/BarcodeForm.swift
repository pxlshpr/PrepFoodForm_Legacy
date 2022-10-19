import SwiftUI
import SwiftHaptics
import RSBarcodes_Swift
import AVKit

struct BarcodesForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingAddMenu = false
    @State var showingAddBarcodeMenu = false
    
    var body: some View {
//        List {
//            ForEach(viewModel.barcodeViewModels.indices, id: \.self) { index in
//                barcodeCell(for: viewModel.barcodeViewModels[index])
//            }
//            .onDelete(perform: delete)
//        }
        Color.green
        .toolbar { navigationTrailingContent }
        .bottomMenu(isPresented: $showingAddBarcodeMenu, actionGroups: addBarcodeActionGroups)
    }
    
    var addBarcodeActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Scan a Barcode", systemImage: "barcode.viewfinder", tapHandler: {
                    viewModel.showingBarcodeScanner = true
                }),
//                BottomMenuAction(title: "Choose Photo", systemImage: "photo.on.rectangle", tapHandler: {
//
//                }),
            ]
//            ,
//            [enterBarcodeManuallyLink]
        ]
    }
    
    var enterBarcodeManuallyLink: BottomMenuAction {
       BottomMenuAction(
           title: "Enter Manually",
           systemImage: "123.rectangle",
           textInput: BottomMenuTextInput(
               placeholder: "012345678912",
               keyboardType: .decimalPad,
               submitString: "Add Barcode",
               autocapitalization: .never,
               textInputIsValid: isValidBarcode,
               textInputHandler: {
                   let barcodeValue = FieldValue.BarcodeValue(
                       payloadString: $0,
                       symbology: .ean13,
                       fill: .userInput)
                   let fieldViewModel = FieldViewModel(fieldValue: .barcode(barcodeValue))
                   let _ = viewModel.add(barcodeViewModel: fieldViewModel)
                   Haptics.successFeedback()
               }
           )
       )
    }
    
    func isValidBarcode(_ string: String) -> Bool {
        let isValid = RSUnifiedCodeValidator.shared.isValid(
            string,
            machineReadableCodeObjectType: AVMetadataObject.ObjectType.ean13.rawValue)
        let exists = viewModel.contains(barcode: string)
        return isValid && !exists
    }
    
    @ViewBuilder
    func barcodeCell(for barcodeViewModel: FieldViewModel) -> some View {
        Color.green
            .frame(width: 100, height: 40)
//        if let barcodeValue = barcodeViewModel.barcodeValue,
//           let image = barcodeViewModel.barcodeThumbnail(asSquare: false)
//        {
//            HStack {
//                Color.green
//                    .frame(width: 100, height: 40)
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxWidth: 100)
//                    .shadow(radius: 3, x: 0, y: 3)
//                    .padding()
////                Spacer()
//                Text(barcodeValue.payloadString)
//                Spacer()
//                fillTypeIcon(for: barcodeViewModel.fieldValue)
//            }
//        }
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
        showingAddBarcodeMenu = true
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.barcodeViewModels.remove(atOffsets: offsets)
    }
}
