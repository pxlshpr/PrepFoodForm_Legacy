import SwiftUI

struct FoodDetailsView: View {
    
    @Binding var emoji: String
    @Binding var name: String
    @Binding var detail: String
    @Binding var brand: String

    var didTapEmoji: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            emojiButton
            VStack(alignment: .leading) {
                nameText
                detailText
                    .foregroundColor(.secondary)
                brandText
                    .foregroundColor(Color(.tertiaryLabel))
            }
            Spacer()
        }
        .foregroundColor(.primary)
    }
    
    var emojiButton: some View {
        var emojiLabel: some View {
            Text(emoji)
                .font(.system(size: 50))
        }
        
        return Group {
            if let didTapEmoji {
                Button {
                    didTapEmoji()
                } label: {
                    emojiLabel
                }
            } else {
                emojiLabel
            }
        }
    }
    
    @ViewBuilder
    var nameText: some View {
        if !name.isEmpty {
            Text(name)
                .bold()
                .multilineTextAlignment(.leading)
        } else {
            Text("Required")
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    @ViewBuilder
    var detailText: some View {
        if !detail.isEmpty {
            Text(detail)
                .multilineTextAlignment(.leading)
        }
    }

    @ViewBuilder
    var brandText: some View {
        if !brand.isEmpty {
            Text(brand)
                .multilineTextAlignment(.leading)
        }
    }    
}
