import SwiftUI

extension FoodForm.AmountPerForm {
    struct DensityView: View {
        @ObservedObject var field: Field
        @Binding var isWeightBased: Bool
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
        }
    }
}
