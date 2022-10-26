import SwiftUI

struct NavigationLinkButton<Content: View>: View {
    
    var action: () -> ()
    @ViewBuilder var label: Content
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                label
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
                    .imageScale(.small)
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(.borderless)
    }
}
