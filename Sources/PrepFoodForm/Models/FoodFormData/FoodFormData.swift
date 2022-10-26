import SwiftUI

public struct FoodFormData {
    public let images: [UUID: UIImage]
    public let data: Data
    public let shouldPublish: Bool
    
    init(rawData: FoodFormRawData, images: [UUID : UIImage], shouldPublish: Bool) {
        self.images = images
        self.data = try! JSONEncoder().encode(rawData)
        self.shouldPublish = shouldPublish
    }
}
