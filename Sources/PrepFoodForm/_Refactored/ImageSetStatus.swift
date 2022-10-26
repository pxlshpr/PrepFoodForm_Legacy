import Foundation

enum ImageSetStatus {
    case loading(numberOfImages: Int = 0)
    case scanning(numberOfImages: Int)
    case scanned(numberOfImages: Int, counts: DataPointsCount)
    
    var description: String {
        let s = numberOfImages > 1 ? "s": ""
        switch self {
        case .loading:
            return "Loading image\(s)"
        case .scanning:
            return "Reading food label\(s)"
        case .scanned:
            return "facts detected"
        }
    }
    
    var counts: DataPointsCount? {
        switch self {
        case .scanned(_, let counts):
            return counts
        default:
            return nil
        }
    }
    
    var numberOfImages: Int {
        switch self {
        case .loading(let numberOfImages), .scanning(let numberOfImages), .scanned(let numberOfImages, _):
            return numberOfImages
        }
    }
    
    var isScanned: Bool {
        switch self {
        case .scanned:
            return true
        default:
            return false
        }
    }
}
