import SwiftUI
import SwiftHaptics

struct SourceTypePicker: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List {
                ForEach(SourceType.nonManualSources, id: \.self) { sourceType in
                    Section(header: Text(sourceType.headerString), footer: Text(sourceType.footerString)) {
                        Button {
                            withAnimation {
                                FoodFormViewModel.shared.sourceType = sourceType
                            }
                            dismiss()
                        } label: {
                            Label(sourceType.actionString, systemImage: sourceType.systemImage)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Pick a Source")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
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
                SourceImagesCarousel()
                    .environmentObject(viewModel)
            }
        }
    }
}
