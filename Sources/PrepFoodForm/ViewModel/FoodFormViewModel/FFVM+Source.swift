import Foundation

extension FoodFormViewModel {
    var imageSetStatusString: String {
        let s = numberOfImagesBeingProcessed > 1 ? "s": ""
        switch imageSetStatus {
        case .loading:
            return "Loading image\(s)"
        case .scanning:
            return "Scanning food label\(s)"
        case .scanned:
            return "facts detected"
        default:
            return "(not handled)"
        }
    }
    
    var numberOfImagesBeingProcessed: Int {
        imageViewModels
            .map { $0.status.isWorking }
            .count
    }
}
