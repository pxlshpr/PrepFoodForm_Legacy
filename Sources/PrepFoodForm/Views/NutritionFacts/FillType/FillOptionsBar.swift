import SwiftUI
import SwiftHaptics

struct FillOptionsBar: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var fieldFormViewModel: FieldValueViewModel

    @Binding var fieldValue: FieldValue
//    @Binding var showingImageTextPicker: Bool
//    @State var ignoreNextChange: Bool = false

    var body: some View {
        scrollView
    }
    
    let ColorBarLight = Color(hex: "fbfbfc")
    let ColorBarDark = Color(hex: "282827")
    
    var barColor: Color {
        colorScheme == .light ? ColorBarLight : ColorBarDark
    }
    
    var gradient: Gradient {
        Gradient(colors: [barColor, .clear])
    }
    var scrollView: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Color.clear.frame(width: 5)
                    prefillButton
                    imageAutofillButton
                    imageSelectButton
                    calculatedButton
                    Color.clear.frame(width: 5)
                }
            }
            .onTapGesture {
            }
            .padding(.vertical, 5)
            HStack {
                LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                    .frame(width: 10, height: 44)
                Spacer()
                LinearGradient(gradient: gradient, startPoint: .trailing, endPoint: .leading)
                    .frame(width: 10, height: 44)
            }
        }
        .frame(height: 44)
    }
    
    @ViewBuilder
    var prefillButton: some View {
        if let prefillFieldValue = viewModel.fieldValueFromPrefilledFood(for: fieldValue) {
            Color.blue
//            FillOptionButton(
//                string: prefillFieldValue.fillButtonString,
//                systemImage: "link",
//                isSelected: fieldValue.fillType == .prefill)
//            {
//                withAnimation {
//                    Haptics.feedback(style: .rigid)
                    //TODO: Bring these back
//                    if fieldValue.double != 125 {
//                        ignoreNextAmountChange = true
//                    }
//                    if fieldValue.unit != .kcal {
//                        ignoreNextUnitChange = true
//                    }
//                    fieldValue.double = 125
//                    fieldValue.unit = .kcal
//                    fieldValue.fillType = .prefill
//                }
//            }
        }
    }
    
    @ViewBuilder
    var imageAutofillButton: some View {
        if let scanResultFieldValue = viewModel.fieldValueFromScanResults(for: fieldValue),
           !scanResultFieldValue.fillType.isCalculated
        {
            Color.blue
//            FillOptionButton(
//                string: scanResultFieldValue.fillButtonString,
//                systemImage: "text.viewfinder",
//                isSelected: fieldValue.fillType.isImageAutofill)
//            {
//                withAnimation {
//                    Haptics.feedback(style: .rigid)
//                    fieldFormViewModel.ignoreNextChange = true
//                    withAnimation {
//                        fieldValue = scanResultFieldValue
//                    }
//                    if fieldValue.double != 115 {
//                        ignoreNextAmountChange = true
//                    }
//                    if fieldValue.unit != .kcal {
//                        ignoreNextUnitChange = true
//                    }
//                    fieldValue.double = 115
//                    fieldValue.unit = .kcal
//                }
//            }
        }
    }
    
    var imageSelectButton: some View {
        Color.blue
//        var title: String {
//            fieldValue.fillType.isImageSelection ? "Select" : "Select"
//        }
//        return FillOptionButton(
//            string: title,
//            systemImage: "hand.tap",
//            isSelected: fieldValue.fillType.isImageSelection,
//            disabledWhenSelected: false)
//        {
//            Haptics.feedback(style: .soft)
//            fieldFormViewModel.showingImageTextPicker = true
//        }
    }
    
    @ViewBuilder
    var calculatedButton: some View {
        Color.blue
//        if let calculatedFieldValue = viewModel.calculatedFieldValue(for: fieldValue) {
//            FillOptionButton(
//                string: calculatedFieldValue.fillButtonString,
//                systemImage: "equal.square",
//                isSelected: fieldValue.fillType.isCalculated)
//            {
//                withAnimation {
//                    Haptics.feedback(style: .rigid)
//                    fieldFormViewModel.ignoreNextChange = true
//                    withAnimation {
//                        fieldValue = calculatedFieldValue
//                    }
//                }
//            }
//        }
    }
}

import FoodLabelScanner

extension FoodFormViewModel {
    
    func calculatedFieldValue(for fieldValue: FieldValue) -> FieldValue? {
        var newFieldValue = fieldValue
        
        switch fieldValue {
        case .energy:
            /// First check if we have a calculated value from the scanResult (which will be indicated by it not having an associated text)
            if let energyFieldValue = calculatedFieldValueFromScanResults(for: .energy) {
                return energyFieldValue
            } else {
                /// If this is not the case—do the calculation ourself by seeing if we have 3 other components of the energy equation and if so—calculating it

            }
            
            
        case .macro:
            /// First check if we have a calculated value from the scanResult (which will be indicated by it not having an associated text)
            if let macroFieldValue = calculatedFieldValueFromScanResults(for: fieldValue.macroValue.macro.attribute) {
                return macroFieldValue
            } else {
                /// If this is not the case—do the calculation ourself by seeing if we have 3 other components of the energy equation and if so—calculating it
                newFieldValue.macroValue.double = 54

            }
            
            
        default:
            return nil
        }
        newFieldValue.fillType = .calculated
        return newFieldValue
    }
    
    func calculatedFieldValueFromScanResults(for attribute: Attribute) -> FieldValue? {
        guard let fieldValue = fieldValueFromScanResults(for: attribute),
              fieldValue.fillType == .calculated
        else {
            return nil
        }
        return fieldValue
    }
}

struct FillOptionsBarPreview: View {
    
    @State var fieldValue: FieldValue
    @StateObject var viewModel = FoodFormViewModel()
    
    init() {
        _fieldValue = State(initialValue: FieldValue(micronutrient: .addedSugars, fillType: .userInput))
    }
    
    var body: some View {
        ZStack {
            Color.gray
                .edgesIgnoringSafeArea(.all)
            FillOptionsBar(fieldValue: $fieldValue)
                .environmentObject(viewModel)
                .background(.white)
                .padding(.horizontal)
        }
    }
}

struct FillOptionsBar_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionsBarPreview()
    }
}
