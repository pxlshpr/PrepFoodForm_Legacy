import SwiftUI
import PrepUnits
import SwiftHaptics

extension FoodForm.ServingForm {
    struct UnitSelector: View {
        
        @Environment(\.dismiss) var dismiss
        @ObservedObject var viewModel: FoodForm.ViewModel
        @State var type: UnitType
        @State var pickedUnit: AmountUnit
        
        init(viewModel: FoodForm.ViewModel) {
            self.viewModel = viewModel
            _pickedUnit = State(initialValue: viewModel.amountUnit)
            _type = State(initialValue: viewModel.amountUnit.unitType)
        }
        
    }
}

extension FoodForm.ServingForm.UnitSelector {
    
    var body: some View {
        NavigationView {
            list
//            .navigationTitle("Pick a unit")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar { bottomBarContent }
        }
        .onChange(of: pickedUnit) { newValue in
            pickedUnitChanged(to: newValue)
        }
    }
    
    func pickedUnitChanged(to newUnit: AmountUnit) {
        withAnimation {
            viewModel.amountUnit = newUnit
        }
        Haptics.feedback(style: .heavy)
        dismiss()
    }
    
    var bottomBarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            typePicker
        }
    }
    
    var typePicker: some View {
        Picker("", selection: $type) {
            ForEach(UnitType.allCases, id: \.self) { type in
                Text(type.description).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
    
    @ViewBuilder
    var list: some View {
        switch type {
        case .weight:
            weightsList
        case .volume:
            volumesList
        case .serving:
            servingList
        case .size:
            sizesList
        }
    }
    
    func pickedUnit(unit: AmountUnit) {
        self.pickedUnit = unit
    }
    
    var weightsList: some View {
        List {
            ForEach(WeightUnit.allCases, id: \.self) { weightUnit in
                Button {
                    pickedUnit(unit: .weight(weightUnit))
                } label: {
                    HStack {
                        HStack {
                            Text(weightUnit.description)
                                .textCase(.lowercase)
                                .foregroundColor(.primary)
                            Text("•")
                                .foregroundColor(Color(.quaternaryLabel))
                            Text(weightUnit.shortDescription)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if case .weight(let pickedWeightUnit) = pickedUnit, pickedWeightUnit == weightUnit {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    var volumesList: some View {
        List {
            ForEach(VolumeUnit.allCases, id: \.self) { volumeUnit in
                Button {
                    pickedUnit(unit: .volume(volumeUnit))
                } label: {
                    HStack {
                        HStack {
                            Text(volumeUnit.description)
                                .textCase(.lowercase)
                                .foregroundColor(.primary)
                            Text("•")
                                .foregroundColor(Color(.quaternaryLabel))
                            Text(volumeUnit.shortDescription)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if case .volume(let pickedVolumeUnit) = pickedUnit, pickedVolumeUnit == volumeUnit {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    var servingList: some View {
        List {
            Button {
                pickedUnit(unit: .serving)
            } label: {
                HStack {
                    Text("Serving")
                        .textCase(.lowercase)
                        .foregroundColor(.primary)
                    Spacer()
                    if case .serving = pickedUnit {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }

    var sizesList: some View {
        List {
            Button {
                
            } label: {
                Text("Add a size")
            }
            .buttonStyle(.borderless)
        }
    }
}
