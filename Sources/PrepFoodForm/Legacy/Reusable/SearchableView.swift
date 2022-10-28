//import SwiftUI
//
//public struct SearchableView<Content: View>: View {
//    
//    var content: () -> Content
//    
//    @Environment(\.colorScheme) var colorScheme
//    @State private var searchText = ""
//    @FocusState var isFocused: Bool
//    @State var showingSearchLayer: Bool = false
//
//    let blurWhileSearching: Bool
//    let focusOnAppear: Bool
//    
//    public init(
//        blurWhileSearching: Bool = false,
//        focusOnAppear: Bool = false,
//        @ViewBuilder content: @escaping () -> Content)
//    {
//        self.blurWhileSearching = blurWhileSearching
//        self.focusOnAppear = focusOnAppear
//        self.content = content
//    }
//    
//    public var body: some View {
//        NavigationView {
//            ZStack {
//                content()
//                    .blur(radius: blurRadius)
//                searchLayer
//            }
//        }
//        .onAppear {
//            if focusOnAppear {
//                focusOnSearchTextField()
//            }
//        }
//    }
//    
//    var blurRadius: CGFloat {
//        guard blurWhileSearching else { return 0 }
//        return showingSearchLayer ? 10 : 0
//    }
//    
//    func focusOnSearchTextField() {
//        withAnimation {
//            showingSearchLayer = true
//        }
//        isFocused = true
//    }
//
//    var searchLayer: some View {
//        var keyboardColor: Color {
//            colorScheme == .light ? Color(hex: colorHexKeyboardLight) : Color(hex: colorHexKeyboardDark)
//        }
//
//        var textFieldColor: Color {
//            colorScheme == .light ? Color(hex: colorHexSearchTextFieldLight) : Color(hex: colorHexSearchTextFieldDark)
//        }
//
//        
//        var searchBar: some View {
//            var background: some View {
//                keyboardColor
//                    .frame(height: 65)
//            }
//            
//            var textField: some View {
//                TextField("Search or enter website link", text: $searchText)
//                    .focused($isFocused)
//                    .font(.system(size: 18))
//                    .keyboardType(.alphabet)
//                    .autocorrectionDisabled()
//                    .onSubmit {
////                        guard !searchViewModel.searchText.isEmpty else {
////                            dismiss()
////                            return
////                        }
//                        resignFocusOfSearchTextField()
////                        startSearching()
//                    }
//            }
//            
//            var textFieldBackground: some View {
//                RoundedRectangle(cornerRadius: 15, style: .circular)
//                    .foregroundColor(textFieldColor)
//                    .frame(height: 48)
//            }
//            
//            var searchIcon: some View {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(Color(.secondaryLabel))
//                    .font(.system(size: 18))
//                    .fontWeight(.semibold)
//            }
//            
//            var clearButton: some View {
//                Button {
//                    searchText = ""
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(Color(.secondaryLabel))
//                }
//                .opacity(searchText.isEmpty ? 0 : 1)
//            }
//            
//            return ZStack {
//                background
//                ZStack {
//                    textFieldBackground
//                    HStack(spacing: 5) {
//                        searchIcon
//                        textField
//                        Spacer()
//                        clearButton
//                    }
//                    .padding(.horizontal, 12)
//                }
//                .padding(.horizontal, 7)
//            }
//        }
//        
//        return ZStack {
//            VStack {
//                Spacer()
//                searchBar
//                    .background(
//                        keyboardColor
//                            .edgesIgnoringSafeArea(.bottom)
//                    )
//            }
//        }
//    }
//    
//    func resignFocusOfSearchTextField() {
//        withAnimation {
//            showingSearchLayer = false
//        }
//        isFocused = false
//    }
//}
