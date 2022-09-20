import SwiftUI
import SwiftHaptics
import CameraImagePicker

extension FoodForm {
    struct SourceForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingSourceTypePicker = false
    }
}

extension FoodForm.SourceForm {
    var body: some View {
        form
        .navigationTitle("Source")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSourceTypePicker) {
            SourceTypePicker()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
//        .onChange(of: viewModel.capturedImage) { newValue in
//            guard let image = newValue else {
//                return
//            }
//            viewModel.sourceImageViewModels.append(SourceImageViewModel(image: image))
//            viewModel.sourceType = .images
//            showingSourceTypePicker = false
//            capturedImage = nil
//        }
        .onAppear {
            if viewModel.sourceType == nil {
                showingSourceTypePicker = true
            }
        }
    }
    
    var form: some View {
        Form {
            typeSection
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
        var title: String {
            if viewModel.sourceType == .manualEntry {
                return "Choose"
            } else {
                return viewModel.sourceType.description
            }
        }
        
        return Section {
            HStack {
                Text("Source")
                    .foregroundColor(.primary)
                Spacer()
                Menu {
                    Button("Images") {
                        viewModel.sourceType = .images
                    }
                    Button("Link") {
                        viewModel.sourceType = .link
                    }
                    if viewModel.sourceType != .manualEntry {
                        Divider()
                        Button("Remove", role: .destructive) {
                            viewModel.sourceType = .manualEntry
                        }
                    }
                } label: {
                    Text(title)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    var typeSection_legacy: some View {
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
