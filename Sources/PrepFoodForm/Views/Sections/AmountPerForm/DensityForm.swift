import SwiftUI
import SwiftUISugar
import SwiftHaptics
import VisionSugar

struct DensityForm: View {
    
    enum FocusedField {
        case weight, volume
    }
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @ObservedObject var existingDensityViewModel: FieldViewModel
    @StateObject var densityViewModel: FieldViewModel

    @Environment(\.dismiss) var dismiss
    
    @State var showingWeightUnitPicker = false
    @State var showingVolumeUnitPicker = false
    @State var shouldAnimateOptions = false
    @State var showingTextPicker = false
    @State var doNotRegisterUserInput: Bool
    @State var hasBecomeFirstResponder: Bool = false
    @FocusState var focusedField: FocusedField?
    
    let weightFirst: Bool
    
    init(densityViewModel: FieldViewModel, orderWeightFirst: Bool) {
        
        self.existingDensityViewModel = densityViewModel
        _densityViewModel = StateObject(wrappedValue: densityViewModel)
        
        self.weightFirst = orderWeightFirst
//            _doNotRegisterUserInput = State(initialValue: !densityViewModel.fieldValue.isEmpty)
        _doNotRegisterUserInput = State(initialValue: true)
    }
    
    var body: some View {
        form
        .navigationTitle(navigationTitle)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            focusedField = weightFirst ? .weight : .volume
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shouldAnimateOptions = true
                
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                doNotRegisterUserInput = false
            }
        }
        .fullScreenCover(isPresented: $showingTextPicker) {
            textPicker
        }
    }
    
    var form: some View {
        FormStyledScrollView {
            fieldSection
//            if weightFirst {
//                weightSection
//                volumeSection
//            } else {
//                volumeSection
//                weightSection
//            }
            fillOptionsSections
        }
        .sheet(isPresented: $showingWeightUnitPicker) {
            UnitPicker(
                pickedUnit: densityViewModel.fieldValue.weight.unit,
                filteredType: .weight)
            { unit in
                densityViewModel.fieldValue.weight.unit = unit
            }
            .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingVolumeUnitPicker) {
            UnitPicker(
                pickedUnit: densityViewModel.fieldValue.volume.unit,
                filteredType: .volume)
            { unit in
                densityViewModel.fieldValue.volume.unit = unit
            }
            .environmentObject(viewModel)
        }
    }
    
    var textPickerConfiguration: TextPickerConfiguration {
        TextPickerConfiguration(
            imageViewModels: viewModel.imageViewModels,
            filter: .textsWithDensities,
            selectedImageTexts: densityViewModel.fill.imageTexts,
            didSelectImageTexts: { imageTexts in
                didSelectImageTexts(imageTexts)
            }
        )
    }
    
    var textPicker: some View {
        TextPicker(config: textPickerConfiguration)
            .onDisappear {
                guard densityViewModel.isCroppingNextImage else {
                    return
                }
                densityViewModel.cropFilledImage()
                doNotRegisterUserInput = false
            }
    }
    
    func didSelectImageTexts(_ imageTexts: [ImageText]) {
        
        guard let imageText = imageTexts.first else {
            return
        }

        guard let densityValue = imageText.text.string.detectedValues.densityValue else {
            return
        }
        
        let fill = fill(for: imageText, with: densityValue)

        doNotRegisterUserInput = true
        
        //Now set this fill on the density value
        setDensityValue(densityValue)
        densityViewModel.fieldValue.fill = fill
        densityViewModel.isCroppingNextImage = true
    }
    
    func fill(for imageText: ImageText,
              with densityValue: FieldValue.DensityValue
    ) -> Fill {
        if let fill = viewModel.firstScannedFill(for: densityViewModel.fieldValue, with: densityValue) {
            return fill
        } else {
            return .selection(.init(
                imageText: imageText,
                densityValue: densityValue
            ))
        }
    }

    var selectedImageIndex: Int? {
        viewModel.imageViewModels.firstIndex(where: { $0.scanResult?.id == densityViewModel.fill.resultId })
    }

    var fillOptionsSections: some View {
        FillOptionsSections(
            fieldViewModel: densityViewModel,
            shouldAnimate: $shouldAnimateOptions,
            didTapImage: didTapImage,
            didTapFillOption: didTapFillOption
        )
    }
    
    func didTapImage() {
        showTextPicker()
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        switch fillOption.type {
        case .select:
            didTapSelect()
        case .fill(let fill):
            Haptics.feedback(style: .rigid)
            
            doNotRegisterUserInput = true
            switch fill {
            case .prefill(let info):
                guard let densityValue = info.densityValue else {
                    return
                }
                setDensityValue(densityValue)
            case .scanned(let info):
                guard let densityValue = info.densityValue else {
                    return
                }
                setDensityValue(densityValue)
                densityViewModel.assignNewScannedFill(fill)
            default:
                break
            }
            doNotRegisterUserInput = false
            saveAndDismiss()
        }
    }
    
    func didTapSelect() {
        showTextPicker()
    }
    
    func showTextPicker() {
        Haptics.feedback(style: .soft)
        doNotRegisterUserInput = true
        focusedField = nil
        showingTextPicker = true
    }

    func setDensityValue(_ densityValue: FieldValue.DensityValue) {
        densityViewModel.fieldValue.weight.double = densityValue.weight.double
        densityViewModel.fieldValue.weight.unit = densityValue.weight.unit
        densityViewModel.fieldValue.volume.double = densityValue.volume.double
        densityViewModel.fieldValue.volume.unit = densityValue.volume.unit
    }
    
    func saveAndDismiss() {
        doNotRegisterUserInput = true
        existingDensityViewModel.copyData(from: densityViewModel)
        dismiss()
    }

    var weightSection: some View {
        FormStyledSection(header: Text("Weight")) {
            weightStack
        }
    }
    
    var fieldSection: some View {
        FormStyledSection {
            HStack {
                Spacer()
                if weightFirst {
                    weightStack
                } else {
                    volumeStack
                }
                Spacer()
                Text("↔")
                    .font(.title2)
                    .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                if weightFirst {
                    volumeStack
                } else {
                    weightStack
                }
                Spacer()
            }
        }
    }
    
    @State var showColors = false
    
    //MARK: - Weight
    var weightStack: some View {
        HStack {
//            Spacer()
            weightTextField
//                .background(showColors ? .green : .clear)
                .padding(.vertical, 5)
//                .background(
//                    RoundedRectangle(cornerRadius: 5)
//                        .foregroundColor(Color(.systemGroupedBackground))
//                )
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            weightUnitButton
                .background(showColors ? .red : .clear)
                .layoutPriority(2)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            Spacer()
        }
        .background(showColors ? .brown : .clear)
    }
    
    var volumeStack: some View {
        HStack {
//            Spacer()
            volumeTextField
//                .background(showColors ? .yellow : .clear)
                .padding(.vertical, 5)
//                .background(
//                    RoundedRectangle(cornerRadius: 5)
//                        .foregroundColor(Color(.systemGroupedBackground))
//                )
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            volumeUnitButton
                .background(showColors ? .blue : .clear)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            Spacer()
        }
        .background(showColors ? .pink : .clear)
    }
    
    var weightTextField: some View {
        let binding = Binding<String>(
            get: { densityViewModel.fieldValue.weight.string },
            set: {
                if !doNotRegisterUserInput, focusedField == .weight, $0 != densityViewModel.fieldValue.weight.string {
                    withAnimation {
                        densityViewModel.registerUserInput()
                    }
                }
                densityViewModel.fieldValue.weight.string = $0
            }
        )
        
        return TextField("weight", text: binding)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .font(.title2)
            .focused($focusedField, equals: .weight)
//            .introspectTextField { uiTextfield in
//                introspectTextField(uiTextfield, for: .weight)
//            }
    }
    
    func introspectTextField(_ uiTextField: UITextField, for field: FocusedField) {
        guard ((field == .weight && weightFirst) || (field == .volume && !weightFirst)),
              !hasBecomeFirstResponder else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
        }
    }
    
    var weightUnitButton: some View {
        Button {
            showingWeightUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(densityViewModel.fieldValue.weight.unitDescription)
//                    Image(systemName: "chevron.up.chevron.down")
//                        .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    //MARK: - Volume
     
    var volumeTextField: some View {
        let binding = Binding<String>(
            get: { densityViewModel.fieldValue.volume.string },
            set: {
                if !doNotRegisterUserInput, focusedField == .volume, $0 != densityViewModel.fieldValue.volume.string {
                    withAnimation {
                        densityViewModel.registerUserInput()
                    }
                }
                densityViewModel.fieldValue.volume.string = $0
            }
        )
        
        return TextField("volume", text: binding)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .font(.title2)
            .focused($focusedField, equals: .volume)
//            .introspectTextField { uiTextfield in
//                introspectTextField(uiTextfield, for: .volume)
//            }
    }
    
    var volumeUnitButton: some View {
        Button {
            showingVolumeUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(densityViewModel.fieldValue.volume.unitDescription)
//                    Image(systemName: "chevron.up.chevron.down")
//                        .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    

    var volumeSection: some View {
        FormStyledSection(header: Text("Volume")) {
            volumeStack
        }
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button {
                Haptics.feedback(style: .soft)
                focusedField = weightFirst ? .weight : .volume
            } label: {
                Image(systemName: "chevron.backward")
            }
            .disabled(topFieldIsFocused)
            Button {
                Haptics.feedback(style: .soft)
                focusedField = weightFirst ? .volume : .weight
            } label: {
                Image(systemName: "chevron.forward")
            }
            .disabled(bottomFieldIsFocused)
            Button("Units") {
                Haptics.feedback(style: .medium)
                guard let focusedField = focusedField else {
                    return
                }
                if focusedField == .weight {
                    showingWeightUnitPicker = true
                } else {
                    showingVolumeUnitPicker = true
                }
            }
            Spacer()
            Button("Save") {
                Haptics.successFeedback()
                saveAndDismiss()
            }
        }
    }
    
    var topFieldIsFocused: Bool {
        if weightFirst {
            return focusedField == .weight
        } else {
            return focusedField == .volume
        }
    }

    var bottomFieldIsFocused: Bool {
        if weightFirst {
            return focusedField == .volume
        } else {
            return focusedField == .weight
        }
    }

    var navigationTitle: String {
        return "Unit Conversion"
//        if orderWeightFirst {
//            return "Weight:Volume"
////            return "Weight-to-Volume Ratio"
//        } else {
//            return "Volume:Weight"
////            return "Volume-to-Weight Ratio"
//        }
    }
}

struct DensityFormPreview: View {
    @StateObject var viewModel: FoodFormViewModel
    
    init() {
        let viewModel = FoodFormViewModel.shared
        viewModel.densityViewModel.fieldValue = FieldValue.density(FieldValue.DensityValue(
            weight: FieldValue.DoubleValue(double: 33, string: "33", unit: .weight(.g), fill: .userInput),
            volume: FieldValue.DoubleValue(double: 0.25, string: "0.25", unit: .volume(.cup), fill: .userInput),
            fill: .userInput))
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        DensityForm(
            densityViewModel: viewModel.densityViewModel,
            orderWeightFirst: viewModel.isWeightBased
        )
        .environmentObject(viewModel)
    }
}

struct DensityForm_Previews: PreviewProvider {
    static var previews: some View {
        DensityFormPreview()
    }
}

import PrepUnits

extension RecognizedText {
    var densityValue: FieldValue.DensityValue? {
        string.detectedValues.densityValue
    }
}

extension Array where Element == FoodLabelValue {
    var firstWeightValue: FoodLabelValue? {
        first(where: { $0.unit?.unitType == .weight })
    }
    
    var firstVolumeValue: FoodLabelValue? {
        first(where: { $0.unit?.unitType == .volume })
    }

    var densityValue: FieldValue.DensityValue? {
        guard let weightDoubleValue, let volumeDoubleValue else {
            return nil
        }
        return FieldValue.DensityValue(
            weight: weightDoubleValue,
            volume: volumeDoubleValue,
            fill: .userInput
        )
    }
    
    var weightDoubleValue: FieldValue.DoubleValue? {
        firstWeightValue?.asDoubleValue
    }
    var volumeDoubleValue: FieldValue.DoubleValue? {
        firstVolumeValue?.asDoubleValue
    }
}

extension FoodLabelValue {
    var asDoubleValue: FieldValue.DoubleValue? {
        guard let formUnit = unit?.formUnit else { return nil }
        return FieldValue.DoubleValue(
            double: amount,
            string: amount.cleanAmount,
            unit: formUnit,
            fill: .userInput
        )
    }
}
