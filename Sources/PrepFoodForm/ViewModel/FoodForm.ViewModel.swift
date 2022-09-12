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
        @Published var amountUnit: AmountUnit = .serving
//        @Published var amountWeightUnit: WeightUnit? = nil
//        @Published var amountVolumeUnit: VolumeUnit? = nil
//        @Published var amountUnitIsServing: Bool = true

        @Published var servingAmountString: String = ""
        @Published var servingAmountUnit: SelectionOption = WeightUnit.g
    }
}

extension FoodForm.ViewModel {
    var hasNutrientsPerContent: Bool {
        !amountString.isEmpty
    }
    
    var hasNutrientsPerServingContent: Bool {
        !servingAmountString.isEmpty
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
        Double(servingAmountString) ?? 0
    }
    
    var servingAmountUnitDescription: String {
        servingAmountUnit.title(isPlural: servingAmount > 1) ?? ""
    }
    
    var servingAmountDescription: String {
        "\(servingAmountString) \(servingAmountUnitDescription)"
    }
    
    var amountUnitString: String {
        amountUnit.description
    }
    
    var amountUnitShortString: String {
        amountUnit.shortDescription
    }

}
