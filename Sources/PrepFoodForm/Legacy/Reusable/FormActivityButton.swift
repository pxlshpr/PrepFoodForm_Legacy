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
                Spacer()
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
                    .frame(width: 20.0, height: 20.0)
            }
        }
    }
}
