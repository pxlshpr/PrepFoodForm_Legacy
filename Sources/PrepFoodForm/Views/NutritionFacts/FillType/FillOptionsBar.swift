import SwiftUI
import SwiftHaptics

struct FillOptionsBar: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Binding var fieldValue: FieldValue

    @State var showingImageTextPicker = false
    @State var ignoreNextChange: Bool = false

    var body: some View {
        scrollView
            .sheet(isPresented: $showingImageTextPicker) {
                ImageTextPicker(fieldValue: $fieldValue, ignoreNextChange: $ignoreNextChange)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
            //TODO: Maybe do an onchange on the whole fieldValue? or grab textfield and do it there
            .onChange(of: fieldValue) { newValue in
                guard !ignoreNextChange else {
                    ignoreNextChange = false
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
            HStack(spacing: 10) {
                Spacer().frame(width: 5)
                prefillButton
                imageAutofillButton
                imageSelectButton
                Spacer().frame(width: 5)
            }
        }
        .onTapGesture {
        }
        .padding(.vertical, 10)
        .background(
            VStack(spacing: 0) {
                Divider()
//                Color(.systemGroupedBackground)
                Color.clear
                    .background (
                            .thinMaterial
                    )
            }
        )
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
                    ignoreNextChange = true
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
            showingImageTextPicker = true
        }
    }
    
    func button(_ string: String, systemImage: String, isSelected: Bool, action: @escaping () -> ()) -> some View {
        
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundColor(isSelected ? .accentColor : Color(.secondarySystemFill))
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(isSelected ? .white : .secondary)
                    Text(string)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
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
