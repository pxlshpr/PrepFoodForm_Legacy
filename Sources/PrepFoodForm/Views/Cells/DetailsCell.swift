import SwiftUI
import RSBarcodes_Swift
import AVFoundation

extension FoodForm {
    struct DetailsCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
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
    
    var filledContent: some View {
        
        @ViewBuilder
        var emoji: some View {
            if !viewModel.emoji.isEmpty {
                Text(viewModel.emoji.string)
                    .font(.system(size: 50))
            }
        }
        
        @ViewBuilder
        var name: some View {
            if !viewModel.name.isEmpty {
                Text(viewModel.name.string)
                    .bold()
            } else {
                Text("[Name Required]")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        
        @ViewBuilder
        var detail: some View {
            if !viewModel.detail.isEmpty {
                Text(viewModel.detail.string)
            }
        }

        @ViewBuilder
        var brand: some View {
            if !viewModel.brand.isEmpty {
                Text(viewModel.brand.string)
            }
        }
        
        @ViewBuilder
        var barcode: some View {
            if !viewModel.barcode.isEmpty {
                barcodeView(for: viewModel.barcode.string)
            }
        }

        return HStack {
            emoji
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
        !name.isEmpty
        || !emoji.isEmpty
        || !detail.isEmpty
        || !brand.isEmpty
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
                        FoodForm.DetailsCell()
                            .environmentObject(viewModel)
                    }
                }
            }
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.emoji = FieldValue.emoji(string: "🧈")
        viewModel.name = FieldValue.name(string: "Butter")
        viewModel.detail = FieldValue.detail(string: "Salted")
        viewModel.brand = FieldValue.brand(string: "Emborg")
        viewModel.barcode = FieldValue.barcode(string: "10123456789019")
//        viewModel.barcode = "2166529V"
    }
}
struct DetailsCell_Previews: PreviewProvider {
    static var previews: some View {
        DetailsCellPreview()
    }
}
