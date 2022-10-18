import Foundation

extension FoodFormViewModel {
    
    func prefillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        
        for prefillFieldValue in prefillOptionFieldValues(for: fieldValue) {
            
            let info = prefillInfo(for: prefillFieldValue)
            let option = FillOption(
                string: prefillString(for: prefillFieldValue),
                systemImage: Fill.SystemImage.prefill,
                isSelected: fieldValue.shouldSelectFieldValue(prefillFieldValue),
                disableWhenSelected: fieldValue.usesValueBasedTexts, /// disable selected value-based prefills (so not string-based ones that act as toggles)
                type: .fill(.prefill(info))
            )
            fillOptions.append(option)
        }
        return fillOptions
    }
    
    func prefillInfo(for fieldValue: FieldValue) -> PrefillFillInfo {
        switch fieldValue {
        case .name, .brand, .detail:
            return PrefillFillInfo(fieldStrings: fieldValue.prefillFieldStrings)
        case .density(let densityValue):
            return PrefillFillInfo(densityValue: densityValue)
        case .size(let sizeValue):
            return PrefillFillInfo(size: sizeValue.size)
        default:
            return PrefillFillInfo()
        }
    }
    
    func prefillString(for fieldValue: FieldValue) -> String {
        switch fieldValue {
        case .name(let stringValue), .emoji(let stringValue), .brand(let stringValue), .detail(let stringValue):
            return stringValue.string
        case .amount(let doubleValue), .serving(let doubleValue):
            return doubleValue.description
            
        case .energy(let energyValue):
            return energyValue.description
        case .macro(let macroValue):
            return macroValue.description
        case .micro(let microValue):
            return microValue.description
        case .density(let densityValue):
            return densityValue.description(weightFirst: isWeightBased)
            
        case .size(let sizeValue):
            return sizeValue.size.fullNameString.lowercased()
            
        case .barcode(let barcodeValue):
            return "(barcodes prefill not supported)"
        }
    }
    
}

extension FieldValue {
    var prefillFieldStrings: [PrefillFieldString] {
        guard case .prefill(let info) = fill, info.fieldStrings.count == 1 else {
            return []
        }
        return info.fieldStrings
    }
    
    func shouldSelectFieldValue(_ prefillFieldValue: FieldValue) -> Bool {
        
        /// If this is a size—check if they match up
        guard !self.isSize else {
            return self.size == prefillFieldValue.size
        }
        
        /// If this a value based text (which would only ever have one prefill)—return true if its a prefill fill
        guard !self.usesValueBasedTexts else {
            return fill.isPrefill
        }
        
        guard case .prefill(let info) = fill, let fieldString = prefillFieldValue.prefillFieldStrings.first
        else {
            return false
        }
        return info.fieldStrings.contains(fieldString)
    }
}

extension PrefillFieldString: Equatable {
    /// Doesn't care about text case when comparing
    static func ==(lhs: PrefillFieldString, rhs: PrefillFieldString) -> Bool {
        lhs.string.lowercased() == rhs.string.lowercased()
        && lhs.field == rhs.field
    }
}

extension FoodFormViewModel {
    func prefillOptionFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        guard let food = prefilledFood else { return [] }
        
        switch fieldValue {
        case .name, .detail, .brand:
            return food.stringBasedFieldValues
        case .macro(let macroValue):
            return [food.macroFieldValue(for: macroValue.macro)]
        case .micro(let microValue):
            return [food.microFieldValue(for: microValue.nutrientType)].compactMap { $0 }
        case .energy:
            return [food.energyFieldValue]
        case .serving:
            return [food.servingFieldValue].compactMap { $0 }
        case .amount:
            return [food.amountFieldValue].compactMap { $0 }
        case .density:
            return [food.densityFieldValue].compactMap { $0 }
        case .size:
            return prefillOptionSizeFieldValues(for: fieldValue)
//        case .size:
            
//            return food.detail
//        case .barcode(let stringValue):
//            return nil
//        case .density(let densityValue):
//
        default:
            return []
        }
    }
    
    func prefillOptionSizeFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        guard let food = prefilledFood else { return [] }
        return prefillSizeOptionFieldValues(for: fieldValue, from: food.sizeFieldValues)
    }
}

import MFPScraper

