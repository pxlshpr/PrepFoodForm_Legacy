import SwiftUI
import RSBarcodes_Swift
import AVFoundation

extension FoodForm {
    struct DetailsCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @ObservedObject var nameViewModel: FieldViewModel
    }
}

extension FoodForm.DetailsCell {
    
    var body: some View {
        Group {
            if !viewModel.hasDetails {
                emptyContent
            } else {
                filledContent
            }
        }
    }
    
    var emptyContent: some View {
        Text("Required")
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var emojiButton: some View {
        Button {
            viewModel.showingEmojiPicker = true
        } label: {
            Text(viewModel.emojiViewModel.fieldValue.stringValue.string)
                .font(.system(size: 50))
        }
        .buttonStyle(.borderless)
    }
    
    var filledContent: some View {
        
        @ViewBuilder
        var name: some View {
            if !nameViewModel.fieldValue.isEmpty {
                Text(nameViewModel.fieldValue.stringValue.string)
                    .bold()
            } else {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        
        @ViewBuilder
        var detail: some View {
            if !viewModel.detailViewModel.fieldValue.isEmpty {
                Text(viewModel.detailViewModel.fieldValue.stringValue.string)
            }
        }

        @ViewBuilder
        var brand: some View {
            if !viewModel.brandViewModel.fieldValue.isEmpty {
                Text(viewModel.brandViewModel.fieldValue.stringValue.string)
            }
        }
        
        @ViewBuilder
        var barcode: some View {
            if !viewModel.barcodeViewModel.fieldValue.isEmpty {
                barcodeView(for: viewModel.barcodeViewModel.fieldValue.stringValue.string)
            }
        }

        return HStack {
            emojiButton
            VStack(alignment: .leading) {
                HStack {
                    name
                }
                detail
                    .foregroundColor(.secondary)
                brand
                    .foregroundColor(Color(.tertiaryLabel))
            }
            Spacer()
            barcode
//            Image(systemName: "chevron.forward")
        }
            .foregroundColor(.primary)
    }
    
    func barcodeView(for barcode: String) -> some View {
        Group {
            if let image = RSUnifiedCodeGenerator.shared.generateCode(barcode, machineReadableCodeObjectType: AVMetadataObject.ObjectType.code128.rawValue)
            {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100)
            } else {
                EmptyView()
            }
        }
    }
}

extension FoodFormViewModel {
    var hasDetails: Bool {
        !nameViewModel.fieldValue.isEmpty
        || !emojiViewModel.fieldValue.isEmpty
        || !detailViewModel.fieldValue.isEmpty
        || !brandViewModel.fieldValue.isEmpty
    }
}

//MARK: - Preview

struct DetailsCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    NavigationLink {
                    } label: {
                        FoodForm.DetailsCell(nameViewModel: viewModel.nameViewModel)
                            .environmentObject(viewModel)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.emojiViewModel.fieldValue = FieldValue.emoji(FieldValue.StringValue(string: "🧈"))
        viewModel.nameViewModel.fieldValue = FieldValue.name(FieldValue.StringValue(string: "Butter"))
        viewModel.detailViewModel.fieldValue = FieldValue.detail(FieldValue.StringValue(string: "Salted"))
        viewModel.brandViewModel.fieldValue = FieldValue.brand(FieldValue.StringValue(string: "Emborg"))
        viewModel.barcodeViewModel.fieldValue = FieldValue.barcode(FieldValue.StringValue(string: "10123456789019"))
//        viewModel.barcode = "2166529V"
    }
}
struct DetailsCell_Previews: PreviewProvider {
    static var previews: some View {
        DetailsCellPreview()
    }
}
