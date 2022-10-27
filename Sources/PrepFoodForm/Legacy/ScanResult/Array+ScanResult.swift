import FoodLabelScanner
import SwiftSugar
import PrepDataTypes

extension ScanResult {
    func fieldValue(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
        switch fieldValue {
        case .amount:
            return amountFieldValue(for: column)
        case .serving:
            return servingFieldValue(for: column)
        case .density:
            return densityFieldValue
        case .energy:
            return energyFieldValue(at: column)
        case .macro(let macroValue):
            return macroFieldValue(for: macroValue.macro, at: column)
        case .micro(let microValue):
            return microFieldValue(for: microValue.nutrientType, at: column)
        default:
            return nil
        }
    }
}

enum FieldType {
    case amount, serving, density, energy, macro, micro
}

extension Array where Element == ScanResult {

    func bestFieldValues(at column: Int) -> [FieldValue] {
        
        /// Single fields
        var fieldValues: [FieldValue?] = [
            bestAmountFieldValue(at: column),
            bestServingFieldValue(at: column),
            bestDensityFieldValue,
            bestEnergyFieldValue(at: column)
        ]

        /// Macros
        for macro in Macro.allCases {
            fieldValues.append(bestMacroFieldValue(macro, at: column))
        }
        
        /// Micronutrients
        for nutrientType in NutrientType.allCases {
            fieldValues.append(bestMicroFieldValue(nutrientType, at: column))
        }
        
        /// Sizes
        fieldValues.append(contentsOf: allSizeFieldValues(at: column))

        /// Barcodes
        fieldValues.append(contentsOf: allBarcodeFieldValues)

        return fieldValues.compactMap { $0 }
    }
    
    func bestFieldValue(for fieldValue: FieldValue, at column: Int) -> FieldValue? {
        switch fieldValue {
        case .amount:
            return bestAmountFieldValue(at: column)
        case .serving:
            return bestServingFieldValue(at: column)
        case .density:
            return bestDensityFieldValue
        case .energy:
            return bestEnergyFieldValue(at: column)
        case .macro(let macroValue):
            return bestMacroFieldValue(macroValue.macro, at: column)
        case .micro(let microValue):
            return bestMicroFieldValue(microValue.nutrientType, at: column)
        default:
            return nil
        }
    }
    
    func bestAmountFieldValue(at column: Int) -> FieldValue? {
        filter { $0.amountFieldValue(for: column) != nil }
            .bestScanResult?
            .amountFieldValue(for: column)
    }
    
    func bestServingFieldValue(at column: Int) -> FieldValue? {
        filter { $0.servingFieldValue(for: column) != nil }
            .bestScanResult?
            .servingFieldValue(for: column)
    }
    
    var bestDensityFieldValue: FieldValue? {
        filter { $0.densityFieldValue != nil }
            .bestScanResult?
            .densityFieldValue
    }
    
    func bestEnergyFieldValue(at column: Int) -> FieldValue? {
        filter { $0.containsValue(for: .energy, at: column) }
            .bestScanResult?
            .energyFieldValue(at: column)
    }
    
    func bestMacroFieldValue(_ macro: Macro, at column: Int) -> FieldValue? {
        filter { $0.containsValue(for: macro.attribute, at: column) }
            .bestScanResult?
            .macroFieldValue(for: macro, at: column)
    }
    
    func bestMicroFieldValue(_ nutrientType: NutrientType, at column: Int) -> FieldValue? {
        guard let attribute = nutrientType.attribute else { return nil }
        return filter { $0.containsValue(for: attribute, at: column) }
            .bestScanResult?
            .microFieldValue(for: nutrientType, at: column)
    }
}

extension Array where Element == ScanResult {
    
    var allBarcodeFieldValues: [FieldValue] {
        reduce([]) { partialResult, scanResult in
            partialResult + scanResult.barcodeFieldValues
        }
    }

    func allSizeFieldValues(at column: Int) -> [FieldValue] {
        guard let bestScanResult else { return [] }
        var fieldValues: [FieldValue] = []
        
        /// Start by adding the best `ScanResult`'s size view models (as it gets first preference)
        fieldValues.append(contentsOf: bestScanResult.allSizeFieldValues(at: column))
        
        /// Now go through the remaining `ScanResult`s and add those
        for scanResult in filter({ $0.id != bestScanResult.id }) {
            fieldValues.append(contentsOf: scanResult.allSizeFieldValues(at: column))
        }
        
        return fieldValues
    }

    //TODO: Remove this
    var allBarcodeViewModels: [Field] {
        allBarcodeFieldValues.map { Field(fieldValue: $0) }
    }

    //TODO: Remove this
    func allSizeViewModels(at column: Int) -> [Field] {
        allSizeFieldValues(at: column)
            .map { Field(fieldValue: $0) }
    }
    
    /**
     First gets the `bestScanResult` (with the greatest `nutrientCount`).
     
     Then filters this array to only include those that have the same number of columns as this best result, and matches the headers, *if present*.
     */
    var candidateScanResults: [ScanResult] {
        guard let bestScanResult else { return [] }
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
//    var columnWithTheMostNutrients: Int {
//        map { $0.columnWithTheMostNutrients}
//            .mostFrequent ?? 1
//    }

    func imageTextsForColumnSelection(at column: Int) -> [ImageText] {
        var fieldValues: [FieldValue?] = []
        fieldValues.append(bestEnergyFieldValue(at: column))
        for macro in Macro.allCases {
            fieldValues.append(bestMacroFieldValue(macro, at: column))
        }
        for nutrientType in NutrientType.allCases {
            fieldValues.append(bestMicroFieldValue(nutrientType, at: column))
        }
        return fieldValues.compactMap({ $0?.fill.imageText })
    }
    
    /** Minimum number of columns */
    var minimumNumberOfColumns: Int {
        allSatisfy({ $0.columnCount == 2 }) ? 2 : 1
    }
}

extension ScanResult {
    
    func containsValue(for attribute: Attribute, at column: Int) -> Bool {
        nutrients.rows.contains { row in
            row.attribute == attribute
            && ( column == 1 ? row.value1 != nil : row.value2 != nil )
        }
    }
    
    var bestColumn: Int {
        columnWithTheMostNutrients ?? columnWithLargerValues
    }
    
    var columnWithLargerValues: Int {
        var isLargerCount1 = 0
        var isLargerCount2 = 0
        for row in nutrients.rows {
            guard let value1 = row.value1, let value2 = row.value2 else {
                continue
            }
            if value1.amount > value2.amount { isLargerCount1 += 1 }
            if value2.amount > value1.amount { isLargerCount2 += 1 }
        }
        return isLargerCount1 > isLargerCount2 ? 1 : 2
    }

    /**
     Returns the column number with the most number of non-nil nutrients.
     
     Remember that the column numbers aren't 0-based, so they start at 1.
     Returns `nil` if they are both equal.
     */
    var columnWithTheMostNutrients: Int? {
        let count1 = nutrientsCount(column: 1)
        let count2 = nutrientsCount(column: 2)
        guard count1 != count2 else { return nil }
        return count1 > count2 ? 1 : 2
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
        if isTabular { return 2 }
        if nutrientCount > 0 { return 1 }
        return 0
//        isTabular ? 2 : 1
    }
}
