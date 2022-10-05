import SwiftUI

struct FillOptionButton: View {
    
    let selectionColorDark = Color(hex: "6c6c6c")
    let selectionColorLight = Color(hex: "959596")
    @Environment(\.colorScheme) var colorScheme
    
    let fillOption: FillOption
    let didTap: () -> ()
    
    init(fillOption: FillOption, didTap: @escaping () -> Void) {
        self.fillOption = fillOption
        self.didTap = didTap
    }

    var body: some View {

        var backgroundColor: Color {
            guard fillOption.isSelected else {
                return Color(.secondarySystemFill)
            }
            if fillOption.disableWhenSelected {
                return .accentColor
            } else {
                return colorScheme == .light ? selectionColorLight : selectionColorDark
            }
        }
        
        return Button {
            didTap()
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(backgroundColor)
                HStack(spacing: 5) {
                    Image(systemName: fillOption.systemImage)
                        .foregroundColor(fillOption.isSelected ? .white : .secondary)
                        .imageScale(.small)
                        .frame(height: 25)
                    Text(fillOption.string)
                        .foregroundColor(fillOption.isSelected ? .white : .primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
//            .background(
//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .foregroundColor(isSelected.wrappedValue ? .accentColor : Color(.secondarySystemFill))
//            )
        }
        .grayscale(fillOption.isSelected ? 1 : 0)
        .disabled(fillOption.disableWhenSelected ? fillOption.isSelected : false)
    }
}
