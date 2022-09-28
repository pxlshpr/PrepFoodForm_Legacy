import SwiftUI
import PrepUnits
import SwiftHaptics

struct EnergyForm: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    @Binding var fieldValue: FieldValue
    
    @State var showingFillForm = false
    
    @State var showingImageTextPicker = false
    @State var isSelected1: Bool = false
    @State var isSelected2: Bool = false
    @State var isSelected3: Bool = false
    @State var ignoreNextAmountChange: Bool = false
    @State var ignoreNextUnitChange: Bool = false
    @State var selectedText = "Select"
}

struct ImageTextPicker: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button("Simulate") {
            dismiss()
        }
    }
}
extension EnergyForm {
    var body: some View {
        form
        .scrollDismissesKeyboard(.never)
        .navigationTitle(fieldValue.description)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            isFocused = true
        }
        .onChange(of: fieldValue.energyValue.double) { newValue in
            guard !ignoreNextAmountChange else {
                ignoreNextAmountChange = false
                return
            }
            isSelected1 = false
            isSelected2 = false
            isSelected3 = false
            fieldValue.energyValue.fillType = .userInput
        }
        .onChange(of: fieldValue.energyValue.unit) { newValue in
            guard !ignoreNextUnitChange else {
                ignoreNextUnitChange = false
                return
            }
            isSelected1 = false
            isSelected2 = false
            isSelected3 = false
            fieldValue.energyValue.fillType = .userInput
        }
        .sheet(isPresented: $showingFillForm) {
            FillForm()
        }
        .sheet(isPresented: $showingImageTextPicker) {
            ImageTextPicker()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .onDisappear {
                    Haptics.feedback(style: .rigid)
                    if fieldValue.energyValue.double != 135 {
                        ignoreNextAmountChange = true
                    }
                    if fieldValue.energyValue.unit != .kcal {
                        ignoreNextUnitChange = true
                    }
                    fieldValue.energyValue.double = 135
                    fieldValue.energyValue.unit = .kcal
                    isSelected1 = false
                    isSelected2 = false
                    isSelected3 = true
                    selectedText = "Selected 140"
                }
        }
    }
    
    var form: some View {
        ZStack {
            Form {
                HStack {
                    textField
                    unitLabel
//                    fillButton
                }
            }
            VStack {
                Spacer()
                fillButtons
                    .padding(.bottom, 10)
            }
        }
    }
    
    var fillButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Spacer().frame(width: 5)
                button("125 kcal", systemImage: "link", isSelected: isSelected1) {
                    Haptics.feedback(style: .rigid)
                    if fieldValue.energyValue.double != 125 {
                        ignoreNextAmountChange = true
                    }
                    if fieldValue.energyValue.unit != .kcal {
                        ignoreNextUnitChange = true
                    }
                    fieldValue.energyValue.double = 125
                    fieldValue.energyValue.unit = .kcal
                    isSelected1 = true
                    isSelected2 = false
                    isSelected3 = false
                    selectedText = "Select"
                }
                button("115 kcal", systemImage: "text.viewfinder", isSelected: isSelected2) {
                    Haptics.feedback(style: .rigid)
                    if fieldValue.energyValue.double != 115 {
                        ignoreNextAmountChange = true
                    }
                    if fieldValue.energyValue.unit != .kcal {
                        ignoreNextUnitChange = true
                    }
                    fieldValue.energyValue.double = 115
                    fieldValue.energyValue.unit = .kcal
                    isSelected1 = false
                    isSelected2 = true
                    isSelected3 = false
                    selectedText = "Select"
                }
                button(selectedText, systemImage: "photo.on.rectangle.angled", isSelected: isSelected3) {
                    Haptics.feedback(style: .soft)
                    showingImageTextPicker = true
                }
                Spacer().frame(width: 5)
            }
        }
        .onTapGesture {
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
    
//    @ViewBuilder
//    var fillButton: some View {
//        if viewModel.shouldShowFillButton {
//            Button {
//                Haptics.feedback(style: .soft)
//                showingFillForm = true
//            } label: {
//                Image(systemName: fieldValue.energyValue.fillType.buttonSystemImage)
//                    .imageScale(.large)
//            }
//            .buttonStyle(.borderless)
//        }
//    }
    
    var textField: some View {
        TextField("Required", text: $fieldValue.energyValue.string)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .interactiveDismissDisabled()
    }
    
    var unitLabel: some View {
        Text(fieldValue.unitString)
            .foregroundColor(.secondary)
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Picker("", selection: $fieldValue.energyValue.unit) {
                ForEach(EnergyUnit.allCases, id: \.self) { unit in
                    Text(unit.shortDescription).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            Spacer()
            Button("Done") {
                dismiss()
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
