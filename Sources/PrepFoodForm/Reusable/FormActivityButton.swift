import SwiftUI
import ActivityIndicatorView

struct FormActivityButton: View {
    
    var title: String
    var action: () -> ()

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
//                    .foregroundColor(.primary)
                Spacer()
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .equalizer(count: 5))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .gradient([.white, .accentColor], lineWidth: 3))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .arcs(count: 3, lineWidth: 2))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .flickeringDots(count: 8))
                    .frame(width: 20.0, height: 20.0)
            }
        }
    }
}
