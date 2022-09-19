import SwiftUI
import SwiftHaptics
import CameraImagePicker

extension FoodForm {
    struct SourceForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingSourceTypePicker = false
        @State var showingCamera = false
        @State var capturedImage: UIImage? = nil
    }
}

extension FoodForm.SourceForm {
    var body: some View {
        form
        .navigationTitle("Source")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSourceTypePicker) {
            SourceTypePicker()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .onDisappear {
                    if viewModel.sourceType == .images {
                        Haptics.feedback(style: .rigid)
                        showingCamera = true
                    }
                }
        }
        .sheet(isPresented: $showingCamera) {
            CameraImagePicker(capturedImage: $capturedImage)
        }
        .onChange(of: capturedImage) { newValue in
            guard let image = newValue else {
                return
            }
            viewModel.sourceImageViewModels.append(SourceImageViewModel(image: image))
            capturedImage = nil
        }
        .onAppear {
            if viewModel.sourceType == nil {
                showingSourceTypePicker = true
            }
        }
    }
    
    var form: some View {
        Form {
//            if !viewModel.isProcessingSource {
                typeSection
//            }
            if viewModel.sourceIncludesImages {
                imagesSection
            }
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
                showingSourceTypePicker = true
            } label: {
                if let sourceType = viewModel.sourceType {
                    Text(sourceType.cellString)
                } else {
                    Text("Optional")
                        .foregroundColor(Color(.tertiaryLabel))
                }
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
            Section("Extracted Data") {
                NavigationLinkButton {
                    
                } label: {
                    Text("'Amount per' details")
                }
                NavigationLinkButton {
                    
                } label: {
                    Text("2 sizes")
                }
                NavigationLinkButton {
                    
                } label: {
                    Text("\(count) nutrition facts")
                }
            }
        }
    }
    
    var imagesSection: some View {
        
        return Group {
            Section("Images") {
                SourceImagesCarousel { index in
                    viewModel.path.append(.sourceImage(viewModel.sourceImageViewModels[index]))
                } didTapDeleteOnImage: { index in
                }
                .environmentObject(viewModel)
            }
        }
    }    
}
