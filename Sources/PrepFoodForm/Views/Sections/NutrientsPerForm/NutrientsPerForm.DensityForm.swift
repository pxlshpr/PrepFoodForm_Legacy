import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct DensityForm: View {
        
        @EnvironmentObject var viewModel: FoodForm.ViewModel
        
        @State var showingWeightUnitPicker = false
        @State var showingVolumeUnitPicker = false
        
        let orderWeightFirst: Bool
        
        init(orderWeightFirst: Bool = true) {
            self.orderWeightFirst = orderWeightFirst
        }
    }
}

extension FoodForm.NutrientsPerForm.DensityForm {
    
    var body: some View {
        form
        .navigationTitle("Weight-to-Volume Ratio")
    }
    
    var navigationTitle: String {
        if orderWeightFirst {
            return "Weight-to-Volume Ratio"
        } else {
            return "Volume-to-Weight Ratio"
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
        }
        .sheet(isPresented: $showingVolumeUnitPicker) {
            UnitPicker(
                pickedUnit: viewModel.densityVolumeUnit,
                filteredType: .volume)
            { unit in
                viewModel.densityVolumeUnit = unit
            }
        }
    }
    
    var weightSection: some View {
        Section("Weight") {
            HStack {
                TextField("Required", text: $viewModel.densityWeightString)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
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
