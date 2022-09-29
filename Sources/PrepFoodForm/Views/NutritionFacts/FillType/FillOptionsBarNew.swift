import SwiftUI
import SwiftHaptics

struct FillOptionsBarNew: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var fieldFormViewModel: FieldFormViewModel

    @Binding var fieldValue: FieldValue
//    @Binding var showingImageTextPicker: Bool
//    @State var ignoreNextChange: Bool = false

    var body: some View {
        scrollView
            //TODO: Maybe do an onchange on the whole fieldValue? or grab textfield and do it there
            .onChange(of: fieldValue) { newValue in
                guard !fieldFormViewModel.ignoreNextChange else {
                    fieldFormViewModel.ignoreNextChange = false
                    return
                }
                withAnimation {
                    fieldValue.fillType = .userInput
                }
            }
//            .onChange(of: fieldValue.energyValue.unit) { newValue in
//                guard !ignoreNextUnitChange else {
//                    ignoreNextUnitChange = false
//                    return
//                }
//                withAnimation {
//                    fieldValue.energyValue.fillType = .userInput
//                }
//            }
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
                   isSelected: fieldValue.energyValue.fillType == .thirdPartyFoodPrefill)
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
//                    fieldValue.energyValue.double = 125
//                    fieldValue.energyValue.unit = .kcal
//                    fieldValue.energyValue.fillType = .thirdPartyFoodPrefill
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
                    fieldValue = outputFieldValue
//                    if fieldValue.energyValue.double != 115 {
//                        ignoreNextAmountChange = true
//                    }
//                    if fieldValue.energyValue.unit != .kcal {
//                        ignoreNextUnitChange = true
//                    }
//                    fieldValue.energyValue.double = 115
//                    fieldValue.energyValue.unit = .kcal
                }
            }
        }
    }
    
    var imageSelectButton: some View {
        var title: String {
            fieldValue.energyValue.fillType.isImageSelection ? "Selected 140" : "Select"
        }
        return button(title, systemImage: "hand.tap", isSelected: fieldValue.energyValue.fillType.isImageSelection) {
            Haptics.feedback(style: .soft)
            fieldFormViewModel.showingImageTextPicker = true
        }
    }
    
    func button(_ string: String, systemImage: String, isSelected: Bool, action: @escaping () -> ()) -> some View {
        
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(isSelected ? .accentColor : Color(.secondarySystemFill))
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(isSelected ? .white : .secondary)
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
        .disabled(isSelected)
    }
    
}
