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
        @Published var amountString: String = "" {
            didSet {
                updateShouldShowDensitiesSection()
            }
        }
        
        @Published var amountUnit: FormUnit = .serving {
            didSet {
                updateShouldShowDensitiesSection()
                if amountUnit != .serving {
                    servingString = ""
                    servingUnit = .weight(.g)
                }
            }
        }
        @Published var servingString: String = "" {
            didSet {
                /// If we've got a serving-based unit for the serving size—modify it to make sure the values equate
                modifyServingUnitIfServingBased()
                updateShouldShowDensitiesSection()
//                if !servingString.isEmpty && amountString.isEmpty {
//                    amountString = "1"
//                }
            }
        }
        @Published var servingUnit: FormUnit = .weight(.g) {
            didSet {
                updateShouldShowDensitiesSection()
            }
        }
        
        @Published var shouldShowDensitiesSection: Bool = false
        
        @Published var standardSizes: [Size] = []
        @Published var volumePrefixedSizes: [Size] = []
        @Published var summarySizeViewModels: [SizeViewModel] = []
        
        @Published var densityWeightString: String = ""
        @Published var densityWeightUnit: FormUnit = .weight(.g)
        @Published var densityVolumeString: String = ""
        @Published var densityVolumeUnit: FormUnit = .volume(.mL)
        
        init(prefilledWithMockData: Bool = false, onlyServing: Bool = false) {
            guard prefilledWithMockData else {
                return
            }
            
            if onlyServing {
                let sizes = [
                    Size(quantity: 1, name: "container", amount: 5, amountUnit: .serving)
                ]
                
                self.standardSizes = sizes
                self.summarySizeViewModels = sizes.map { SizeViewModel(size: $0) }

                self.amountString = "1"
                self.servingString = "0.2"
                self.servingUnit = .size(standardSizes.first!, nil)
            } else {
                self.name = "Carrot"
                self.emoji = "🥕"
                self.detail = "Baby"
                self.brand = "Woolworths"
                self.barcode = "5012345678900"
                
                self.amountString = "1"
                self.amountUnit = .serving
                self.servingString = "50"
                self.servingUnit = .weight(.g)
                
                self.densityWeightString = "20"
                self.densityWeightUnit = .weight(.g)
                self.densityVolumeString = "25"
                self.densityVolumeUnit = .volume(.mL)
                
                self.standardSizes = mockStandardSizes
                self.volumePrefixedSizes = mockVolumePrefixedSizes
                
                self.summarySizeViewModels = Array((standardSizes + volumePrefixedSizes).map { SizeViewModel(size: $0) }.prefix(maxNumberOfSummarySizeViewModels))
            }
        }
    }
}

extension FormUnit {
    var isWeightBased: Bool {
        unitType == .weight
    }
    
    var isVolumeBased: Bool {
        unitType == .volume
    }
}

extension FoodForm.ViewModel {

    func updateShouldShowDensitiesSection() {
        withAnimation {
            shouldShowDensitiesSection =
            ((amountUnit.isWeightBased || amountUnit.isVolumeBased) && amount > 0)
            ||
            ((servingUnit.isWeightBased || servingUnit.isVolumeBased) && servingAmount > 0)
        }
    }

    var isWeightBased: Bool {
        amountUnit.isWeightBased || servingUnit.isWeightBased
    }

    var isVolumeBased: Bool {
        amountUnit.isVolumeBased || servingUnit.isVolumeBased
    }

    func modifyServingAmount(for newUnit: FormUnit) {
        guard newUnit.isServingBased, case .size(let size, _) = newUnit else {
            return
        }
        let newServingAmount: Double
        if size.amount > 0 {
            newServingAmount = size.quantity / size.amount
        } else {
            newServingAmount = 0
        }
        
        servingString = "\(newServingAmount.clean)"
    }

    func modifyServingUnitIfServingBased() {
        guard servingUnit.isServingBased, case .size(let size, _) = servingUnit else {
            return
        }
        let newAmount: Double
        if servingAmount > 0 {
            newAmount = size.quantity / servingAmount
        } else {
            newAmount = 0
        }
        
        print("Now we need to change: \(size) to new amount \(newAmount)")
        
        standardSizes.first!.amount = newAmount
        updateSummary()
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

    var densityWeightAmount: Double {
        Double(densityWeightString) ?? 0
    }

    var densityVolumeAmount: Double {
        Double(densityVolumeString) ?? 0
    }
    
    var hasValidDensity: Bool {
        densityWeightAmount > 0
        && densityVolumeAmount > 0
        && densityWeightUnit.unitType == .weight
        && densityVolumeUnit.unitType == .volume
    }

    var densityDescription: String? {
        guard hasValidDensity else {
            return nil
        }
                
        let weight = "\(densityWeightAmount.cleanAmount) \(densityWeightUnit.shortDescription)"
        let volume = "\(densityVolumeAmount.cleanAmount) \(densityVolumeUnit.shortDescription)"
        
        if isWeightBased {
            return "\(weight) = \(volume)"
        } else {
            return "\(volume) = \(weight)"
        }
    }
    
    var lhsDensityAmountString: String {
        if isWeightBased {
            return densityWeightAmount.cleanAmount
        } else {
            return densityVolumeAmount.cleanAmount
        }
    }
    
    var rhsDensityAmountString: String {
        if isWeightBased {
            return densityVolumeAmount.cleanAmount
        } else {
            return densityWeightAmount.cleanAmount
        }
    }

    var lhsDensityUnitString: String {
        if isWeightBased {
            return densityWeightUnit.shortDescription
        } else {
            return densityVolumeUnit.shortDescription
        }
    }
    
    var rhsDensityUnitString: String {
        if isWeightBased {
            return densityVolumeUnit.shortDescription
        } else {
            return densityWeightUnit.shortDescription
        }
    }

}
