import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI
import MFPScraper

extension FoodForm {
    class Sources: ObservableObject {
        @Published var imageViewModels: [ImageViewModel] = []
        @Published var imageSetStatus: ImageSetStatus = .loading()
        @Published var linkInfo: LinkInfo? = nil
        @Published var prefilledFood: MFPProcessedFood? = nil

        /// Scan Results
        @Published var columnSelectionInfo: ColumnSelectionInfo? = nil
        @Published var selectedScanResultsColumn = 1
        
        @Published var selectedPhotos: [PhotosPickerItem] = []
        var presentingImageIndex: Int = 0
    }
}

extension FoodForm.Sources {
    
    func receivedScanResult(_ scanResult: ScanResult, for image: UIImage) {
        let imageViewModel = ImageViewModel(image: image, scanResult: scanResult, delegate: self)
        imageViewModels.append(imageViewModel)
        tryExtractFieldsFromScanResults()
    }
    
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item, delegate: self)
            imageViewModels.append(imageViewModel)
        }
        selectedPhotos = []
    }
    
    func tryExtractFieldsFromScanResults() {
        imageSetStatus = .extracting(numberOfImages: imageViewModels.count)
        
        Task {
            guard let output = await FieldsExtractor.shared.tryExtractFieldsFrom(allScanResults)
            else {
                return
            }
            await MainActor.run {
                switch output {
                case .needsColumnSelection(let columnSelectionInfo):
                    self.columnSelectionInfo = columnSelectionInfo
                case .fieldValues(let fieldValues):
                    
//                    let counts = DataPointsCount(imageViewModels: imageViewModels)
//                    imageSetStatus = .scanned(numberOfImages: imageViewModels.count, counts: counts)
                    print("WE HERE")
                    break
                }
            }
        }
    }
}

extension FoodForm.Sources {
    func removeLink() {
        linkInfo = nil
    }
    
    func removeImage(at index: Int) {
        imageViewModels.remove(at: index)
    }

}

//MARK: - Helpers
extension FoodForm.Sources {
    func imageViewModels(for columnSelectionInfo: ColumnSelectionInfo) -> [ImageViewModel] {
        imageViewModels.containingTexts(in: columnSelectionInfo)
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
    
    var pluralS: String {
        availableImagesCount == 1 ? "" : "s"
    }
}

//MARK: - ImageViewModelDelegate
extension FoodForm.Sources: ImageViewModelDelegate {
    
    func imageDidFinishScanning(_ imageViewModel: ImageViewModel) {
        guard !imageSetStatus.isScanned else {
            return
        }
        
        if imageViewModels.allSatisfy({ $0.status == .scanned }) {
//            Haptics.successFeedback()
            tryExtractFieldsFromScanResults()
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
