import SwiftUI
import PrepUnits
import SwiftHaptics

struct UnitSelector: View {
    
    @Environment(\.dismiss) var dismiss
    @State var type: UnitType
    @State var pickedUnit: FormUnit
    
    var delegate: UnitSelectorDelegate
    var includeServing: Bool

    init(pickedUnit: FormUnit = .weight(.g), includeServing: Bool = true, delegate: UnitSelectorDelegate) {
        self.delegate = delegate
        self.includeServing = includeServing
        _pickedUnit = State(initialValue: pickedUnit)
        _type = State(initialValue: pickedUnit.unitType)
    }
}

protocol UnitSelectorDelegate {
    func didPickUnit(unit: FormUnit)
}

extension UnitSelector {
    
    var body: some View {
        VStack {
            typePicker
                .padding(.horizontal)
            list
        }
        .onChange(of: pickedUnit) { newValue in
            pickedUnitChanged(to: newValue)
        }
        .onChange(of: type) { newValue in
            if type == .serving {
                pickedUnit(unit: .serving)
            }
        }
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
    
    
    func pickedUnitChanged(to newUnit: FormUnit) {
        delegate.didPickUnit(unit: newUnit)
        Haptics.feedback(style: .heavy)
//        dismiss()
    }
    
    var bottomBarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            typePicker
        }
    }
    
    var unitTypes: [UnitType] {
        guard includeServing else {
            return UnitType.allCases.filter({ $0 != .serving })
        }
        return UnitType.allCases
    }
    
    var typePicker: some View {
        Picker("", selection: $type) {
            ForEach(unitTypes, id: \.self) { type in
                Text(type.description).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
    
    func pickedUnit(unit: FormUnit) {
        self.pickedUnit = unit
//        if unit == .serving {
//            dismiss()
//        }
    }
    
    var weightUnits: [WeightUnit] {
        [.g, .oz, .mg, .lb, .kg]
    }

    var volumeUnits: [VolumeUnit] {
        [.cup, .mL, .fluidOunce, .teaspoon, .tablespoon, .liter, .pint, .quart, .gallon]
    }

    var weightsList: some View {
        List {
            ForEach(weightUnits, id: \.self) { weightUnit in
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
            ForEach(volumeUnits, id: \.self) { volumeUnit in
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
                HStack {
                    Text("Add a size")
                    Spacer()
                }
            }
            .buttonStyle(.borderless)
            .contentShape(Rectangle())
        }
    }
}


public struct UnitSelectorPreview: View {
    
    @StateObject var viewModel = SizeForm.ViewModel()
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            UnitSelector(delegate: viewModel)
                .navigationTitle("Pick a Unit")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UnitSelector_Previews: PreviewProvider {
    static var previews: some View {
        UnitSelectorPreview()
    }
}

