import Foundation
import PrepUnits

struct ServerFood: Codable {
    let id: UUID?
    let name: String
    let emoji: String
    let detail: String?
    let brand: String?
    let barcodes: [ServerBarcode]?
    let amount: ServerAmountWithUnit
    let serving: ServerAmountWithUnit
    let nutrients: ServerNutrients
    let sizes: [ServerSize]
    let density: ServerDensity?
    let linkUrl: String?
    let prefilledUrl: String?
    let imageIds: [UUID]?
}
