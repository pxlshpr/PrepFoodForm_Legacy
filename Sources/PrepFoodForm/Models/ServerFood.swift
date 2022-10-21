import Foundation
import PrepUnits

struct ServerFood: Codable {
    let id: UUID?
    let name: String
    let emoji: String
    let detail: String?
    let brand: String?
    let amount: ServerAmountWithUnit
    let serving: ServerAmountWithUnit
    let nutrients: ServerNutrients
    let sizes: [ServerSize]
    let density: ServerDensity?
    let linkUrl: String?
    let prefilledUrl: String?
    let imageIds: [UUID]?
    
    var type: Int16
    var verificationStatus: Int16?
    var database: Int16?
}

struct ServerFoodForm: Codable {
    let food: ServerFood
    let barcodes: [ServerBarcode]
}
