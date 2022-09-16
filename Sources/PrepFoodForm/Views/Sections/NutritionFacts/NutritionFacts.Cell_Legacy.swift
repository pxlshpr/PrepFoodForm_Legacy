import SwiftUI
import PrepUnits

extension FoodForm.NutritionFacts {
    struct Cell_Legacy: View {
        @State var nutrientType: NutritionFactType
        @State var name: String
        @State var amount: String
        @State var unit: String
        @State var inputType: NutritionFactInputType
    }
}

extension FoodForm.NutritionFacts.Cell_Legacy {
    var body: some View {
        content
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            topRow
            Spacer()
            bottomRow
        }
    }
    
    //MARK: - Components
    
    var systemImage: String {
        switch nutrientType {
        case .energy: return "flame"
        case .macro: return "circle.grid.cross"
        case .micro: return "circle.hexagongrid"
        }
    }
    var topRow: some View {
        HStack {
            Image(systemName: systemImage)
            Text(name)
            Spacer()
            inputIcon
            disclosureArrow
        }
        .foregroundColor(.black)
    }
    
    @ViewBuilder
    var inputIcon: some View {
        if inputType != .manuallyEntered {
            Image(systemName: inputType.image)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
    var bottomRow: some View {
        HStack {
            Text(amount)
                .foregroundColor(.primary)
                .font(.title2)
                .bold()
            Text(unit)
                .foregroundColor(.secondary)
            Spacer()
        }
    }    
}
