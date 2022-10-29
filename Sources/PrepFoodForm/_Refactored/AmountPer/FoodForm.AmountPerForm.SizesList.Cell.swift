import SwiftUI
import PrepDataTypes

extension FoodForm.AmountPerForm.SizesList {
    struct Cell: View {
        let size: FormSize
        let iconSystemImage: String?
    }
}

extension FoodForm.AmountPerForm.SizesList.Cell {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                if let volumePrefixString {
                    Text(volumePrefixString)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(", ")
                        .foregroundColor(Color(.quaternaryLabel))
                }
                Text(size.name)
                    .foregroundColor(.primary)
            }
            Spacer()
            Text(size.scaledAmountString)
                .foregroundColor(Color(.secondaryLabel))
            if let iconSystemImage {
                Image(systemName: iconSystemImage)
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    
    var volumePrefixString: String? {
        size.volumePrefixString
    }
}
