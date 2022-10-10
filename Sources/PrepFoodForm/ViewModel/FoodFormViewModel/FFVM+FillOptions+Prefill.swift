import Foundation

extension FoodFormViewModel {
    
    func prefillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        /// Prefill Options
        //TODO: Check that array returns name, detail and brand for string fields
        for prefillFieldValue in prefillOptionFieldValues(for: fieldValue) {
            var fieldStrings: [PrefillFieldString] = []
            if let fieldString = prefillFieldValue.singlePrefillFieldString {
                fieldStrings.append(fieldString)
            }
            let info = PrefillFillInfo(fieldStrings: fieldStrings)
            let option = FillOption(
                string: prefillFieldValue.prefillString,
                systemImage: Fill.SystemImage.prefill,
                isSelected: fieldValue.prefillFillContains(prefillFieldValue),
                disableWhenSelected: false,
                type: .fill(.prefill(info))
            )
            fillOptions.append(option)
        }
        return fillOptions
    }
}

extension FieldValue {
    var singlePrefillFieldString: PrefillFieldString? {
        guard case .prefill(let info) = fill, info.fieldStrings.count == 1 else {
            return nil
        }
        return info.fieldStrings.first
    }
    
    func prefillFillContains(_ prefillFieldValue: FieldValue) -> Bool {
        
        /// If this a value based text (which would only ever have one prefill)—return true if its a prefill fill
        guard !self.usesValueBasedTexts else {
            return fill.isPrefill
        }
        
        guard case .prefill(let info) = fill,
              let fieldString = prefillFieldValue.singlePrefillFieldString
        else {
            return false
        }
        return info.fieldStrings.contains(fieldString)
    }
}

extension FoodFormViewModel {
    func prefillOptionFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        guard let food = prefilledFood else {
            return []
        }
        
        switch fieldValue {
        case .name, .detail, .brand:
            return food.stringBasedPrefillFieldValues
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
}

import MFPScraper

extension MFPProcessedFood {
    var stringBasedPrefillFieldValues: [FieldValue] {
        [namePrefillFieldValue, detailPrefillFieldValue, brandPrefillFieldValue].compactMap { $0 }
    }
    
    var namePrefillFieldValue: FieldValue? {
        guard !name.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: name, field: .name)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.name(FieldValue.StringValue(string: name, fill: fill))
    }
    
    var detailPrefillFieldValue: FieldValue? {
        guard let detail, !detail.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: detail, field: .detail)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.detail(FieldValue.StringValue(string: detail, fill: fill))
    }
    
    var brandPrefillFieldValue: FieldValue? {
        guard let brand, !brand.isEmpty else {
            return nil
        }
        let fieldString = PrefillFieldString(string: brand, field: .brand)
        let fill = Fill.prefill(.init(fieldStrings: [fieldString]))
        return FieldValue.brand(FieldValue.StringValue(string: brand, fill: fill))
    }

}

