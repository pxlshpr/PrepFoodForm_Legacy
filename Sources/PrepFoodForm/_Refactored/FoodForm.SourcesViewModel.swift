import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI

extension FoodForm {
    class SourcesViewModel: ObservableObject {
        @Published var imageViewModels: [ImageViewModel] = []
        @Published var imageSetStatus: ImageSetStatus = .loading()
        @Published var linkInfo: LinkInfo? = nil
        
        /// Scan Results
        @Published var twoColumnOutput: ScanResultsTwoColumnOutput? = nil
        @Published var selectedScanResultsColumn = 1
        
        @Published var selectedPhotos: [PhotosPickerItem] = []
        var presentingImageIndex: Int = 0
    }
}

extension FoodForm.SourcesViewModel {
    
    func receivedScanResult(_ scanResult: ScanResult, for image: UIImage) {
        let imageViewModel = ImageViewModel(image: image, scanResult: scanResult, delegate: self)
        imageViewModels.append(imageViewModel)
        processScanResults()
    }
    
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item, delegate: self)
            imageViewModels.append(imageViewModel)
        }
        selectedPhotos = []
    }
    
    func processScanResults() {
        let counts = DataPointsCount(imageViewModels: imageViewModels)
        imageSetStatus = .scanned(numberOfImages: imageViewModels.count, counts: counts)
        
        Task {
            guard let output = await ScanResultsProcessor.shared.process(allScanResults) else {
                return
            }
            await MainActor.run {
                switch output {
                case .twoColumns(let twoColumnOutput):
                    print("🍩 Setting twoColumnOutput")
                    self.twoColumnOutput = twoColumnOutput
                case .oneColumn:
                    break
                }
            }
        }
    }
    
    func imageViewModels(for twoColumnOutput: ScanResultsTwoColumnOutput) -> [ImageViewModel] {
        imageViewModels.containingTexts(in: twoColumnOutput)
    }
    var allScanResults: [ScanResult] {
        imageViewModels.compactMap { $0.scanResult }
    }

    /// Returns how many images can still be added to this food
    var availableImagesCount: Int {
        max(5 - imageViewModels.count, 0)
    }
    
    var isEmpty: Bool {
        imageViewModels.isEmpty && linkInfo == nil
    }
}
//TODO: Finish this
//Also migrate form to use this
//Also have scan results moved here possibly
extension FoodForm.SourcesViewModel: ImageViewModelDelegate {
    
    func imageDidFinishScanning(_ imageViewModel: ImageViewModel) {
        guard !imageSetStatus.isScanned else {
            return
        }
        
        if imageViewModels.allSatisfy({ $0.status == .scanned }) {
//            Haptics.successFeedback()
            withAnimation {
                processScanResults()
            }
        }
    }

    func imageDidStartScanning(_ imageViewModel: ImageViewModel) {
        withAnimation {
            self.imageSetStatus = .scanning(numberOfImages: imageViewModels.count)
        }
    }

    func imageDidFinishLoading(_ imageViewModel: ImageViewModel) {
        withAnimation {
            self.imageSetStatus = .scanning(numberOfImages: imageViewModels.count)
        }
    }
}
