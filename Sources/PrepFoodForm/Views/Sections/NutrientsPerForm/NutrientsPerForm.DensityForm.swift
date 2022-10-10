import SwiftUI
import SwiftUISugar

extension FoodForm.NutrientsPerForm {
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
        @State var doNotRegisterUserInput: Bool
        @FocusState var focusedField: FocusedField?
        
        let weightFirst: Bool
        
        init(densityViewModel: FieldViewModel, orderWeightFirst: Bool) {
            
            self.existingDensityViewModel = densityViewModel
            _densityViewModel = StateObject(wrappedValue: densityViewModel)
            
            self.weightFirst = orderWeightFirst
//            _doNotRegisterUserInput = State(initialValue: !densityViewModel.fieldValue.isEmpty)
            _doNotRegisterUserInput = State(initialValue: true)
        }
    }
}

extension FoodForm.NutrientsPerForm.DensityForm {
    
    var body: some View {
        form
        .navigationTitle(navigationTitle)
        .toolbar { keyboardToolbarContents }
        .onAppear {
//            focusedField = orderWeightFirst ? .weight : .volume
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                print("🔥")
                shouldAnimateOptions = true
                
                /// Wait a while before unlocking the `doNotRegisterUserInput` flag in case it was set (due to a value already being present)
                doNotRegisterUserInput = false
            }
        }
    }
    
    var form: some View {
        FormStyledScrollView {
            if weightFirst {
                weightSection
                volumeSection
            } else {
                volumeSection
                weightSection
            }
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
    
    var fillOptionsSections: some View {
        FillOptionsSections(
            fieldViewModel: densityViewModel,
            shouldAnimate: $shouldAnimateOptions,
            didTapImage: didTapImage,
            didTapFillOption: didTapFillOption
        )
    }
    
    func didTapImage() {
        
    }
    
    func didTapFillOption(_ fillOption: FillOption) {
        //TODO: Prefill info should have DensityValue associated with it
        print("We tapped: \(fillOption)")
    }
    
    func saveAndDismiss() {
        doNotRegisterUserInput = true
        existingDensityViewModel.copyData(from: densityViewModel)
        dismiss()
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
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($focusedField, equals: .weight)
    }
    var weightSection: some View {
        FormStyledSection(header: Text("Weight")) {
            HStack {
                weightTextField
                Button {
                    showingWeightUnitPicker = true
                } label: {
                    HStack(spacing: 5) {
                        Text(densityViewModel.fieldValue.weight.unitDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
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
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($focusedField, equals: .volume)
    }
    var volumeSection: some View {
        FormStyledSection(header: Text("Volume")) {
            HStack {
                volumeTextField
                Button {
                    showingVolumeUnitPicker = true
                } label: {
                    HStack(spacing: 5) {
                        Text(densityViewModel.fieldValue.volume.unitDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button {
                focusedField = weightFirst ? .weight : .volume
            } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(topFieldIsFocused)
            Button {
                focusedField = weightFirst ? .volume : .weight
            } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(bottomFieldIsFocused)
            Button("Units") {
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
        return "Conversion"
//        if orderWeightFirst {
//            return "Weight:Volume"
////            return "Weight-to-Volume Ratio"
//        } else {
//            return "Volume:Weight"
////            return "Volume-to-Weight Ratio"
//        }
    }
}
