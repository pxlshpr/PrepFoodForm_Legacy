//import SwiftUI
//import WebKit
//import ActivityIndicatorView
//
//struct WebView: UIViewRepresentable {
// 
//    var url: URL
//    var delegate: WKNavigationDelegate?
//        var scrollViewDelegate: UIScrollViewDelegate?
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = delegate
//        webView.scrollView.delegate = scrollViewDelegate
//        return webView
//    }
// 
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        let request = URLRequest(url: url)
//        webView.load(request)
//    }
//}
//
//struct SourceWebView: View {
//    
//    @Environment(\.dismiss) var dismiss
//    @State var urlString: String
//    @State var hasAppeared: Bool = false
//
//    @StateObject var vm = ViewModel()
//    
//    @ViewBuilder
//    var body: some View {
//        WebView(url: URL(string: urlString)!, delegate: vm)
//            .transition(.opacity)
//            .overlay(loadingOverlay)
//            .navigationBarTitle("Website")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { navigationTrailingContent }
//            .toolbar { navigationLeadingContent }
//            .edgesIgnoringSafeArea(.bottom)
//    }
//    
//    @ViewBuilder
//    var loadingOverlay: some View {
//        if !vm.hasStartedNavigating {
//            ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
//                    .foregroundColor(Color(.tertiaryLabel))
//                    .frame(width: 70, height: 70)
//                    .transition(.opacity)
//        }
//    }
//    func appeared() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            withAnimation {
//                hasAppeared = true
//            }
//        }
//    }
//
//    var navigationLeadingContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarLeading) {
//            if vm.isNavigating {
//                ActivityIndicatorView(isVisible: .constant(true), type: .opacityDots())
//                    .foregroundColor(.secondary)
//                    .frame(width: 20, height: 20)
////                ProgressView()
////                    .transition(.opacity)
//            }
//        }
//    }
//    
//    var navigationTrailingContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            
//            Link(destination: URL(string: urlString)!) {
//                Image(systemName: "safari")
//            }
//            ShareLink(item: URL(string: urlString)!) {
//                Image(systemName: "square.and.arrow.up")
////                Label("Learn Swift here", systemImage: "swift")
//            }
////            Menu {
////                Button("Copy URL") {
////                    UIPasteboard.general.string = urlString
////                }
////            } label: {
////                Image(systemName: "square.and.arrow.up")
////            }
//        }
//    }
//    
//    class ViewModel: NSObject, ObservableObject, WKNavigationDelegate {
//        
//        @Published var isNavigating = false
//        @Published var hasStartedNavigating = false
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            withAnimation {
//                isNavigating = false
//            }
//        }
//        
//        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//            withAnimation {
//                hasStartedNavigating = true
//                isNavigating = true
//            }
//        }
//    }
//}
