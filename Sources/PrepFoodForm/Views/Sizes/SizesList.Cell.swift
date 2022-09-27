import SwiftUI

extension SizesList {
    struct Cell: View {
        @Binding var size: NewSize
    }
}

extension SizesList.Cell {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                if let volumePrefixString = size.volumePrefixString {
                    Text(volumePrefixString)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(", ")
                        .foregroundColor(Color(.quaternaryLabel))
                }
                Text(size.nameString)
                    .foregroundColor(.primary)
            }
            Spacer()
            Text(size.scaledAmountString)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}
