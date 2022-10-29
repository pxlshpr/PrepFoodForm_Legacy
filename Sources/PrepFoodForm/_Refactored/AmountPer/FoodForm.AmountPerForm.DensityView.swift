import SwiftUI

extension FoodForm.AmountPerForm {
    struct DensityView: View {
        @ObservedObject var field: Field
        @Binding var isWeightBased: Bool
        @Binding var shouldShowFillIcon: Bool
    }
}
extension FoodForm.AmountPerForm.DensityView {
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.triangle.swap")
                .foregroundColor(Color(.tertiaryLabel))
            if let description = field.value.densityValue?.description(weightFirst: isWeightBased) {
                Text(description)
                    .foregroundColor(Color(.secondaryLabel))
            } else {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
            Spacer()
            fillTypeIcon
        }
    }
    
    @ViewBuilder
    var fillTypeIcon: some View {
        if shouldShowFillIcon {
            Image(systemName: field.value.fill.iconSystemImage)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}
