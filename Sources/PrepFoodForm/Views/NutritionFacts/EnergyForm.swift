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
    
    @State var ignoreNextAmountChange: Bool = false
    @State var ignoreNextUnitChange: Bool = false
}

struct ImageTextPicker: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var fieldValue: FieldValue
    @Binding var ignoreNextAmountChange: Bool
    @Binding var ignoreNextUnitChange: Bool
    
    var body: some View {
        Button("Simulate") {
            Haptics.feedback(style: .rigid)
            if fieldValue.energyValue.double != 135 {
                ignoreNextAmountChange = true
            }
            if fieldValue.energyValue.unit != .kcal {
                ignoreNextUnitChange = true
            }
            fieldValue.energyValue.double = 135
            fieldValue.energyValue.unit = .kcal
            fieldValue.energyValue.fillType = .imageSelection(UUID())
            dismiss()
        }
    }
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
        .onChange(of: fieldValue.energyValue.double) { newValue in
            guard !ignoreNextAmountChange else {
                ignoreNextAmountChange = false
                return
            }
            withAnimation {
                fieldValue.energyValue.fillType = .userInput
            }
        }
        .onChange(of: fieldValue.energyValue.unit) { newValue in
            guard !ignoreNextUnitChange else {
                ignoreNextUnitChange = false
                return
            }
            withAnimation {
                fieldValue.energyValue.fillType = .userInput
            }
        }
        .sheet(isPresented: $showingFillForm) {
            FillForm()
        }
        .sheet(isPresented: $showingImageTextPicker) {
            ImageTextPicker(fieldValue: $fieldValue, ignoreNextAmountChange: $ignoreNextAmountChange, ignoreNextUnitChange: $ignoreNextUnitChange)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    var content: some View {
        var fillButtonsLayer: some View {
            VStack {
                Spacer()
                fillButtons
                    .padding(.bottom, 10)
            }
        }
        return ZStack {
            form
            fillButtonsLayer
        }
    }
    
    var form: some View {
        var textFieldSection: some View {
            var headerString: String {
                switch fieldValue.energyValue.fillType {
                case .thirdPartyFoodPrefill:
                    return "Copied from third-pary food"
                case .imageAutofill:
                    return "Auto-filled from image"
                case .imageSelection:
                    return "Selected from image"
                case .userInput:
                    if !fieldValue.isEmpty {
                        return "Manually entered"
                    }
                default:
                    break
                }
                return ""
            }
            
            return Section(headerString) {
//            return Section {
                HStack {
                    textField
                    unitLabel
                }
            }
        }
        
        var sampleImage: UIImage? {
            guard let path = Bundle.module.path(forResource: "energy1", ofType: "jpg") else {
                return nil
            }
            return UIImage(contentsOfFile: path)
        }
        
        func imageSection(for image: UIImage) -> some View {
            var header: some View {
                var string: String {
                    fieldValue.energyValue.fillType.isImageAutofill ? "Detected Text" : "Selected Text"
                }
                
                var systemImage: String {
                    fieldValue.energyValue.fillType.isImageAutofill ? "text.viewfinder" : "hand.tap"
                }
                
                return Text(string)
//                return Label(string, systemImage: systemImage)
            }
            
            return Section(header: header) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                Button {
//                } label: {
//                    Text("Select another text")
//                }
            }
        }
        @ViewBuilder
        var optionalImageSection: some View {
            if fieldValue.energyValue.fillType.usesImage, let image = sampleImage {
                imageSection(for: image)
            }
        }
        
        @ViewBuilder
        var optionalSelectSection: some View {
            if fieldValue.energyValue.fillType.isImageSelection {
                Section {
                    Button {
                    } label: {
                        Text("Select another text")
                    }
                }
            }
        }
        return Form {
            textFieldSection
            optionalImageSection
            optionalSelectSection
        }
    }
    
    var fillButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Spacer().frame(width: 5)
                thirdPartyButton
                imageAutofillButton
                imageSelectButton
                Spacer().frame(width: 5)
            }
        }
        .onTapGesture {
        }
    }
    
    @ViewBuilder
    var thirdPartyButton: some View {
        button("125 kcal", systemImage: "link", isSelected: fieldValue.energyValue.fillType == .thirdPartyFoodPrefill) {
            withAnimation {
                Haptics.feedback(style: .rigid)
                if fieldValue.energyValue.double != 125 {
                    ignoreNextAmountChange = true
                }
                if fieldValue.energyValue.unit != .kcal {
                    ignoreNextUnitChange = true
                }
                fieldValue.energyValue.double = 125
                fieldValue.energyValue.unit = .kcal
                fieldValue.energyValue.fillType = .thirdPartyFoodPrefill
            }
        }
    }
    
    @ViewBuilder
    var imageAutofillButton: some View {
        button("115 kcal", systemImage: "text.viewfinder", isSelected: fieldValue.energyValue.fillType.isImageAutofill) {
            withAnimation {
                Haptics.feedback(style: .rigid)
                if fieldValue.energyValue.double != 115 {
                    ignoreNextAmountChange = true
                }
                if fieldValue.energyValue.unit != .kcal {
                    ignoreNextUnitChange = true
                }
                fieldValue.energyValue.double = 115
                fieldValue.energyValue.unit = .kcal
                fieldValue.energyValue.fillType = .imageAutofill(UUID())
            }
        }
    }
    
    @ViewBuilder
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
