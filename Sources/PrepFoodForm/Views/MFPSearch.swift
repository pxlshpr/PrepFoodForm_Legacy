import SwiftUI
import ActivityIndicatorView

let colorHexKeyboardLight = "CDD0D6"
let colorHexKeyboardDark = "303030"
let colorHexSearchTextFieldDark = "535355"
let colorHexSearchTextFieldLight = "FFFFFF"

struct MFPSearch: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isSearching) var isSearching
    @State var searchText = ""
    @FocusState var isFocused: Bool
    @State var showingSearchLayer: Bool = false
    @State var showingSearchActivityIndicator = false

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
        .interactiveDismissDisabled(isFocused)
    }
    
    func focusOnSearchTextField() {
        showingSearchLayer = true
        isFocused = true
    }
    
    func startSearching() {
        withAnimation {
            showingSearchActivityIndicator = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            withAnimation {
                showingSearchActivityIndicator = false
            }
        }
    }
    
    var navigationStack: some View {
        var title: String {
            if showingSearchActivityIndicator {
                return "Searching …"
            } else {
                return "Search MyFitnessPal"
            }
        }
        return NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { navigationTrailingContent }
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
    
    var searchActivityIndicator: some View {
        ActivityIndicatorView(isVisible: .constant(true), type: .growingCircle)
            .foregroundColor(Color(.secondaryLabel))
            .frame(width: 200, height: 200)
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                withAnimation {
                    showingSearchLayer = true
                }
                isFocused = true
            } label: {
                Image(systemName: "magnifyingglass")
            }
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
                TextField("Search or enter website link", text: $searchText)
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
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.secondaryLabel))
                }
                .opacity(searchText.isEmpty ? 0 : 1)
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
            blurLayer
            VStack {
                Spacer()
                searchBar
            }
        }
    }
    
    var list: some View {
        List {
        }
    }
}

struct MFPSearchPreview: View {
    var body: some View {
        MFPSearch()
    }
}

struct MFPSearch_Previews: PreviewProvider {
    static var previews: some View {
        MFPSearchPreview()
    }
}

