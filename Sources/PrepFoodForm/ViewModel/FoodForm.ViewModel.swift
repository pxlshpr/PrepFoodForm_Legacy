import SwiftUI
import PrepUnits
import SwiftUISugar

extension FoodForm {
    
    class ViewModel: ObservableObject {
        
        //MARK: Details
        @Published var name: String = ""
        @Published var emoji = ""
        @Published var detail = ""
        @Published var brand = ""
        @Published var barcode = ""

        //MARK: Serving
        @Published var amountString: String = ""
        @Published var amountUnit: FormUnit = .serving
//        @Published var amountWeightUnit: WeightUnit? = nil
//        @Published var amountVolumeUnit: VolumeUnit? = nil
//        @Published var amountUnitIsServing: Bool = true

        @Published var servingString: String = ""
        @Published var servingUnit: FormUnit = .weight(.g)
    }
}

extension FoodForm.ViewModel {
    var hasNutrientsPerContent: Bool {
        !amountString.isEmpty
    }
    
    var hasNutrientsPerServingContent: Bool {
        !servingString.isEmpty
    }
    
    var amount: Double {
        Double(amountString) ?? 0
    }
    
//    var amountUnitDescription: String {
//        amountUnit.title(isPlural: amount > 1) ?? ""
//    }
    
    var amountDescription: String {
        "\(amountString) \(amountUnitShortString)"
    }
    
    var servingAmount: Double {
        Double(servingString) ?? 0
    }
    
    var servingUnitDescription: String {
        servingUnit.description
    }
    
    var servingUnitShortString: String {
        servingUnit.shortDescription
    }
    
    var servingDescription: String {
        "\(servingString) \(servingUnitShortString)"
    }
    
    var amountUnitString: String {
        amountUnit.description
    }
    
    var amountUnitShortString: String {
        amountUnit.shortDescription
    }

}
