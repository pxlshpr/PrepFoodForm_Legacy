import SwiftUI
import SwiftUISugar
import RSBarcodes_Swift
import Vision
import AVKit
import SwiftHaptics

enum BarcodeSymbology {
    case code128
    case aztec
    case pdf417
    case qr
    case ean13
    
    var ciFilterName: String {
        switch self {
        case .code128:  return "CICode128BarcodeGenerator"
        case .aztec:    return "CIAztecCodeGenerator"
        case .pdf417:   return "CIPDF417BarcodeGenerator"
        case .qr:       return "CIQRCodeGenerator"
        case .ean13:    return "CICode128BarcodeGenerator"
        }
    }
    
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii, allowLossyConversion: false)

        if let filter = CIFilter(name: ciFilterName) {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    init?(visionSymbology: VNBarcodeSymbology) {
        switch visionSymbology {
        case .code128:  self = .code128
        case .qr:       self = .qr
        case .aztec:    self = .aztec
        case .pdf417:   self = .pdf417
        case .ean13:    self = .ean13
        default:        return nil
        }
    }
}

extension FieldViewModel {
    func barcodeThumbnail(asSquare: Bool = false) -> UIImage? {
        let width = 100
        let height = asSquare ? 100 : 40
        return barcodeImage(within: CGSize(width: width, height: height))
    }
    
    func barcodeImage(within size: CGSize) -> UIImage? {
        guard let barcodeValue else { return nil }
        return RSUnifiedCodeGenerator.shared.generateCode(
            barcodeValue.payloadString,
            machineReadableCodeObjectType: barcodeValue.symbology.objectType.rawValue,
            targetSize: size
        )
    }
}

extension VNBarcodeSymbology {
    var isSquare: Bool {
        switch self {
        case .qr, .aztec, .microQR:
            return true
        default:
            return false
        }
    }
}

struct BarcodesSection: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingPhotosPicker = false
    
    var body: some View {
        
        Group {
            if viewModel.hasBarcodes {
                chosenContentSection
            } else {
                notChosenContentSection
            }
        }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: viewModel.availableImagesCount,
            matching: .images
        )
    }
    
    var notChosenContentSection: some View {
        FormStyledSection(header: header, footer: footer) {
            Button {
                viewModel.showingAddBarcodeMenu = true
            } label: {
                Text("Add a barcode")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var chosenContentSection: some View {
        FormStyledSection(header: header, footer: footer, horizontalPadding: 0, verticalPadding: 0) {
            NavigationLink {
                BarcodesForm()
                    .environmentObject(viewModel)
            } label: {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(viewModel.barcodeViewModels.indices, id: \.self) { index in
                        barcodeView(for: viewModel.barcodeViewModels[index])
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    func barcodeView(for barcodeViewModel: FieldViewModel) -> some View {
        if let image = barcodeViewModel.barcodeThumbnail(asSquare: viewModel.hasSquareBarcodes) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100)
                .shadow(radius: 3, x: 0, y: 3)
                .padding()
        }
    }


    var imagesGrid: some View {
//        GeometryReader { geometry in
            HStack {
                ForEach(viewModel.imageViewModels, id: \.self.hashValue) { imageViewModel in
                    SourceImage(imageViewModel: imageViewModel, imageSize: .small)
                }
            }
//        }
    }
    
    var imageSetStatus: some View {
        ImagesSummary()
            .environmentObject(viewModel)
    }

    var header: some View {
        Text("Barcodes")
    }
    
    @ViewBuilder
    var footer: some View {
        if !viewModel.hasBarcodes {
            Button {
                
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("This will allow you to scan and quickly find this food again later.")
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.leading)
                }
                .font(.footnote)
            }
        }
    }
}

public struct BarcodesSectionPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        FoodFormViewModel.shared = FoodFormViewModel.mock(for: .proteinOats)
        
        let barcodes: [(String, VNBarcodeSymbology)] = [
            ("9300650430419", .qr),
            ("9300650430419", .code128),
            ("9300650430419", .code93),
            ("9300650430419", .aztec),
            ("9300650430419", .pdf417),
            ("00712453", .upce),
            ("9300650430419", .ean13),
        ]
        
        for (string, symbology) in barcodes {
            let barcodeViewModel = FieldViewModel(fieldValue: .barcode(
                FieldValue.BarcodeValue(
                    payloadString: string,
                    symbology: symbology,
                    fill: .discardable
                ))
            )
            FoodFormViewModel.shared.addBarcodeViewModel(barcodeViewModel)
        }
        let viewModel = FoodFormViewModel.shared
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            FormStyledScrollView {
                BarcodesSection()
                    .environmentObject(viewModel)
            }
            .navigationTitle("BarcodesSection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BarcodesSection_Preview: PreviewProvider {
    static var previews: some View {
        BarcodesSectionPreview()
    }
}