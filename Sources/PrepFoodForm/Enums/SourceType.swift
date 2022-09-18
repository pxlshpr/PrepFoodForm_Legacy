import Foundation

enum SourceType: CaseIterable {
    case scan
    case image
    case thirdPartyImport
    case link
    case manualEntry
}

extension SourceType {
    static var nonManualSources: [SourceType] {
        allCases.filter { $0 != .manualEntry }
    }
}

extension SourceType {
    var headerString: String {
        switch self {
        case .scan:
            return "Scan Images"
        case .image:
            return "Provide Images"
        case .thirdPartyImport:
            return "Import an online source"
        case .link:
            return "Provide a Link"
        case .manualEntry:
            return "Manual Entry"
        }
    }
    
    var footerString: String {
        switch self {
        case .scan:
            return "Provide images of nutrition fact labels or screenshots of other apps to scan in their data."
        case .image:
            return "Provide images that we will use to verify that this food is valid and the nutrition facts match up."
        case .thirdPartyImport:
//            return "Use data from a third-party source when you need to roughly estimate the nutrition facts for this food. This method is slow and the data can sometimes be unreliable."
            return "Search and import a food from online sources. Keep in mind that this method relies on the third-party for search speed and correctness."
        case .link:
            return "Provide a link that we will use to verify that this food is valid and that the nutrition facts match up."
        case .manualEntry:
            return "Manually enter in details from a nutrition fact label or elsewhere."
        }
    }
    
    var systemImage: String {
        switch self {
        case .scan:
            return "text.viewfinder"
        case .image:
            return "photo.on.rectangle.angled"
        case .thirdPartyImport:
            return "magnifyingglass"
        case .link:
            return "link"
        case .manualEntry:
            return "character.cursor.ibeam"
        }
    }
    var includesImages: Bool {
        switch self {
        case .image, .scan:
            return true
        default:
            return false
        }
    }
    
    var actionString: String {
        switch self {
        case .scan:
            return "Choose images"
        case .thirdPartyImport:
            return "Search"
        case .image:
            return "Choose images"
        case .link:
            return "Enter Link"
        case .manualEntry:
            return "Enter details"
        }
    }
    
    var cellString: String {
        switch self {
        case .scan:
            return "Images"
        case .thirdPartyImport:
            return "Link"
        case .image:
            return "Image"
        case .link:
            return "Link"
        case .manualEntry:
            return "Manual Entry"
        }
    }
}
