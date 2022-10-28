import SwiftUI
import FoodLabel
import PrepDataTypes
import MFPScraper
import VisionSugar

let DefaultAmount = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving, fill: .discardable))

extension FoodForm {
    
    class Fields: ObservableObject {
        
        static var shared = Fields()
        
        @Published var amount: Field
        @Published var serving: Field
        @Published var energy: Field
        @Published var carb: Field
        @Published var fat: Field
        @Published var protein: Field
        
        @Published var standardSizes: [Field] = []
        @Published var volumePrefixedSizes: [Field] = []
        @Published var density: Field

//        @Published var micronutrients: [MicroGroupTuple] = DefaultMicronutrients()
        
        @Published var microsFats: [Field] = []
        @Published var microsFibers: [Field] = []
        @Published var microsSugars: [Field] = []
        @Published var microsMinerals: [Field] = []
        @Published var microsVitamins: [Field] = []
        @Published var microsMisc: [Field] = []
        
        @Published var barcodes: [Field] = []

        @Published var shouldShowFoodLabel: Bool = false
        
        /**
         These are the last extracted `FieldValues` returned from the `FieldsExtractor`,
         which would have analysed and picked the best values from all available `ScanResult`s
         (after the user selects a column if applicable).
         */
        var extractedFieldValues: [FieldValue] = []
        var prefilledFood: MFPProcessedFood? = nil

        var sizeBeingEdited: FormSize? = nil

        init() {
            self.amount = .init(fieldValue: DefaultAmount)
            self.serving = .init(fieldValue: .serving())
            self.energy = .init(fieldValue: .energy())
            self.carb = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .carb)))
            self.fat = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .fat)))
            self.protein = .init(fieldValue: .macro(FieldValue.MacroValue(macro: .protein)))
            self.density = .init(fieldValue: .density(FieldValue.DensityValue()))
        }
    }
}
