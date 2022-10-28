import Foundation
import RSBarcodes_Swift
import AVKit

extension FoodForm {
    var detailsAreEmpty: Bool {
        name.isEmpty && emoji.isEmpty && detail.isEmpty && brand.isEmpty
    }
    
    func isValidBarcode(_ string: String) -> Bool {
        return true
//        let isValid = RSUnifiedCodeValidator.shared.isValid(
//            string,
//            machineReadableCodeObjectType: AVMetadataObject.ObjectType.ean13.rawValue)
//        let exists = fields.contains(barcode: string)
//        return isValid && !exists
    }
}
