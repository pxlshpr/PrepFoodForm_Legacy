import SwiftUI

extension MFPFoodView {
    struct SizeCell: View {
        var sizeViewModel: MFPSizeViewModel
    }
}

extension MFPFoodView.SizeCell {
    var body: some View {
        HStack {
            Text(sizeViewModel.fullNameString)
                .foregroundColor(.primary)
            Spacer()
            HStack {
                Text(sizeViewModel.scaledAmountString)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}
