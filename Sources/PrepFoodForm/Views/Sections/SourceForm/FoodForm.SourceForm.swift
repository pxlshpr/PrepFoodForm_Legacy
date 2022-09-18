import SwiftUI
import SwiftHaptics

extension FoodForm {
    struct SourceForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
    }
}

extension FoodForm.SourceForm {
    var body: some View {
        form
        .navigationTitle("Source")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var form: some View {
        Form {
//            if !viewModel.isProcessingSource {
                typeSection
//            }
            imagesSection
            if viewModel.isProcessingSource {
                activitySection
            }
            if !viewModel.isScanning {
                resultsSection
            }
        }
    }
    
    var typeSection: some View {
        Section("Source") {
            NavigationLinkButton {
                
            } label: {
                Text("Images")
            }
            .disabled(viewModel.isScanning)
        }
    }
    
    var activitySection: some View {
        var activityTitle: String {
            let imagesCount = viewModel.sourceImageViewModels.count
            guard viewModel.isScanning else {
                return "Processed \(imagesCount) images"
            }
            return "Processing Image \(viewModel.numberOfScannedImages + 1) of \(imagesCount)"
        }
        return Section("Scan in progress") {
            FormActivityButton(title: activityTitle) {
                
            }
            .foregroundColor(.secondary)
            Button {
                Haptics.feedback(style: .rigid)
                viewModel.cancelScan()
            } label: {
                Text("Cancel")
            }
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    var resultsSection: some View {
        if let count = viewModel.numberOfScannedDataPoints {
            Section("Scanned Data") {
                NavigationLinkButton {
                    
                } label: {
                    Text("\(count) nutrition facts extracted")
                }
            }
        }
    }
    
    var imagesSection: some View {
        
        return Group {
            Section("Images") {
                SourceImagesCarousel()
                    .environmentObject(viewModel)
            }
        }
    }
}
