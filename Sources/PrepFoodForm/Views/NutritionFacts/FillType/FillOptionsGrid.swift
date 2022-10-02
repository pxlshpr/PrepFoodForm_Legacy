import SwiftUI
import SwiftUIFlowLayout

struct FillOptionsGrid: View {
    var body: some View {
//        grid
        flowLayout
    }
    
    var grid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80, maximum: 300))],
            alignment: .center,
            spacing: 16
        ) {
            ForEach(0...10, id: \.self) { index in
                FillOptionButton(
                    string: "\(index) hello there",
                    systemImage: "text.viewfinder",
                    isSelected: false) {
                        
                    }
            }
        }
    }
    
    var items: [String] {
        ["527 kcal", "1272 kJ", "325 kcal", "2000 kcal", "Choose"]
    }
    
    var flowLayout: some View {
        FlowLayout(mode: .scrollable, items: items, itemSpacing: 4) { string in
            FillOptionButton(
                string: string,
                systemImage: "text.viewfinder",
                isSelected: false) {

                }
                .buttonStyle(.borderless)
        }
    }
}

struct FillOptionsGridPreview: View {
    var body: some View {
        FillOptionsGrid()
    }
}

struct FillOptionsGrid_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionsGridPreview()
    }
}

import SwiftUI

struct FillOptionButton: View {
    
    let selectionColorDark = Color(hex: "6c6c6c")
    let selectionColorLight = Color(hex: "959596")
    @Environment(\.colorScheme) var colorScheme
    
    let string: String
    let systemImage: String
    let isSelected: Bool
    let disabledWhenSelected: Bool
    let didTap: () -> ()
    
    init(string: String, systemImage: String, isSelected: Bool, disabledWhenSelected: Bool = true, didTap: @escaping () -> Void) {
        self.string = string
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.disabledWhenSelected = disabledWhenSelected
        self.didTap = didTap
    }

    var body: some View {

        var backgroundColor: Color {
            guard isSelected else {
                return Color(.secondarySystemFill)
            }
            if disabledWhenSelected {
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
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(isSelected ? .white : .secondary)
                        .imageScale(.small)
                        .frame(height: 25)
                    Text(string)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
//            .background(
//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .foregroundColor(isSelected.wrappedValue ? .accentColor : Color(.secondarySystemFill))
//            )
        }
        .grayscale(isSelected ? 1 : 0)
        .disabled(disabledWhenSelected ? isSelected : false)
    }
}

struct FillOptionButtonPreview: View {
    var body: some View {
        FillOptionButton(string: "Fill", systemImage: "globe", isSelected: false) {
            
        }
    }
}

struct FillOptionButton_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionButtonPreview()
    }
}
