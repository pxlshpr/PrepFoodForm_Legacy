import SwiftUI
import ActivityIndicatorView
import SwiftHaptics
import MFPScraper

let colorHexKeyboardLight = "CDD0D6"
let colorHexKeyboardDark = "303030"
let colorHexSearchTextFieldDark = "535355"
let colorHexSearchTextFieldLight = "FFFFFF"

struct MFPSearch: View {
    
    enum Route: Hashable {
        case mfpFood(MFPSearchResultFood, MFPProcessedFood?)
    }
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel = ViewModel()
    
    @FocusState var isFocused: Bool
    @State var showingSearchLayer: Bool = false
    @State var showingSearchActivityIndicator = false
    
    @State var path: [Route] = []

    var body: some View {
        ZStack {
            navigationStack
                .blur(radius: showingSearchLayer ? 10 : 0)
            if showingSearchLayer {
                ZStack {
                    searchLayer
                }
            }
        }
        .onAppear {
            focusOnSearchTextField()
        }
        .onDisappear {
            viewModel.cancelSearching()
        }
        .interactiveDismissDisabled(shouldDisableInteractiveDismissal)
        .onAppear {
            stopTimer()
        }
        .onChange(of: viewModel.results) { newValue in
            guard !newValue.isEmpty else {
                return
            }
            stopTimer()
            Haptics.feedback(style: .medium)
            withAnimation {
                progressValue = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    self.showingSearchActivityIndicator = false
                }
            }
        }
    }
    
    var shouldDisableInteractiveDismissal: Bool {
//        isFocused || !viewModel.results.isEmpty
        !viewModel.results.isEmpty
    }
    
    func focusOnSearchTextField() {
        showingSearchLayer = true
        isFocused = true
    }
    
    func startSearching() {
        withAnimation {
            showingSearchActivityIndicator = true
        }
        viewModel.startSearching()
    }
    
    var navigationStack: some View {
        var title: String {
            if showingSearchActivityIndicator {
//                return "Searching …"
                return "Search Third-Party Foods"
            } else {
                return "Search Third-Party Foods"
            }
        }
        return NavigationStack(path: $path) {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { navigationTrailingContent }
                .toolbar { navigationLeadingContent }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .mfpFood(let result, let processedFood):
                        MFPFoodView(result: result, processedFood: processedFood)
                    }
                }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if showingSearchActivityIndicator {
            searchActivityIndicator
        } else {
            list
        }
    }
    
    @State var timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    @State var progressValue: Double = 0
    
    var searchActivityIndicator: some View {
        VStack {
//            Text("Loading")
//                .foregroundColor(.secondary)
            ProgressView(value: progressValue, total: 10) {
                HStack {
                    Spacer()
                    Text("Searching '\(viewModel.searchText)'…")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .frame(width: 250)
            .onReceive(timer) { _ in
                let newValue = progressValue + 0.02
                guard newValue < 10 else {
                    stopTimer()
                    return
                }
                withAnimation {
                    progressValue = newValue
                }
            }
        }
//        ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
//            .foregroundColor(Color(.secondaryLabel))
//            .frame(width: 200, height: 200)
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            searchButton
        }
    }
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if shouldDisableInteractiveDismissal {
                doneButton
            }
        }
    }
    
    var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
        }
    }
    
    var searchButton: some View {
        Button {
            withAnimation {
                showingSearchLayer = true
            }
            isFocused = true
        } label: {
            Image(systemName: "magnifyingglass")
        }
    }
    
    var searchLayer: some View {
        var keyboardColor: Color {
            colorScheme == .light ? Color(hex: colorHexKeyboardLight) : Color(hex: colorHexKeyboardDark)
        }

        var textFieldColor: Color {
            colorScheme == .light ? Color(hex: colorHexSearchTextFieldLight) : Color(hex: colorHexSearchTextFieldDark)
        }

        var blurLayer: some View {
            Color.black.opacity(0.5)
                .onTapGesture {
                    
                    withAnimation {
                        showingSearchLayer = false
                    }
                    isFocused = false
                }
                .edgesIgnoringSafeArea(.all)
        }
        
        var searchBar: some View {
            var background: some View {
                keyboardColor
                    .frame(height: 60)
            }
            
            var textField: some View {
                TextField("Search or enter website link", text: $viewModel.searchText)
                    .focused($isFocused)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .onSubmit {
                        withAnimation {
                            showingSearchLayer = false
                            isFocused = false
                        }
                        startSearching()
                    }
            }
            
            var textFieldBackground: some View {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(textFieldColor)
                    .frame(height: 44)
            }
            
            var searchIcon: some View {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.quaternaryLabel))
                    .imageScale(.medium)
            }
            
            var clearButton: some View {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.secondaryLabel))
                }
                .opacity(viewModel.searchText.isEmpty ? 0 : 1)
            }
            
            return ZStack {
                background
                ZStack {
                    textFieldBackground
                    HStack(spacing: 5) {
                        searchIcon
                        textField
                        Spacer()
                        clearButton
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal, 7)
            }
        }
        
        return ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    Haptics.feedback(style: .soft)
                    withAnimation {
                        showingSearchLayer = false
                    }
                    isFocused = false
                }
                .background (
                    .ultraThinMaterial
                )
            VStack {
                Spacer()
                searchBar
            }
        }
    }
    
    var list: some View {
        List {
            ForEach(viewModel.results, id: \.self) { result in
                NavigationLinkButton {
                    path.append(.mfpFood(result, viewModel.food(for: result)))
                } label: {
                    ResultCell(result: result)
                        .onAppear {
                            viewModel.loadMoreContentIfNeeded(currentResult: result)
                        }
                        .contentShape(Rectangle())
                }
            }
            if viewModel.isLoadingPage {
                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

public struct MFPSearchPreview: View {
    
    public var body: some View {
        MFPSearch()
    }
    
    public init() { }
}

struct MFPSearch_Previews: PreviewProvider {
    static var previews: some View {
        MFPSearchPreview()
    }
}

