import FoodLabelScanner
import PrepUnits

extension FieldValue {
    var altValues: [FoodLabelValue] {
//        guard !fillType.isAltValue else { return [] }
        switch self {
        case .energy(let energyValue):
            return energyValue.altValues
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .name(let stringValue):
//            <#code#>
//        case .emoji(let stringValue):
//            <#code#>
//        case .brand(let stringValue):
//            <#code#>
//        case .barcode(let stringValue):
//            <#code#>
//        case .detail(let stringValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
        default:
            return []
        }
    }
}

extension FoodLabelValue {
    
    /**
     Returns the same value with the opposite energy unit (so `.kcal` if its `.kJ` and vice versa).
     
     This assumes that any non-energy or unit-less values are `.kcal`—to ensure a value is always used—so in those cases expect the value with a `.kJ` unit to be returned.
     */
    var withOppositeEnergyUnit: FoodLabelValue {
        let unit = unit?.energyUnit ?? .kcal
        let oppositeEnergyUnit: FoodLabelUnit
        switch unit {
        case .kJ:
            oppositeEnergyUnit = .kcal
        case .kcal:
            oppositeEnergyUnit = .kj
        }
        return FoodLabelValue(amount: amount, unit: oppositeEnergyUnit)
    }
    
    
    /**
     Returns this value forced as an energy value. If it is already an energy value, it isn't changed. If it has another (or no) unit however—`.kcal` is used as a default and this is returned with it.
     
     This is used when presenting fill options for the energy value for the user—when reading in values from a food label that may have been misread or read without a unit.
     */
    var withEnergyUnit: FoodLabelValue {
        switch unit {
        case .kj:
            return self
        default:
            return FoodLabelValue(amount: amount, unit: .kcal)
        }
    }
    
    /**
     Returns this value forced as macro value—returned with a 'g' unit.
     */
    var withMacroUnit: FoodLabelValue {
        FoodLabelValue(amount: amount, unit: .g)
    }

    /**
     Returns this value forced as micro value—if it doesn't have one of the supported units, then it is returned with the default unit for the provided nutrient type.
     */
    func withMicroUnit(for nutrientType: NutrientType) -> FoodLabelValue {
        guard let unit, nutrientType.supportsUnit(unit) else {
            return FoodLabelValue(amount: amount, unit: nutrientType.defaultUnit.foodLabelUnit)
        }
        return self
    }
}

extension NutrientType {
    
    var defaultUnit: NutrientUnit {
        units.first ?? .g
    }
    
    func supportsUnit(_ foodLabelUnit: FoodLabelUnit) -> Bool {
        guard let nutrientUnit = foodLabelUnit.nutrientUnit(for: self) else { return false }
        return supportsUnit(nutrientUnit)
    }
    
    func supportsUnit(_ nutrientUnit: NutrientUnit) -> Bool {
        units.contains(nutrientUnit)
    }
}

extension FieldValue.EnergyValue {
    /**
     Returns the `FoodLabelValue` to generate alts for. This is either the `altValue` currently attached to this—or the first value that's detected in the string (which is initially assigned to this when the text is selected).
    */
    var valueToGenerateAltsFor: FoodLabelValue? {
        switch fillType {
        case .imageSelection(let recognizedText, _, _, let altValue):
            return altValue ?? recognizedText.string.energyValue
        case .imageAutofill(let valueText, _, let altValue):
            return altValue ?? valueText.value
        default:
            return nil
        }
    }
    
    var altValue: FoodLabelValue? {
        switch fillType {
        case .imageSelection(_, _, _, let altValue):
            return altValue
        case .imageAutofill(_, _, let altValue):
            return altValue
        default:
            return nil
        }
    }
    
    var altValues: [FoodLabelValue] {
        guard let valueToGenerateAltsFor else { return [] }
        
        var values: [FoodLabelValue] = []
        
        /// First add the opposite unit
        values.append(valueToGenerateAltsFor.withOppositeEnergyUnit)
        
        /// Add any other values that were found
        for value in fillType.detectedValues {
            
            /// Skip any values
            guard
                value.amount != double,                                 /// that have the same amount as the current field
                !values.contains(where: { $0.amount == value.amount })   /// or has already been picked
            else {
                continue
            }
            
            /// If there is no unit for this value, assign it `.kcal` arbitrarily
            let unit = value.unit?.isEnergy == true ? value.unit : .kcal
            let value = FoodLabelValue(amount: value.amount, unit: unit)
            values.append(value)
            
            /// Also add the value with the opposite energy unit to this
            values.append(value.withOppositeEnergyUnit)
        }
        
        return values
    }
}
