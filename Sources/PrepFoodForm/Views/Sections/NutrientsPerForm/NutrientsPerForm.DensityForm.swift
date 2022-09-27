import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct DensityForm: View {
        
        enum FocusedField {
            case weight, volume
        }
        
        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingWeightUnitPicker = false
        @State var showingVolumeUnitPicker = false
        
        @FocusState var focusedField: FocusedField?
        
        let orderWeightFirst: Bool
        
        init(orderWeightFirst: Bool = true) {
            self.orderWeightFirst = orderWeightFirst
        }
    }
}

extension FoodForm.NutrientsPerForm.DensityForm {
    
    var body: some View {
        form
        .navigationTitle(navigationTitle)
        .toolbar { keyboardToolbarContents }
        .onAppear {
            focusedField = orderWeightFirst ? .weight : .volume
        }
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
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
            Button {
                focusedField = orderWeightFirst ? .weight : .volume
            } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(topFieldIsFocused)
            Button {
                focusedField = orderWeightFirst ? .volume : .weight
            } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(bottomFieldIsFocused)
        }
    }
    
    var topFieldIsFocused: Bool {
        if orderWeightFirst {
            return focusedField == .weight
        } else {
            return focusedField == .volume
        }
    }

    var bottomFieldIsFocused: Bool {
        if orderWeightFirst {
            return focusedField == .volume
        } else {
            return focusedField == .weight
        }
    }

    var navigationTitle: String {
        if orderWeightFirst {
            return "Weight:Volume"
//            return "Weight-to-Volume Ratio"
        } else {
            return "Volume:Weight"
//            return "Volume-to-Weight Ratio"
        }
    }
    
    var form: some View {
        Form {
            if orderWeightFirst {
                weightSection
                volumeSection
            } else {
                volumeSection
                weightSection
            }
        }
        .sheet(isPresented: $showingWeightUnitPicker) {
            UnitPicker(
                pickedUnit: viewModel.densityWeightUnit,
                filteredType: .weight)
            { unit in
                viewModel.densityWeightUnit = unit
            }
            .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingVolumeUnitPicker) {
            UnitPicker(
                pickedUnit: viewModel.densityVolumeUnit,
                filteredType: .volume)
            { unit in
                viewModel.densityVolumeUnit = unit
            }
            .environmentObject(viewModel)
        }
    }
    
    var weightSection: some View {
        Section("Weight") {
            HStack {
                TextField("Required", text: $viewModel.densityWeightString)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                Button {
                    showingWeightUnitPicker = true
                } label: {
                    HStack(spacing: 5) {
                        Text(viewModel.densityWeightUnit.shortDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    var volumeSection: some View {
        Section("Volume") {
            HStack {
                TextField("Required", text: $viewModel.densityVolumeString)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .volume)
                Button {
                    showingVolumeUnitPicker = true
                } label: {
                    HStack(spacing: 5) {
                        Text(viewModel.densityVolumeUnit.shortDescription)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
