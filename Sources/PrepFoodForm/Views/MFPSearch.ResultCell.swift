import SwiftUI
import MFPScraper
import ActivityIndicatorView

//MARK: - ViewModel
extension MFPSearch.ResultCell {
    
    class ViewModel: ObservableObject {
        
        @Published var result: MFPSearchResultFood
        @Published var processedFood: MFPProcessedFood? = nil
        
        init(result: MFPSearchResultFood) {
            self.result = result
            
//            let nutrients: [MFPProcessedFood.Nutrient] = [
//                MFPProcessedFood.Nutrient(type: .saturatedFat, amount: 20, unit: .g),
//                MFPProcessedFood.Nutrient(type: .cholesterol, amount: 140, unit: .mg),
//                MFPProcessedFood.Nutrient(type: .addedSugars, amount: 7, unit: .g),
//                MFPProcessedFood.Nutrient(type: .biotin, amount: 64, unit: .mg),
//                MFPProcessedFood.Nutrient(type: .calcium, amount: 54, unit: .mcg),
//                MFPProcessedFood.Nutrient(type: .cobalamin, amount: 2, unit: .mg),
//                MFPProcessedFood.Nutrient(type: .folate, amount: 120, unit: .g),
////                MFPProcessedFood.Nutrient
//            ]
//            let sizes: [MFPProcessedFood.Size] = [
//                MFPProcessedFood.Size(quantity: 1, name: "large", amount: 150, amountUnit: .weight, amountVolumeUnit: nil, amountWeightUnit: .g, amountSizeUnit: nil),
//                MFPProcessedFood.Size(quantity: 1, name: "medium", amount: 120, amountUnit: .weight, amountVolumeUnit: nil, amountWeightUnit: .g, amountSizeUnit: nil),
//                MFPProcessedFood.Size(quantity: 1, name: "small", amount: 90, amountUnit: .weight, amountVolumeUnit: nil, amountWeightUnit: .g, amountSizeUnit: nil),
//            ]
//            let mockFood = MFPProcessedFood(
//                name: "Double Quarter Pounder Hamburger",
//                brand: "McDonalds",
//                detail: "Large",
//                amount: 100,
//                amountUnit: .weight,
//                amountWeightUnit: .g,
//                servingValue: 0,
//                servingUnit: .weight,
//                energy: 0,
//                carbohydrate: 0,
//                fat: 0,
//                protein: 0,
//                nutrients: nutrients,
//                sizes: sizes)
//            self.processedFood = mockFood
            
//            Task {
//                let food = try await MFPScraper().getFood(with: result.url)
//                await MainActor.run {
//                    withAnimation {
//                        self.processedFood = food
//                    }
//                }
//            }
        }
    }
}

extension MFPSearch.ResultCell.ViewModel {
    var name: String {
        result.name
    }
    
    var energy: String {
        "\(result.calories.cleanAmount) kcal"
    }
    
    var numberOfSizes: Int? {
        processedFood?.sizes.count
    }
    
    var numberOfMicros: Int? {
        processedFood?.nutrients.count
    }
    
    var sizes: [MFPProcessedFood.Size]? {
        processedFood?.sizes
    }
    
    var nutrients: [MFPProcessedFood.Nutrient]? {
        processedFood?.nutrients
    }
    
    var sizesString: String? {
        guard let sizes = processedFood?.sizes, !sizes.isEmpty else {
            return nil
        }
        let string = sizes.map { $0.name }.joined(separator: ", ")
        return string.isEmpty ? nil : string
    }
    
    var nutrientsString: String? {
        guard let nutrients = processedFood?.nutrients, !nutrients.isEmpty else {
            return nil
        }
        let string = nutrients.map { $0.type.description.lowercased() }.joined(separator: ", ")
        return string.isEmpty ? nil : string
    }
    
    var detailString: String? {
        if let brand = processedFood?.brand {
            if let detail = processedFood?.detail {
                return "\(brand) • \(detail)"
            } else {
                return brand
            }
        } else if let detail = processedFood?.detail {
            return detail
        } else if !result.detail.isEmpty {
            return result.detail
        }
        return nil
    }
    
    var hasProcessedFood: Bool {
        processedFood != nil
    }
}

//MARK: - Cell
extension MFPSearch {
    struct ResultCell: View {
        @StateObject var viewModel: ViewModel
        
