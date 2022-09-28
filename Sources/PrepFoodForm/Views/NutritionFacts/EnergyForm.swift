import SwiftUI
import PrepUnits
import SwiftHaptics

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
}

extension EnergyForm {
    
    var body: some View {
        content
            .scrollDismissesKeyboard(.never)
            .navigationTitle(fieldValue.description)
            .toolbar { keyboardToolbarContents }
            .onAppear {
                isFocused = true
            }
    }
    
    var content: some View {
        ZStack {
            form
//            VStack {
//                Spacer()
//                FillOptionsBar(fieldValue: $fieldValue)
//                    .environmentObject(viewModel)
//            }
        }
    }
    
    var form: some View {
        Form {
            textFieldSection
            FilledImageSection(fieldValue: $fieldValue)
            optionalSelectSection
        }
        .safeAreaInset(edge: .bottom) {
            Spacer().frame(height: 50)
        }
    }
    
    var textFieldSection: some View {
        Section(fieldValue.fillType.sectionHeaderString) {
            HStack {
                textField
                unitLabel
            }
        }
    }
    
    @ViewBuilder
    var optionalSelectSection: some View {
        if fieldValue.energyValue.fillType.isImageSelection {
            Section {
                Button {
                    Haptics.feedback(style: .soft)
                    //TODO: Communicate this
                    //                    showingImageTextPicker = true
                } label: {
                    Text("Select another text")
                }
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $fieldValue.energyValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
            .font(.largeTitle)
    }
    
    var unitLabel: some View {
//        Text(fieldValue.unitString)
//            .foregroundColor(.secondary)
//            .font(.title3)
        Picker("", selection: $fieldValue.energyValue.unit) {
            ForEach(EnergyUnit.allCases, id: \.self) { unit in
                Text(unit.shortDescription).tag(unit)
            }
        }
        .pickerStyle(.segmented)

    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack(spacing: 0) {
                FillOptionsBarNew(fieldValue: $fieldValue)
                    .environmentObject(viewModel)
                    .frame(maxWidth: .infinity)
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct EnergyFormPreview: View {
    
    @State var fieldValue = FieldValue.energy(FieldValue.EnergyValue(double: 105, string: "105", unit: .kcal, fillType: .thirdPartyFoodPrefill))
    
    @StateObject var viewModel = FoodFormViewModel()
    var body: some View {
        EnergyForm(fieldValue: $fieldValue)
            .environmentObject(viewModel)
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        EnergyFormPreview()
    }
}
