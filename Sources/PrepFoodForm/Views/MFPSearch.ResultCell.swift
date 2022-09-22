import SwiftUI
import MFPScraper

//MARK: - ViewModel
extension MFPSearch.ResultCell {
    
    class ViewModel: ObservableObject {
        
        @Published var result: MFPSearchResultFood
        @Published var processedFood: MFPProcessedFood? = nil
        
        init(result: MFPSearchResultFood) {
            self.result = result
            
            let nutrients: [MFPProcessedFood.Nutrient] = [
                MFPProcessedFood.Nutrient
            ]
            let sizes: [MFPProcessedFood.Size] = [
            ]
            let mockFood = MFPProcessedFood(
                name: "Banana",
                brand: "Woolworths",
                detail: "Cavendish",
                amount: 100,
                amountUnit: .weight,
                amountWeightUnit: .g,
                servingValue: 0,
                servingUnit: .weight,
                energy: 0,
                carbohydrate: 0,
                fat: 0,
                protein: 0,
                nutrients: nutrients,
                sizes: sizes)
            self.processedFood = mockFood
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
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.name)
                    .bold()
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
            Spacer()
            NutritionSummary(dataProvider: viewModel)
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

struct MFPSearchResultCellPreview: View {
    
    var body: some View {
        List {
            MFPSearch.ResultCell(result: MockResult.Banana)
            MFPSearch.ResultCell(result: MockResult.Banana)
            MFPSearch.ResultCell(result: MockResult.Banana)
        }
    }
}

struct MFPSearchResultCell_Previews: PreviewProvider {
    static var previews: some View {
        MFPSearchResultCellPreview()
    }
}

struct MockResult {
    static let Banana = MFPSearchResultFood(
        name: "Banana",
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
