import SwiftUI
import SwiftHaptics

struct FillOptionsBar: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var fieldFormViewModel: FieldFormViewModel

    @Binding var fieldValue: FieldValue
//    @Binding var showingImageTextPicker: Bool
//    @State var ignoreNextChange: Bool = false

    var body: some View {
        scrollView
    }
    
    var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                prefillButton
                imageAutofillButton
                imageSelectButton
            }
        }
        .onTapGesture {
        }
        .padding(.vertical, 5)
    }
    
    @ViewBuilder
    var prefillButton: some View {
        if let prefillFieldValue = viewModel.fieldValueFromPrefilledFood(for: fieldValue) {
            button(prefillFieldValue.fillButtonString,
                   systemImage: "link",
                   isSelected: fieldValue.fillType == .thirdPartyFoodPrefill)
            {
                withAnimation {
                    Haptics.feedback(style: .rigid)
                    //TODO: Bring these back
//                    if fieldValue.double != 125 {
//                        ignoreNextAmountChange = true
//                    }
//                    if fieldValue.unit != .kcal {
//                        ignoreNextUnitChange = true
//                    }
//                    fieldValue.double = 125
//                    fieldValue.unit = .kcal
//                    fieldValue.fillType = .thirdPartyFoodPrefill
                }
            }
        }
    }
    
    @ViewBuilder
    var imageAutofillButton: some View {
        if let outputFieldValue = viewModel.fieldValueFromOutputs(for: fieldValue) {
            button(outputFieldValue.fillButtonString,
                   systemImage: "text.viewfinder",
                   isSelected: fieldValue.fillType.isImageAutofill)
            {
                withAnimation {
                    Haptics.feedback(style: .rigid)
                    fieldFormViewModel.ignoreNextChange = true
                    withAnimation {
                        fieldValue = outputFieldValue
                    }
//                    if fieldValue.double != 115 {
//                        ignoreNextAmountChange = true
//                    }
//                    if fieldValue.unit != .kcal {
//                        ignoreNextUnitChange = true
//                    }
//                    fieldValue.double = 115
//                    fieldValue.unit = .kcal
                }
            }
        }
    }
    
    var imageSelectButton: some View {
        var title: String {
            fieldValue.fillType.isImageSelection ? "Select" : "Select"
        }
        return button(title, systemImage: "hand.tap", isSelected: fieldValue.fillType.isImageSelection, disableAllowed: false) {
            Haptics.feedback(style: .soft)
            fieldFormViewModel.showingImageTextPicker = true
        }
    }
    
    func button(_ string: String, systemImage: String, isSelected: Bool, disableAllowed: Bool = true, action: @escaping () -> ()) -> some View {
        
        let selectionColorDark = Color(hex: "6c6c6c")
        let selectionColorLight = Color(hex: "959596")

        var backgroundColor: Color {
            guard isSelected else {
                return Color(.secondarySystemFill)
            }
            if disableAllowed {
                return .accentColor
            } else {
                return colorScheme == .light ? selectionColorLight : selectionColorDark
            }
        }
        
        return Button {
            action()
        } label: {
            ZStack {
//                RoundedRectangle(cornerRadius: 10, style: .continuous)
                Capsule(style: .continuous)
                    .foregroundColor(backgroundColor)
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(isSelected ? .white : .secondary)
                        .imageScale(.small)
                        .frame(height: 25)
                    Text(string)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
//            .background(
//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .foregroundColor(isSelected.wrappedValue ? .accentColor : Color(.secondarySystemFill))
//            )
        }
        .grayscale(isSelected ? 1 : 0)
        .disabled(disableAllowed ? isSelected : false)
    }
    
}