extension Fill {
    func replacingSinglePrefillString(with string: String) -> Fill {
        guard isPrefill,
              case .prefill(let prefillFillInfo) = self,
              let fieldString = prefillFillInfo.fieldStrings.first
        else {
            return self
        }
        let copy = PrefillFieldString(string: string, field: fieldString.field)
        return Fill.prefill(.init(fieldStrings: [copy]))
    }
}
extension FieldValue {
    func replacingString(with string: String) -> FieldValue {
        var copy = self
        copy.string = string
        copy.fill = fill.replacingSinglePrefillString(with: string)
        return copy
    }
}

extension FieldValue {
    var stringComponentFieldValues: [FieldValue] {
        var fieldValues: [FieldValue] = []
        for component in string.selectionComponents {
            fieldValues.append(replacingString(with: component))
        }
        return fieldValues
    }
}

extension String {
    var selectionComponents: [String] {
        self
        .components(separatedBy: ",")
        .map {
            $0
                .trimmingWhitespaces
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
                .map { $0.capitalized.capitalizedIfUppercase }
        }
        .reduce([], +)
    }
}

import SwiftSugar

extension MFPProcessedFood {
    var stringBasedFieldValues: [FieldValue] {
        var componentFieldValues: [FieldValue] = []
        let fieldValues = [nameFieldValue, detailFieldValue, brandFieldValue].compactMap { $0 }
        for fieldValue in fieldValues {
            componentFieldValues.append(contentsOf: fieldValue.stringComponentFieldValues)
        }
        return componentFieldValues
    }
    
    var nameFieldStrings: [PrefillFieldString] {
        name
            .selectionComponents
            .map { PrefillFieldString(string: $0, field: .name) }
    }
    var nameFieldValue: FieldValue? {
        guard !name.isEmpty else {
            return nil
        }
//        let fieldString = PrefillFieldString(string: name, field: .name)
        let fill = Fill.prefill(.init(fieldStrings: nameFieldStrings))
        return FieldValue.name(FieldValue.StringValue(string: name, fill: fill))
    }
    
    var detailFieldValue: FieldValue? {
        guard let detail, !detail.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: detail, field: .detail)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.detail(FieldValue.StringValue(string: detail, fill: fill))
    }
    
    var brandFieldValue: FieldValue? {
        guard let brand, !brand.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: brand, field: .brand)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.brand(FieldValue.StringValue(string: brand, fill: fill))
    }

    var densityFieldValue: FieldValue? {
        guard let densitySize = sizes.first(where: { $0.isDensity }),
              let volumeUnit = densitySize.prefixVolumeUnit else  {
            return nil
        }
        
        return FieldValue.density(FieldValue.DensityValue(
            weight: .init(
                double: densitySize.amount,
                string: densitySize.amount.cleanAmount,
                unit: densitySize.amountUnit.formUnit,
                fill: .prefill()),
            volume: .init(
                double: densitySize.quantity,
                string: densitySize.quantity.cleanAmount,
                unit: volumeUnit.formUnit,
                fill: .prefill()),
            fill: .prefill()
        ))
    }
    
    var sizeFieldValues: [FieldValue] {
        sizes.compactMap { $0.sizeFieldValue }
    }
}

extension MFPProcessedFood.Size {
    var sizeFieldValue: FieldValue? {
        guard let prepSize else { return nil }
        return FieldValue.size(.init(
            size: prepSize,
            fill: .prefill(.init(size: prepSize))
        ))
    }
    
    var prepSize: PrepFoodForm.Size? {
        guard !isDensity else { return nil }
        return PrepFoodForm.Size(
            quantity: quantity,
            volumePrefixUnit: prefixVolumeUnit?.formUnit,
            name: name.lowercased(),
            amount: amount,
            unit: amountUnit.formUnit
        )
    }
}

import SwiftUI

struct TempPreview: PreviewProvider {
    static var previews: some View {
        Text(joined)
    }
    
    static var components: [String] {
        "Hi,,,,, hello there what's    up man"
            .components(separatedBy: ",")
            .map {
                $0
                    .trimmingWhitespaces
                    .components(separatedBy: " ")
                    .filter { !$0.isEmpty }
            }
            .reduce([], +)
    }
    
    static var joined: String {
        components
            .joined(separator: "_")
    }
}
