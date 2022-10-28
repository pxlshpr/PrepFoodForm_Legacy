import SwiftUI
import PrepDataTypes

struct FoodAmountView: View {
    
    @Binding var amountDescription: String
    @Binding var servingDescription: String?
    @Binding var numberOfSizes: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(amountDescription)
                    .foregroundColor(.primary)
                if let servingDescription {
                    Text("•")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text(servingDescription)
                        .foregroundColor(.secondary)
                }
                Spacer()
                sizesCount
            }
        }
    }
    
    
    @ViewBuilder
    var sizesCount: some View {
        if numberOfSizes > 0 {
            HStack {
//                Image(systemName: "plus.circle.fill")
//                    .foregroundColor(Color(.quaternaryLabel))
                Text("\(numberOfSizes) size\(numberOfSizes != 1 ? "s" : "")")
                    .foregroundColor(Color(.secondaryLabel))
            }
            .padding(.vertical, 5)
            .padding(.leading, 7)
            .padding(.trailing, 9)
            .background(
                Capsule(style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
            )
            .padding(.vertical, 5)
        }
    }
}
