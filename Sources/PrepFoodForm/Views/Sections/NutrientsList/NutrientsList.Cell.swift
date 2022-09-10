import SwiftUI
import PrepUnits

extension FoodForm.NutrientsList {
    struct Cell: View {
        
        @State var nutrientType: NutrientType
        @State var name: String
        @State var amount: String
        @State var unit: String
        @State var inputType: NutrientInputType
    }
}

extension FoodForm.NutrientsList.Cell {
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
        .foregroundColor(nutrientType.color)
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
    
    //MARK: - Helpers
    
    enum NutrientType {
        case energy
        case macro(Macro)
        case micro
        
        var color: Color {
            switch self {
            case .energy:
                return .accentColor
            case .macro(let macro):
                return macro.color
            case .micro:
                return .gray
//                return Color(.secondaryLabel)
            }
        }
    }
    
    enum NutrientInputType {
        /// When user manually inputs the value by means of the keyboard, copy-pasting, etc.
        case manuallyEntered
        
        /// When the user opts for using the value filled in via the classifier
        case filledIn
        
        /// When the user selects a different recognized text of the image from what was chosen to be filled in with
        case selected
        
        var image: String {
            switch self {
            case .manuallyEntered: return "keyboard"
            case .filledIn: return "text.viewfinder"
            case .selected: return "rectangle.and.hand.point.up.left.filled"
            }
        }
    }
}
