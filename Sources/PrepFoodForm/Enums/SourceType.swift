import Foundation

enum SourceType: CaseIterable {
    case images
    case onlineSource
    case link
    case manualEntry
}

extension SourceType {
    static var nonManualSources: [SourceType] {
        allCases.filter { $0 != .manualEntry }
    }
}

extension SourceType: CustomStringConvertible {
    var description: String {
        switch self {
        case .images:
            return "Images"
        case .onlineSource:
            return "Online Source"
        case .link:
            return "Link"
        case .manualEntry:
            return "Manual Entry"
        }
    }
}

extension SourceType {
    var headerString: String {
        switch self {
//        case .scan:
//            return "Scan Images"
        case .images:
            return "Provide Images"
        case .onlineSource:
            return "Import an online source"
        case .link:
            return "Provide a Link"
        case .manualEntry:
            return "Manual Entry"
        }
    }
    
    var footerString: String {
        switch self {
//        case .scan:
//            return "Provide images of nutrition fact labels or screenshots of other apps to scan in their data."
        case .images:
//            return "Provide images that we will use to verify that this food is valid and the nutrition facts match up."
            return "Provide images of nutrition fact labels or screenshots of other apps. These will be processed to extract any data from them. They will also be used to verify this food."
        case .onlineSource:
//            return "Use data from a third-party source when you need to roughly estimate the nutrition facts for this food. This method is slow and the data can sometimes be unreliable."
            return "Search and import from an online source. This relies on the third-party for search speed and correctness."
        case .link:
            return "Provide a link that we will use to verify this."
        case .manualEntry:
            return "Manually enter in details from a nutrition fact label or elsewhere."
        }
    }
    
    var systemImage: String {
        switch self {
//        case .scan:
//            return "text.viewfinder"
        case .images:
            return "photo.on.rectangle.angled"
        case .onlineSource:
            return "magnifyingglass"
        case .link:
            return "link"
        case .manualEntry:
            return "character.cursor.ibeam"
        }
    }
    var includesImages: Bool {
        switch self {
        case .images:
            return true
//        case .scan:
//            return true
        default:
            return false
        }
    }
    
    var actionString: String {
        switch self {
//        case .scan:
//            return "Choose images"
        case .onlineSource:
            return "Search online source"
        case .images:
            return "Choose images"
        case .link:
            return "Provide link"
        case .manualEntry:
            return "Enter details"
        }
    }
    
    var cellString: String {
        switch self {
//        case .scan:
//            return "Images"
        case .onlineSource:
            return "Online Source"
        case .images:
            return "Image"
        case .link:
            return "Link"
        case .manualEntry:
            return "Manual Entry"
        }
    }
}