        init(result: MFPSearchResultFood) {
            _viewModel = StateObject(wrappedValue: ViewModel(result: result))
        }
    }
}

extension MFPSearch.ResultCell {
    var body: some View {
        HStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    if let detail = viewModel.detailString {
                        Text(detail)
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            Spacer()
            Text(viewModel.energy)
                .foregroundColor(.secondary)
        }
    }
    
    var content: some View {
        VStack(spacing: 5) {
            title
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    subtitle
//                    details
                }
                Spacer()
                NutritionSummary(dataProvider: viewModel)
            }
        }
    }
    
    var title: some View {
        Text(viewModel.name)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    var subtitle: some View {
        if let detailString = viewModel.detailString {
            Text(detailString)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    var details: some View {
        if viewModel.hasProcessedFood {
//            sizesAndNutrients_legacy
            HStack(spacing: 15) {
                sizesButton
                nutrientsButton
            }
        } else {
            ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                .frame(width: 20, height: 20)
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    @ViewBuilder
    var sizesButton: some View {
        if let sizes = viewModel.sizes {
            Button {
                
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "rectangle.3.group")
                        .imageScale(.small)
                    Text("3")
                        .font(.footnote)
                }
                .foregroundColor(.secondary)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
            }
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    var nutrientsButton: some View {
        if let nutrients = viewModel.nutrients {
            Button {
                
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .imageScale(.small)
                    Text("7")
                        .font(.footnote)
                }
                .foregroundColor(.secondary)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
            }
            .buttonStyle(.borderless)
        }
    }
    
    var sizesAndNutrients_legacy: some View {
        @ViewBuilder
        var sizes: some View {
            if let sizesString = viewModel.sizesString {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sizes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .foregroundColor(Color(.secondarySystemFill))
                        )

                    Text(sizesString)
                        .font(.caption2)
                        .foregroundColor(Color(.tertiaryLabel))
                        .padding(.leading, 4)
                }
            }
        }
        
        
        @ViewBuilder
        var nutrients: some View {
            if let nutrientsString = viewModel.nutrientsString {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nutrients")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .foregroundColor(Color(.secondarySystemFill))
                        )
                    Text(nutrientsString)
                        .font(.caption2)
                        .foregroundColor(Color(.tertiaryLabel))
                        .padding(.leading, 4)
                }
            }
        }
        
        return VStack(alignment: .leading) {
            sizes
            nutrients
        }
    }

    @ViewBuilder
    var summary: some View {
        if let numberOfSizes = viewModel.numberOfSizes, let numberOfMicros = viewModel.numberOfMicros {
            HStack {
                HStack(spacing: 3) {
                    Text("\(numberOfSizes)")
                        .foregroundColor(.secondary)
                    Text("sizes")
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
                HStack(spacing: 3) {
                    Text("\(numberOfMicros)")
                        .foregroundColor(.secondary)
                    Text("micronutrients")
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .font(.footnote)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
            }
        }
    }
}

extension MFPSearch.ResultCell.ViewModel: NutritionSummaryProvider {
    var forMeal: Bool {
        false
    }
    
    var isMarkedAsCompleted: Bool {
        false
    }
    
    var showQuantityAsSummaryDetail: Bool {
        false
    }
    
    var energyAmount: Double {
        result.calories
    }
    
    var carbAmount: Double {
        result.carbs
    }
    
    var fatAmount: Double {
        result.fat
    }
    
    var proteinAmount: Double {
        result.protein
    }
}

public struct MFPSearchResultCellPreview: View {
    
    public var body: some View {
        NavigationStack {
            List {
                MFPSearch.ResultCell(result: MockResult.Banana)
                MFPSearch.ResultCell(result: MockResult.Banana)
                MFPSearch.ResultCell(result: MockResult.Banana)
                MFPSearch.ResultCell(result: MockResult.Banana)
                MFPSearch.ResultCell(result: MockResult.Banana)
            }
//            .listStyle(.plain)
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    public init() { }
}

struct MFPSearchResultCell_Previews: PreviewProvider {
    static var previews: some View {
        MFPSearchResultCellPreview()
    }
}

struct MockResult {
    static let Banana = MFPSearchResultFood(
        name: "Double Quarter Pounder",
        detail: "1 medium",
        servingSize: "",
        isVerified: false,
        calories: 89,
        carbs: 23,
        fat: 0,
        protein: 1,
        url: "/food/calories/banana-1774572771"
    )
}
