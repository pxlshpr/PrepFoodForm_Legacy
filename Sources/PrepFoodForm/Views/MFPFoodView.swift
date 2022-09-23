import SwiftUI
import MFPScraper
import FoodLabel
import PrepUnits

struct MFPSizeViewModel: Hashable {
    let size: MFPProcessedFood.Size

    var nameString: String {
        size.name.lowercased()
    }
    
    var fullNameString: String {
        if let volumePrefixUnit = size.nameVolumeUnit {
            return "\(volumePrefixUnit.shortDescription), \(nameString)"
        } else {
            return nameString
        }
    }

    var scaledAmountString: String {
        "\(scaledAmount.cleanAmount) \(amountUnitDescription.lowercased())"
    }
    
    var amountUnitDescription: String {
        switch size.amountUnit {
        case .weight:
            return size.amountWeightUnit?.description ?? ""
        case .volume:
            return size.amountVolumeUnit?.description ?? ""
        case .size:
            return size.amountSizeUnit?.nameDescription ?? ""
        case .serving:
            return "serving"
        }
    }

    var scaledAmount: Double {
        guard size.quantity > 0 else {
            return 0
        }
        return size.amount / size.quantity
    }
}

extension MFPFoodView {
    struct SizeCell: View {
        var sizeViewModel: MFPSizeViewModel
    }
}

extension MFPFoodView.SizeCell {
    var body: some View {
        HStack {
            Text(sizeViewModel.fullNameString)
                .foregroundColor(.primary)
            Spacer()
            HStack {
                Text(sizeViewModel.scaledAmountString)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}
struct MFPFoodView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(result: MFPSearchResultFood, processedFood: MFPProcessedFood? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel(result: result, processedFood: processedFood))
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text(viewModel.name)
                        .bold()
                    if viewModel.shouldDetailString {
                        Text(viewModel.detail)
                    }
                    if let brand = viewModel.brand {
                        Text(brand)
                            .foregroundColor(.secondary)
                    }
                }
            }
            loadingIndicator
            foodLabelSection
            sizesSection
        }
        .navigationTitle("MyFitnessPal Food")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var loadingIndicator: some View {
        if viewModel.isLoadingFoodDetails {
            ProgressView()
        }
    }
    @ViewBuilder
    var sizesSection: some View {
        if let sizeViewModels = viewModel.sizeViewModels {
            Section("Sizes") {
                ForEach(sizeViewModels, id: \.self) {
                    SizeCell(sizeViewModel: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    var foodLabelSection: some View {
        if viewModel.shouldShowFoodLabel {
            FoodLabel(dataSource: viewModel)
        }
    }
}

extension MFPFoodView.ViewModel: FoodLabelDataSource {
    var amountString: String {
        firstSizeDescription ?? ""
    }

    var energyAmount: Double {
        processedFood?.energy ?? 0
    }
    
    var carbAmount: Double {
        processedFood?.carbohydrate ?? 0
    }
    
    var fatAmount: Double {
        processedFood?.fat ?? 0
    }
    
    var proteinAmount: Double {
        processedFood?.protein ?? 0
    }
    
    var nutrients: [NutrientType : Double] {
        guard let nutrients = processedFood?.nutrients else {
            return [:]
        }
        return nutrients.reduce(into: [NutrientType: Double]()) {
            $0[$1.type] = $1.amount
        }
    }
    
    var showFooterText: Bool {
        false
    }
    
    var showRDAValues: Bool {
        false
    }
    
    var haveMicros: Bool {
        false
    }
    
    var haveCustomMicros: Bool {
        false
    }
    
    func nutrient(ofType: NutrientType) -> Double? {
        nil
    }
}
extension MFPFoodView.ViewModel {
    
    var name: String {
        result.name
    }
    
    var detail: String {
        result.detail
    }
    
    var brand: String? {
        processedFood?.brand
    }
    
    var sizes: [MFPProcessedFood.Size]? {
        guard let processedFood = processedFood else {
            return nil
        }
        let sizes = processedFood.sizes.filter { !$0.name.isEmpty }
        guard !sizes.isEmpty else {
            return nil
        }
        return sizes
    }
    
    var sizeViewModels: [MFPSizeViewModel]? {
        guard let sizes = sizes else {
            return nil
        }
        return sizes.map { MFPSizeViewModel(size: $0) }
    }
    
    var shouldShowFoodLabel: Bool {
        processedFood != nil
    }
    
    var firstSize: MFPProcessedFood.Size? {
        sizes?.first
    }
    
    var firstSizeDescription: String? {
        guard let firstSize else {
            return nil
        }
        return "\(firstSize.quantity.cleanAmount) \(firstSize.name)"
    }
    
    var shouldDetailString: Bool {
        if let firstSizeDescription,
           firstSizeDescription.lowercased() == detail.lowercased() {
            return false
        } else {
            return true
        }
    }
}

extension MFPFoodView {
    
    class ViewModel: ObservableObject {
        @Published var result: MFPSearchResultFood
        @Published var processedFood: MFPProcessedFood? = nil
        @Published var isLoadingFoodDetails = false
        
        init(result: MFPSearchResultFood, processedFood: MFPProcessedFood? = nil) {
            self.result = result
            self.processedFood = processedFood
            
            if processedFood == nil {
                isLoadingFoodDetails = true
                Task {
                    let food = try await MFPScraper().getFood(with: result.url)
                    await MainActor.run {
                        withAnimation {
                            self.processedFood = food
                            self.isLoadingFoodDetails = false
                        }
                    }
                }
            }
        }
    }
}

struct MFPFoodViewPreview: View {
    var body: some View {
        NavigationStack {
            MFPFoodView(result: MockResult.Banana)
        }
    }
}

struct MFPFoodView_Previews: PreviewProvider {
    static var previews: some View {
        MFPFoodViewPreview()
    }
}
