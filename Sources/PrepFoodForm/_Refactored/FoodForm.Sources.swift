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
        
        var didScanAllPickedImages: (() -> ())? = nil
        var autoFillHandler: ColumnSelectionHandler? = nil
    }
}

extension FoodForm.Sources {
    
    func add(_ image: UIImage, with scanResult: ScanResult) {
        let imageViewModel = ImageViewModel(image: image, scanResult: scanResult, delegate: self)
        imageViewModels.append(imageViewModel)
    }
    
    func selectedPhotosChanged(to items: [PhotosPickerItem]) {
        for item in items {
            let imageViewModel = ImageViewModel(photosPickerItem: item, delegate: self)
            imageViewModels.append(imageViewModel)
        }
        selectedPhotos = []
    }
    
    func extractFieldsOrSetColumnSelectionInfo() async -> [FieldValue]? {
        
        await MainActor.run {
            imageSetStatus = .extracting(numberOfImages: imageViewModels.count)
        }
        
        guard let output = await FieldsExtractor.shared.extractFieldsOrGetColumnSelectionInfo(for: allScanResults)
        else {
            return nil
        }
        switch output {
        case .needsColumnSelection(let columnSelectionInfo):
            await MainActor.run {
                self.columnSelectionInfo = columnSelectionInfo
            }
            return nil
        case .fieldValues(let fieldValues):
            return fieldValues
        }
    }
    
    func extractFieldsFrom(_ results: [ScanResult], at column: Int) async -> [FieldValue] {
        let output = await FieldsExtractor.shared.extractFieldsFrom(results, at: column)
        guard case .fieldValues(let fieldValues) = output else {
            return []
        }
        return fieldValues
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
            didScanAllPickedImages?()
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
