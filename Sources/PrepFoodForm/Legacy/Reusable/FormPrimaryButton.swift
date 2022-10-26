import SwiftUI

struct FormPrimaryButton: View {
    
    var title: String
    var color: Color = .accentColor
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .bold()
                .foregroundColor(.white)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(color)
                )
                .padding(.horizontal)
                .padding(.horizontal)
        }
        .buttonStyle(.borderless)
    }
}
