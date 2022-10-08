import SwiftUI

extension SizesList {
    struct Cell: View {
        @ObservedObject var fieldViewModel: FieldViewModel
    }
}

extension SizesList.Cell {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                if let volumePrefixString {
                    Text(volumePrefixString)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(", ")
                        .foregroundColor(Color(.quaternaryLabel))
                }
                Text(name)
                    .foregroundColor(.primary)
            }
            Spacer()
            Text(amountString)
                .foregroundColor(Color(.secondaryLabel))
            //            Button {
            //
            //            } label: {
            //                Image(systemName: size.fillType.buttonSystemImage)
            //                    .imageScale(.large)
            //            }
            //            .buttonStyle(.borderless)
        }
    }
    
    var size: Size? {
        fieldViewModel.fieldValue.size
    }
    
    var volumePrefixString: String? {
        size?.volumePrefixString
    }
    
    var name: String {
        size?.name ?? ""
    }
    
    var amountString: String {
        size?.scaledAmountString ?? ""
    }
}
