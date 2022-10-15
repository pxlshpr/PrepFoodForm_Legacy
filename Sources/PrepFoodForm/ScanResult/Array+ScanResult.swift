import FoodLabelScanner
import SwiftSugar
import PrepUnits

extension Array where Element == ScanResult {

    func pickFieldValue(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
        switch fieldValue {
        case .amount:
            return pickedAmount(at: column)
        case .serving:
            return pickedServing(at: column)
        case .density:
            return pickedDensity
        case .energy:
            return pickEnergy(at: column)
        case .macro(let macroValue):
            return pickedMacro(macroValue.macro, at: column)
        case .micro(let microValue):
            return pickedMicro(microValue.nutrientType, at: column)
        default:
            return nil
        }
    }
    
    func pickedAmount(at column: Int) -> FieldValue? {
        filter { $0.amountFieldValue(for: column) != nil }
            .bestScanResult?
            .amountFieldValue(for: column)
    }
    
    func pickedServing(at column: Int) -> FieldValue? {
        filter { $0.servingFieldValue(for: column) != nil }
            .bestScanResult?
            .servingFieldValue(for: column)
    }
    
    var pickedDensity: FieldValue? {
        filter { $0.densityFieldValue != nil }
            .bestScanResult?
            .densityFieldValue
    }
    
    func pickEnergy(at column: Int) -> FieldValue? {
        filter { $0.containsValue(for: .energy, at: column) }
            .bestScanResult?
            .energyFieldValue(at: column)
    }
    
    func pickedMacro(_ macro: Macro, at column: Int) -> FieldValue? {
        filter { $0.containsValue(for: macro.attribute, at: column) }
            .bestScanResult?
            .macroFieldValue(for: macro, at: column)
    }
    
    func pickedMicro(_ nutrientType: NutrientType, at column: Int) -> FieldValue? {
        guard let attribute = nutrientType.attribute else { return nil }
        return filter { $0.containsValue(for: attribute, at: column) }
            .bestScanResult?
            .microFieldValue(for: nutrientType, at: column)
    }
}

extension Array where Element == ScanResult {
    
    var allBarcodeViewModels: [FieldViewModel] {
        reduce([]) { partialResult, scanResult in
            partialResult + scanResult.barcodeFieldValues.map { FieldViewModel(fieldValue: $0) }
        }
    }
    
    var allSizeViewModels: [FieldViewModel] {
        guard let bestScanResult else { return [] }
        var sizeViewModels: [FieldViewModel] = []
        
        /// Start by adding the best `ScanResult`'s size view models (as it gets first preference)
        sizeViewModels.append(contentsOf: bestScanResult.allSizeViewModels)
        
        /// Now go through the remaining `ScanResult`s and add those
        for scanResult in filter({ $0.id != bestScanResult.id }) {
            sizeViewModels.append(contentsOf: scanResult.allSizeViewModels)
        }
        
        return sizeViewModels
    }
    
    var relevantScanResults: [ScanResult]? {
        guard let bestScanResult else { return nil }
        return filter {
            $0.columnCount == bestScanResult.columnCount
            && $0.hasCompatibleHeadersWith(bestScanResult)
        }
    }
    
    /// Returns the scan result with the most number of nutrient rows
    var bestScanResult: ScanResult? {
        sorted(by: { $0.nutrientCount > $1.nutrientCount })
            .first
    }
    
    /// Returns true if any of the `ScanResult` in this array is tabular
    var hasTabularScanResult: Bool {
        contains(where: { $0.isTabular })
    }
    
    /**
     Returns the column number with the most number of non-nil nutrients in all the ScanResults.
     
     Remember that the column numbers aren't 0-based, so they start at 1.
     Returns 1 if they are both equal.
     */
    var columnWithTheMostNutrients: Int {
        map { $0.columnWithTheMostNutrients}
            .mostFrequent ?? 1
    }
}

extension ScanResult {
    
    func containsValue(for attribute: Attribute, at column: Int) -> Bool {
        nutrients.rows.contains { row in
            row.attribute == attribute
            && ( column == 1 ? row.value1 != nil : row.value2 != nil )
        }
    }
    
    //TODO: Make this consider which column has the larger set of values and return that if the counts are equal on both sides.
    /**
     Returns the column number with the most number of non-nil nutrients.
     
     Remember that the column numbers aren't 0-based, so they start at 1.
     Returns 1 if they are both equal.
     */
    var columnWithTheMostNutrients: Int {
        nutrientsCount(column: 1) >= nutrientsCount(column: 2) ? 1 : 2
    }
    
    /**
     Returns the number of non-nil nutrients in the column specified.
     
     Remember that the column numbers aren't 0-based, so they start at 1.
     */
    func nutrientsCount(column: Int) -> Int {
        nutrients.rows.filter({
            column == 1 ? $0.value1 != nil : $0.value2 != nil
        }).count
    }
    
    /**
     Returns true if the header types between both match (when present).
     
     Empty headers don't disqualify a ScanResult set for compatibility.
     */
    func hasCompatibleHeadersWith(_ other: ScanResult) -> Bool {
        hasCompatibleHeader1With(other)
        && hasCompatibleHeader2With(other)
    }
    
    /**
     Only returns `false` if we have both headers and they don't match.
     
     Will return `true` if either or both sides are empty.
     */
    func hasCompatibleHeader1With(_ other: ScanResult) -> Bool {
        guard let header1Type = headers?.header1Type,
              let otherHeader1Type = other.headers?.header1Type
        else {
            return true
        }
        return header1Type == otherHeader1Type
    }

    /**
     Only returns `false` if we have both headers and they don't match.
     
     Will return `true` if either or both sides are empty.
     */
    func hasCompatibleHeader2With(_ other: ScanResult) -> Bool {
        guard let header2Type = headers?.header2Type,
              let otherHeader2Type = other.headers?.header2Type
        else {
            return true
        }
        return header2Type == otherHeader2Type
    }

    /**
     Returns the number of nutrients in this `ScanResult`.
     
     Only rows with at least one value are counted.
     */
    var nutrientCount: Int {
        nutrients.rows.filter({ $0.value1 != nil || $0.value2 != nil }).count
    }
    
    /// Returns true if tabular—which is determined by any of the nutrient rows having a non-nil `value2`
    var isTabular: Bool {
        self.nutrients.rows.contains(where: { $0.value2 != nil })
    }
    
    var columnCount: Int {
        isTabular ? 2 : 1
    }
}
