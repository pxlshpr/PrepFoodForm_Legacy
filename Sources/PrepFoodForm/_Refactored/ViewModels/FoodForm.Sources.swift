import SwiftUI
import SwiftUISugar
import FoodLabelScanner
import PhotosUI
import MFPScraper

extension FoodForm {
    class Sources: ObservableObject {
        
        static let shared = Sources()
        
        @Published var imageViewModels: [ImageViewModel] = []
        @Published var imageSetStatus: ImageSetStatus = .loading()
        @Published var linkInfo: LinkInfo? = nil

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
    
    func croppedImage(for fill: Fill) async -> UIImage? {
        guard let resultId = fill.imageId,
              let boundingBoxToCrop = fill.boundingBoxToCrop,
              let image = image(for: resultId)
        else {
            return nil
        }
        
        return await image.cropped(boundingBox: boundingBoxToCrop)
    }
    
    func image(for id: UUID) -> UIImage? {
        for imageViewModel in imageViewModels {
            if imageViewModel.id == id {
//            if imageViewModel.scanResult?.id == scanResultId {
                return imageViewModel.image
            }
        }
        return nil
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

import VisionSugar

//MARK: - Available Texts
extension FoodForm.Sources {
    
    /**
     Returns true if there is at least one available (unused`RecognizedText` in all the `ScanResult`s that is compatible with the `fieldValue`
     */
    func hasAvailableTexts(for fieldValue: FieldValue) -> Bool {
        imageViewModels.contains(where: { $0.scanResult != nil })
        
        //TODO: Bring this back, we're currently rudimentarily returning true if we have any ScanResults
//        !availableTexts(for: fieldValue).isEmpty
    }
    
    func availableTexts(for fieldValue: FieldValue) -> [RecognizedText] {
        var availableTexts: [RecognizedText] = []
        for imageViewModel in imageViewModels {
            let texts = fieldValue.usesValueBasedTexts ? imageViewModel.textsWithFoodLabelValues : imageViewModel.texts
//            let filtered = texts.filter { isNotUsingText($0) }
            availableTexts.append(contentsOf: texts)
        }
        return availableTexts
    }

//    func isNotUsingText(_ text: RecognizedText) -> Bool {
//        fieldValueUsing(text: text) == nil
//    }
//    /**
//     Returns the `fieldValue` (if any) that is using the `RecognizedText`
//     */
//    func fieldValueUsing(text: RecognizedText) -> FieldValue? {
//        allFieldValues.first(where: {
//            $0.fill.uses(text: text)
//        })
//    }
}