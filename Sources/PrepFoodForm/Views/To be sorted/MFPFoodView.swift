import SwiftUI
import MFPScraper
import FoodLabel
import PrepUnits
import WebKit
import ActivityIndicatorView

struct MFPFoodView: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var searchViewModel: MFPSearch.ViewModel
    @StateObject var mfpFoodViewModel: ViewModel
    @State var showingWebsite: Bool = false
    
    init(result: MFPSearchResultFood, processedFood: MFPProcessedFood? = nil) {
        _mfpFoodViewModel = StateObject(wrappedValue: ViewModel(result: result, processedFood: processedFood))
    }
    
    var body: some View {
        ZStack {
            scrollView
            if !mfpFoodViewModel.isLoadingFoodDetails {
                buttonLayer
                    .transition(.move(edge: .bottom))
            }
        }
        .navigationTitle("Third-Party Food")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    var websiteView: some View {
        if let url = mfpFoodViewModel.url {
//            SFSafariViewWrapper(url: url)
//                .edgesIgnoringSafeArea(.all)
            SourceWebView(urlString: url.absoluteString)
        }
    }
    
    var buttonLayer: some View {
        VStack(spacing: 0) {
            Spacer()
            Divider()
            FormPrimaryButton(title: "Prefill this food") {
                if let processedFood = mfpFoodViewModel.processedFood {
                    viewModel.prefill(processedFood)
                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    viewModel.showingThirdPartySearch = false
//                }
            }
            .padding(.top)
            .background(
                .thinMaterial
            )
        }
    }
    
    var scrollView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Section {
                        VStack(alignment: .center) {
                            Text(mfpFoodViewModel.name)
                                .multilineTextAlignment(.center)
                                .font(.title)
                                .bold()
//                                .minimumScaleFactor(0.3)
//                                .lineLimit(1)
                            if let detailString = mfpFoodViewModel.detailString {
                                Text(detailString)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(.quaternarySystemFill))
                        )
                        .padding(.top)
                        .padding(.horizontal)
                    }
                    if mfpFoodViewModel.isLoadingFoodDetails {
                        loadingIndicator
                            .frame(maxHeight: .infinity)
                    } else {
                        foodLabelSection
                        sizesSection
                        linkSection
                        Spacer()
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            .safeAreaInset(edge: .bottom) {
                //TODO: Programmatically get this inset (67516AA6)
                Spacer().frame(height: 68)
            }
            .sheet(isPresented: $showingWebsite) {
                websiteView
            }
        }
    }
    
    @ViewBuilder
    var linkSection: some View {
        if let url = mfpFoodViewModel.url {
            linkButton(for: url)
        }
    }
    
    func linkButton(for url: URL) -> some View {
        NavigationLink {
            SourceWebView(urlString: url.absoluteString)
        } label: {
            HStack {
                HStack {
                    Image(systemName: "link")
                    Text("Website")
                }
                .foregroundColor(.secondary)
                Spacer()
                Text("MyFitnessPal")
                    .foregroundColor(.accentColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(Color(.secondarySystemBackground))
            )
            .padding()
            .padding()
        }
    }
    
    @ViewBuilder
    var loadingIndicator: some View {
        VStack {
            Spacer()
            ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                .foregroundColor(Color(.tertiaryLabel))
                .frame(width: 70, height: 70)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    var sizesSection: some View {
        var header: some View {
            Text("Sizes")
                .font(.title2)
        }
        
        return Group {
            if let sizeViewModels = mfpFoodViewModel.sizeViewModels {
                Section(header: header) {
                    Divider()
                    VStack {
                        ForEach(sizeViewModels, id: \.self) {
                            SizeCell(sizeViewModel: $0)
                                .padding(.vertical, 5)
                            Divider()
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .transition(.opacity)
            }
        }
    }
    
    @ViewBuilder
    var foodLabelSection: some View {
        if mfpFoodViewModel.shouldShowFoodLabel {
            Section {
                FoodLabel(dataSource: mfpFoodViewModel)
            }
            .padding()
            .transition(.opacity)
        }
    }
}

//MARK: - Preview
struct MFPFoodViewPreview: View {
    var body: some View {
        NavigationView {
//            MFPFoodView(result: MockResult.Banana, processedFood: MockProcessedFood.Banana)
            MFPFoodView(result: MockResult.Banana, processedFood: nil)
                .environmentObject(FoodFormViewModel.shared)
        }
    }
}

struct MFPFoodView_Previews: PreviewProvider {
    static var previews: some View {
        MFPFoodViewPreview()
    }
}

//MARK: - Mock Data
struct MockProcessedFood {
    static let Banana = MFPProcessedFood(
        name: "Banana",
        brand: "Woolworths",
        detail: "Cavendish",
        amount: 1,
        amountUnit: .size(MFPProcessedFood.Size(
                quantity: 1,
                name: "Medium",
                prefixVolumeUnit: nil,
                amount: 118,
                amountUnit: .weight(.g)
        )),
        servingAmount: 1,
        servingUnit: .weight(.g),
        energy: 105,
        carbohydrate: 26,
        fat: 0.4,
        protein: 1,
        nutrients: [
            MFPProcessedFood.Nutrient(type: .saturatedFat, amount: 0.1, unit: .g),
            MFPProcessedFood.Nutrient(type: .polyunsaturatedFat, amount: 0.05, unit: .g),
            MFPProcessedFood.Nutrient(type: .monounsaturatedFat, amount: 0.05, unit: .g),
            MFPProcessedFood.Nutrient(type: .sodium, amount: 1, unit: .mg),
            MFPProcessedFood.Nutrient(type: .dietaryFiber, amount: 3, unit: .g),
            MFPProcessedFood.Nutrient(type: .sugars, amount: 14, unit: .g),
            MFPProcessedFood.Nutrient(type: .vitaminA, amount: 45, unit: .mcgRAE),
            MFPProcessedFood.Nutrient(type: .vitaminC, amount: 15, unit: .mg),
            MFPProcessedFood.Nutrient(type: .calcium, amount: 7, unit: .mg),
            MFPProcessedFood.Nutrient(type: .iron, amount: 0.3, unit: .mg),
            MFPProcessedFood.Nutrient(type: .potassium, amount: 422, unit: .mg),
        ],
        sizes: [
            MFPProcessedFood.Size(
                quantity: 1,
                name: "Medium",
                prefixVolumeUnit: nil,
                amount: 118,
                amountUnit: .weight(.g)
            ),
            MFPProcessedFood.Size(
                quantity: 1,
                name: "Large",
                prefixVolumeUnit: nil,
                amount: 136,
                amountUnit: .weight(.g)
            ),
            MFPProcessedFood.Size(
                quantity: 1,
                name: "Sliced",
                prefixVolumeUnit: .cup,
                amount: 150,
                amountUnit: .weight(.g)
            ),
            MFPProcessedFood.Size(
                quantity: 1,
                name: "Mashed",
                prefixVolumeUnit: .cup,
                amount: 225,
                amountUnit: .weight(.g)
            ),
            MFPProcessedFood.Size(
                quantity: 1,
                name: "Extra small",
                prefixVolumeUnit: nil,
                amount: 81,
                amountUnit: .weight(.g)
            ),
            MFPProcessedFood.Size(
                quantity: 1,
                name: "Extra large",
                prefixVolumeUnit: nil,
                amount: 152,
                amountUnit: .weight(.g)
            ),

        ],
        sourceUrl: "https://myfitnesspal.com/food/calories/banana-1774572771")
}
