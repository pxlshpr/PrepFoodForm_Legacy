import SwiftUI
import MFPScraper
import FoodLabel
import PrepUnits
import WebKit
import ActivityIndicatorView

//MARK: - MFPSizeViewModel

struct MFPSizeViewModel: Hashable {
    let size: MFPProcessedFood.Size

    var nameString: String {
        size.name.lowercased()
    }
    
    var fullNameString: String {
        if let prefixVolumeUnit = size.prefixVolumeUnit {
            return "\(prefixVolumeUnit.shortDescription), \(nameString)"
        } else {
            return nameString
        }
    }

    var scaledAmountString: String {
        "\(scaledAmount.cleanAmount) \(amountUnitDescription.lowercased())"
    }
    
    var amountUnitDescription: String {
        switch size.amountUnit {
        case .weight(let weightUnit):
            return weightUnit.description
        case .volume(let volumeUnit):
            return volumeUnit.description
        case .size(let size):
            return size.nameDescription
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

//MARK: - SizeCell
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

//MARK: - FoodView
struct MFPFoodView: View {
    @EnvironmentObject var searchViewModel: MFPSearch.ViewModel
    @StateObject var viewModel: ViewModel
    @State var showingWebsite: Bool = false
    
    init(result: MFPSearchResultFood, processedFood: MFPProcessedFood? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel(result: result, processedFood: processedFood))
    }
    
    var body: some View {
        ZStack {
            scrollView
            buttonLayer
        }
        .navigationTitle("Third-Party Food")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    var websiteView: some View {
        if let url = viewModel.url {
//            SFSafariViewWrapper(url: url)
//                .edgesIgnoringSafeArea(.all)
            SourceWebView(urlString: url.absoluteString)
        }
    }
    
    var buttonLayer: some View {
        VStack(spacing: 0) {
            Spacer()
            Divider()
            FormPrimaryButton(title: "Copy this food") {
                
            }
            .padding(.top)
            .background(
                .thinMaterial
            )
        }
    }
    
    var scrollView: some View {
        ScrollView {
            Section {
                VStack(alignment: .center) {
                    Text(viewModel.name)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                    if let detailString = viewModel.detailString {
                        Text(detailString)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top)
            }
            loadingIndicator
            foodLabelSection
            sizesSection
            linkSection
        }
        .safeAreaInset(edge: .bottom) {
            //TODO: Programmatically get this inset (67516AA6)
            Spacer().frame(height: 68)
        }
        .sheet(isPresented: $showingWebsite) {
            websiteView
        }
    }
    
    @ViewBuilder
    var linkSection: some View {
        if let url = viewModel.url {
            linkButton(for: url)
        }
    }
    
    func linkButton(for url: URL) -> some View {
        Button {
            searchViewModel.path.append(.website(url))
//            showingWebsite = true
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
        if viewModel.isLoadingFoodDetails {
            Section {
                ProgressView()
            }
        }
    }
    
    var sizesSection: some View {
        var header: some View {
            Text("Sizes")
                .font(.title2)
        }
        
        return Group {
            if let sizeViewModels = viewModel.sizeViewModels {
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
        if viewModel.shouldShowFoodLabel {
            Section {
                FoodLabel(dataSource: viewModel)
            }
            .padding()
            .transition(.opacity)
        }
    }
}

extension ServingUnit {
    var isNotSize: Bool {
        switch self {
        case .size:
            return false
        default:
            return true
        }
    }
}
//MARK: - ViewModel: FoodLabelDataSource

extension MFPFoodView.ViewModel: FoodLabelDataSource {
    var amountString: String {
        guard let processedFood else {
            return "1 serving"
        }
        let amountDescription = processedFood.amountDescription.lowercased()
        
        if processedFood.amountUnit == .serving, let servingDescription = processedFood.servingDescription {
            if case .size = processedFood.servingUnit {
                return servingDescription.lowercased()
            } else {
                return "\(amountDescription) (\(servingDescription.lowercased()))"
            }
//            let servingUnit = processedFood.servingUnit,
//            servingUnit.isNotSize,
        } else {
            return amountDescription
        }
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
        true
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

//MARK: - ViewModel
extension MFPFoodView.ViewModel {
    
    var servingString: String {
        guard let processedFood else {
            return "1 serving"
        }
        let amountDescription = processedFood.amountDescription.lowercased()
        
        if processedFood.amountUnit == .serving, let servingDescription = processedFood.servingDescription {
            return "\(amountDescription) (\(servingDescription.lowercased()))"
        } else {
            return amountDescription
        }
    }
    
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
    
    var url: URL? {
        URL(string: "https://myfitnesspal.com\(result.url)")
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
    
    var detailString: String? {
        processedFood?.detail ?? processedFood?.brand
    }
    
    var shouldShowDetailString: Bool {
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
                Task(priority: .high) {
                    let food = try await MFPScraper().getFood(for: FoodIdentifier(result.url))
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

//MARK: - Preview
struct MFPFoodViewPreview: View {
    var body: some View {
        NavigationView {
            MFPFoodView(result: MockResult.Banana, processedFood: MockProcessedFood.Banana)
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
        name: "Double Quarter Pounder",
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

//MARK: - SFSafariViewWrapper
import SwiftUI
import SafariServices

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}

import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
 
    var url: URL
    var delegate: WKNavigationDelegate?
        var scrollViewDelegate: UIScrollViewDelegate?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = delegate
        webView.scrollView.delegate = scrollViewDelegate
        return webView
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct SourceWebView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var urlString: String
    @State var hasAppeared: Bool = false

    @StateObject var vm = ViewModel()
    
    @ViewBuilder
    var body: some View {
//        NavigationView {
//            if hasAppeared {
                WebView(url: URL(string: urlString)!, delegate: vm)
                    .navigationBarTitle("Website")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { navigationTrailingContent }
                    .toolbar { navigationLeadingContent }
                    .transition(.opacity)
                    .edgesIgnoringSafeArea(.bottom)
//            }
//        }
//        .onAppear {
//            appeared()
//        }
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                hasAppeared = true
            }
        }
    }

    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if vm.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
//                ProgressView()
//                    .transition(.opacity)
            }
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            
            Link(destination: URL(string: urlString)!) {
                Image(systemName: "safari")
            }
            ShareLink(item: URL(string: urlString)!) {
                Image(systemName: "square.and.arrow.up")
//                Label("Learn Swift here", systemImage: "swift")
            }
//            Menu {
//                Button("Copy URL") {
//                    UIPasteboard.general.string = urlString
//                }
//            } label: {
//                Image(systemName: "square.and.arrow.up")
//            }
        }
    }
    
    class ViewModel: NSObject, ObservableObject, WKNavigationDelegate {
        
        @Published var isLoading = true
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }
    }
}
