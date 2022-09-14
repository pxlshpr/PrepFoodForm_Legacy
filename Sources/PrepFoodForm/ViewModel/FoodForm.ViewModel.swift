import SwiftUI
import PrepUnits
import SwiftUISugar

extension FoodForm {
        
    class ViewModel: ObservableObject {

        @Published var path: [Route] = []

        //MARK: Details
        @Published var name: String = ""
        @Published var emoji = ""
        @Published var detail = ""
        @Published var brand = ""
        @Published var barcode = ""

        //MARK: Nutrients Per
        @Published var amountString: String = ""
        @Published var amountUnit: FormUnit = .serving
        @Published var servingString: String = ""
        @Published var servingUnit: FormUnit = .weight(.g)
        
        @Published var standardSizes: [Size] = []
        @Published var volumePrefixedSizes: [Size] = []
    }
}

extension FoodForm.ViewModel {
    func add(size: Size) {
        withAnimation {
            if size.isVolumePrefixed {
                volumePrefixedSizes.append(size)
            } else {
                standardSizes.append(size)
            }
        }
    }
}

extension FoodForm.ViewModel {
    var allSizes: [Size] {
        standardSizes + volumePrefixedSizes
    }
    
    var allSizesViewModels: [SizeViewModel] {
        allSizes.map { SizeViewModel(size: $0) }
    }

    var standardSizesViewModels: [SizeViewModel] {
        standardSizes
            .filter({ $0.volumePrefixUnit == nil })
            .map { SizeViewModel(size: $0) }
    }

    var volumePrefixedSizesViewModels: [SizeViewModel] {
        volumePrefixedSizes
            .filter({ $0.volumePrefixUnit != nil })
            .map { SizeViewModel(size: $0) }
    }

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
