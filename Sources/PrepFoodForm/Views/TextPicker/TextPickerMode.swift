import Foundation
import VisionSugar

enum TextPickerMode {
    case singleSelection(filter: TextPickerFilter,
                         selectedImageText: ImageText?,
                         handler: SingleSelectionHandler)
    case multiSelection(filter: TextPickerFilter,
                        selectedImageTexts: [ImageText],
                        handler: MultiSelectionHandler)
    case columnSelection(column1: TextPickerColumn,
                         column2: TextPickerColumn,
                         selectedColumn: Int,
                         handler: ColumnSelectionHandler)
    case imageViewer(initialImageIndex: Int,
                     deleteHandler: DeleteImageHandler)
}

extension TextPickerFilter {
    var includesBarcodes: Bool {
        switch self {
        case .allTextsAndBarcodes:
            return true
        default:
            return false
        }
    }
}
extension TextPickerMode {

    var filter: TextPickerFilter? {
        switch self {
        case .singleSelection(let filter, _, _):
            return filter
        case .multiSelection(let filter, _, _):
            return filter
        case .columnSelection:
            return nil
        case .imageViewer:
            return .allTextsAndBarcodes
        }
    }
    
    func columnTexts(onImageWithId imageId: UUID) -> [RecognizedText] {
        guard case .columnSelection(let column1, let column2, _, _) = self else {
            return []
        }
        var texts: [RecognizedText] = []
        for column in [column1, column2] {
            texts.append(
                contentsOf: column.imageTexts
                    .filter { $0.imageId == imageId }
                    .map { $0.text }
                )
        }
        return texts
    }

    var selectedImageTexts: [ImageText] {
        switch self {
        case .singleSelection(_, let selectedImageText, _):
            guard let selectedImageText else { return [] }
            return [selectedImageText]
        case .multiSelection(_, let selectedImageTexts, _):
            return selectedImageTexts
        case .columnSelection(let column1, let column2, let selectedColumn, _):
            return selectedColumn == 1 ? column1.imageTexts : column2.imageTexts
        case .imageViewer:
            return []
        }
    }
    var supportsTextSelection: Bool {
        isSingleSelection || isMultiSelection
    }

    var singleSelectionHandler: SingleSelectionHandler? {
        if case .singleSelection(_, _, let handler) = self {
            return handler
        }
        return nil
    }
    
    var prompt: String? {
        switch self {
        case .singleSelection:
            return "Select a text"
        case .multiSelection:
            return "Select texts"
        case .columnSelection:
            return "Select a column"
        case .imageViewer:
            return nil
        }
    }

    var multiSelectionHandler: MultiSelectionHandler? {
        if case .multiSelection(_, _, let handler) = self {
            return handler
        }
        return nil
    }

    var deleteImageHandler: DeleteImageHandler? {
        if case .imageViewer(_, let deleteHandler) = self {
            return deleteHandler
        }
        return nil
    }
    var isImageViewer: Bool {
        if case .imageViewer = self { return true }
        return false
    }
    var isColumnSelection: Bool {
        if case .columnSelection = self { return true }
        return false
    }
    var isMultiSelection: Bool {
        if case .multiSelection = self { return true }
        return false
    }
    var isSingleSelection: Bool {
        if case .singleSelection = self { return true }
        return false
    }
    
    func initialImageIndex(from imageViewModels: [ImageViewModel]) -> Int {
        switch self {
        case .imageViewer(let initialImageIndex, _):
            return initialImageIndex
        case .singleSelection(_, let selectedImageText, _):
            guard let selectedImageText else { return 0 }
            return imageViewModels.firstIndex(where: { $0.id == selectedImageText.imageId }) ?? 0
        case .multiSelection(_, let selectedImageTexts, _):
            guard let first = selectedImageTexts.first else { return 0 }
            return imageViewModels.firstIndex(where: { $0.id == first.imageId }) ?? 0
        case .columnSelection:
            return 0
        }
    }
}

enum TextPickerFilter {
    case allTextsAndBarcodes
    case allTexts
    case textsWithDensities
    case textsWithFoodLabelValues
    case textsInColumn1
    case textsInColumn2
}

typealias SingleSelectionHandler = ((ImageText) -> ())
typealias MultiSelectionHandler = (([ImageText]) -> ())
typealias ColumnSelectionHandler = ((Int) -> ())
typealias DeleteImageHandler = ((Int) -> ())

struct TextPickerColumn {
    let name: String
    let imageTexts: [ImageText]
}
