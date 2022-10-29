import Foundation
import PrepDataTypes

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
            
        case .barcode:
            return "(barcodes prefill not supported)"
        }
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
