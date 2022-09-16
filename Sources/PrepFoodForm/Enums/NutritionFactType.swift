import SwiftUI
import PrepUnits

enum NutritionFactType: Hashable {
    case energy
    case macro(Macro)
    case micro(NutrientType)
    
    func textColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .energy:
            return .accentColor
        case .macro(let macro):
            return macro.textColor(for: colorScheme)
        case .micro:
            return .gray
//                return Color(.secondaryLabel)
        }
    }
}

extension NutritionFactType: CustomStringConvertible {
    var description: String {
        switch self {
        case .energy:
            return "Energy"
        case .macro(let macro):
            return macro.description
        case .micro(let micro):
            return micro.description
        }
    }
}
