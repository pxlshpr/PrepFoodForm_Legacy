import SwiftUI
import NutritionLabelClassifier
import SwiftHaptics
import PrepUnits

extension FoodFormViewModel {

    func processAllClassifierOutputs() {
        let outputs = imageViewModels.compactMap { $0.output }
        
        //TODO: Decide which column we're going to be using
        /// let's do energy
        extractEnergy(from: outputs)
    }

    //TODO: Store an ImageId that identifies the ImageViewModel in the fillType
    func extractEnergy(from outputs: [Output]) {
        var candidate: FieldValue? = nil
        var nutrientCountOfArrayContainingCandidate = 0
        for output in outputs {
            guard let energyFieldValue = output.energyFieldValue else {
                continue
            }
            
            /// Keep picking the candidate that comes from the output with the largest set of nutrients in case of duplicates (for now)
            //TODO: Improve this
            if output.nutrients.rows.count > nutrientCountOfArrayContainingCandidate {
                nutrientCountOfArrayContainingCandidate = output.nutrients.rows.count
                candidate = energyFieldValue
            }
        }
        
        if let candidate {
            withAnimation {
                energy = candidate
            }
        }
    }
}

extension Output {
    var energyFieldValue: FieldValue? {
        guard let row = row(for: .energy),
              let valueText = row.valueText1,
              let value = row.value1
        else {
            return nil
        }
        return FieldValue.energy(FieldValue.EnergyValue(
            double: value.amount,
            string: value.amount.cleanAmount,
            unit: value.unit?.energyUnit ?? .kcal,
            fillType: .imageAutofill(valueText: valueText, outputId: self.id)))
    }
    
    func row(for attribute: Attribute) -> Output.Nutrients.Row? {
        nutrients.rows.first(where: { $0.attribute == attribute })
    }
}

extension NutritionUnit {
    var energyUnit: EnergyUnit {
        switch self {
        case .kcal:
            return .kcal
        case .kj:
            return .kJ
        default:
            return .kcal
        }
    }
}
