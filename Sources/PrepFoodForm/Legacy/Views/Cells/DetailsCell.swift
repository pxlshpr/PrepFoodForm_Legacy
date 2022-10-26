import SwiftUI
import RSBarcodes_Swift
import AVFoundation
import Vision

extension FoodForm_Legacy {
    struct DetailsCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
    }
}

extension FoodForm_Legacy.DetailsCell {
    
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
            if !viewModel.nameViewModel.fieldValue.isEmpty {
                Text(viewModel.nameViewModel.fieldValue.stringValue.string)
                    .bold()
                    .multilineTextAlignment(.leading)
            } else {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        
        @ViewBuilder
        var detail: some View {
            if !viewModel.detailViewModel.fieldValue.isEmpty {
                Text(viewModel.detailViewModel.fieldValue.stringValue.string)
                    .multilineTextAlignment(.leading)
            }
        }

        @ViewBuilder
        var brand: some View {
            if !viewModel.brandViewModel.fieldValue.isEmpty {
                Text(viewModel.brandViewModel.fieldValue.stringValue.string)
                    .multilineTextAlignment(.leading)
            }
        }
        
        @ViewBuilder
        var barcode: some View {
            if let firstBarcodeValue = viewModel.primaryBarcodeValue {
                barcodeView(for: firstBarcodeValue)
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
//            barcode
//            Image(systemName: "chevron.forward")
        }
            .foregroundColor(.primary)
    }
    
    func barcodeView(for barcodeValue: FieldValue.BarcodeValue) -> some View {
        Group {
            if let image = RSUnifiedCodeGenerator.shared.generateCode(
                barcodeValue.payloadString,
                machineReadableCodeObjectType: barcodeValue.symbology.objectType.rawValue)
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
    var primaryBarcodeValue: FieldValue.BarcodeValue? {
        barcodeViewModels
            .compactMap { $0.barcodeValue }
            .filter({ $0.payloadString != "" })
            .sorted(by: { $0.symbology.preferenceRank < $1.symbology.preferenceRank })
            .first
    }
}

extension FieldViewModel {
    var barcodeValue: FieldValue.BarcodeValue? {
        fieldValue.barcodeValue
    }
}

extension VNBarcodeSymbology {

    var preferenceRank: Int {
        switch self {
        case .code128: return 1
        case .upce: return 1
        case .code39: return 1
        case .ean8: return 1
        case .ean13: return 1
        case .code93: return 1
        case .pdf417: return 1
        case .qr: return 2
        case .aztec: return 3
        default:
            return 4
        }
    }
    
    var objectType: AVMetadataObject.ObjectType {
        switch self {
        case .code128: return .code128
        case .upce: return .upce
        case .code39: return .code39
        case .ean8: return .ean8
        case .ean13: return .ean13
        case .code93: return .code93
        case .pdf417: return .pdf417
        case .qr: return .qr
        case .aztec: return .aztec
        default:
            return .code128
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
                        FoodForm_Legacy.DetailsCell()
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
//        viewModel.barcodeViewModel.fieldValue = FieldValue.barcode(FieldValue.StringValue(string: "10123456789019"))
//        viewModel.barcode = "2166529V"
    }
}
struct DetailsCell_Previews: PreviewProvider {
    static var previews: some View {
        DetailsCellPreview()
    }
}
