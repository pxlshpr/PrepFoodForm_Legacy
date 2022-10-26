import SwiftUI

extension FoodForm_Legacy {
    struct NutrientsCell: View {
    }
}

extension FoodForm_Legacy.NutrientsCell {
    
    var body: some View {
        emptyContent
//        content
    }
    
    var emptyContent: some View {
        Text("Add nutrients")
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Text("Calories")
                    .bold()
                Text("325")
            }
            HStack(spacing: 5) {
                Text("Fat")
                    .bold()
                Text("0g")
            }
            HStack(spacing: 5) {
                Text("Carbohydrate")
                    .bold()
                Text("17g")
            }
            HStack(spacing: 5) {
                Text("Protein")
                    .bold()
                Text("1g")
            }
            Text("…")
        }
    }
}
