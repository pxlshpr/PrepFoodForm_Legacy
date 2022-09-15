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
        @Published var amountUnit: FormUnit = .serving {
            didSet {
                if amountUnit != .serving {
                    servingString = ""
                    servingUnit = .weight(.g)
                }
            }
        }
        @Published var servingString: String = "" {
            didSet {
                servingAmountChanged()
            }
        }
        @Published var servingUnit: FormUnit = .weight(.g)
        
        @Published var standardSizes: [Size] = []
        @Published var volumePrefixedSizes: [Size] = []
        
        init(prefilledWithMockData: Bool = false) {
            guard prefilledWithMockData else {
                return
            }
            self.name = "Carrot"
            self.emoji = "🥕"
            self.detail = "Baby"
            self.brand = "Woolworths"
            self.barcode = "5012345678900"
            
            self.amountString = "1"
            self.amountUnit = .serving
            self.servingString = "50"
            self.servingUnit = .weight(.g)
            
            self.standardSizes = mockStandardSizes
            self.volumePrefixedSizes = mockVolumePrefixedSizes
        }
    }
}

extension FoodForm.ViewModel {
    func servingAmountChanged() {
        if servingUnit.isServingBased {
            
        }
    }
    func add(size: Size) {
        withAnimation {
            if size.isVolumePrefixed {
                volumePrefixedSizes.append(size)
            } else {
                standardSizes.append(size)
            }
        }
    }
    
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
    
    var hasServing: Bool {
        amountUnit == .serving
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
