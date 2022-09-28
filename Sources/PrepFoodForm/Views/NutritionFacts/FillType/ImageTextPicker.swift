import SwiftUI
import SwiftHaptics

struct ImageTextPicker: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var fieldValue: FieldValue
    @Binding var ignoreNextChange: Bool
    
    var body: some View {
        Button("Simulate") {
            Haptics.feedback(style: .rigid)
//            if fieldValue.energyValue.double != 135 {
//                ignoreNextAmountChange = true
//            }
//            if fieldValue.energyValue.unit != .kcal {
//                ignoreNextUnitChange = true
//            }
//            fieldValue.energyValue.double = 135
//            fieldValue.energyValue.unit = .kcal
//            fieldValue.energyValue.fillType = .imageSelection(UUID())
            dismiss()
        }
    }
}
