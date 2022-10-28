import SwiftUI
import SwiftUISugar
import RSBarcodes_Swift
import Vision
import AVKit
import SwiftHaptics

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
    func barcodeView(for barcodeViewModel: Field) -> some View {
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
