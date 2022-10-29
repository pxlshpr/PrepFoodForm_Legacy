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
            Text(viewModel.emojiViewModel.value.stringValue.string)
                .font(.system(size: 50))
        }
        .buttonStyle(.borderless)
    }
    
    var filledContent: some View {
        
        @ViewBuilder
        var name: some View {
            if !viewModel.nameViewModel.value.isEmpty {
                Text(viewModel.nameViewModel.value.stringValue.string)
                    .bold()
                    .multilineTextAlignment(.leading)
            } else {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        
        @ViewBuilder
        var detail: some View {
            if !viewModel.detailViewModel.value.isEmpty {
                Text(viewModel.detailViewModel.value.stringValue.string)
                    .multilineTextAlignment(.leading)
            }
        }

        @ViewBuilder
        var brand: some View {
            if !viewModel.brandViewModel.value.isEmpty {
                Text(viewModel.brandViewModel.value.stringValue.string)
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

extension FoodFormViewModel {
    var hasDetails: Bool {
        !nameViewModel.value.isEmpty
        || !emojiViewModel.value.isEmpty
        || !detailViewModel.value.isEmpty
        || !brandViewModel.value.isEmpty
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
        viewModel.emojiViewModel.value = FieldValue.emoji(FieldValue.StringValue(string: "🧈"))
        viewModel.nameViewModel.value = FieldValue.name(FieldValue.StringValue(string: "Butter"))
        viewModel.detailViewModel.value = FieldValue.detail(FieldValue.StringValue(string: "Salted"))
        viewModel.brandViewModel.value = FieldValue.brand(FieldValue.StringValue(string: "Emborg"))
//        viewModel.barcodeViewModel.fieldValue = FieldValue.barcode(FieldValue.StringValue(string: "10123456789019"))
//        viewModel.barcode = "2166529V"
    }
}
struct DetailsCell_Previews: PreviewProvider {
    static var previews: some View {
        DetailsCellPreview()
    }
}
