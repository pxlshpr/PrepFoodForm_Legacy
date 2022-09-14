import SwiftUI
import PrepUnits
import SwiftHaptics

struct UnitPicker: View {
    
    @Environment(\.dismiss) var dismiss
    @State var type: UnitType
    @State var pickedUnit: FormUnit
    
    @State private var date = Date.now
    @State private var datePickerShown = false
    
    var includeServing: Bool

    @State private var weightsExpanded: Bool
    @State private var volumesExpanded: Bool
    @State private var sizesExpanded: Bool

    var didPickUnit: (FormUnit) -> ()
    init(pickedUnit: FormUnit = .weight(.g), includeServing: Bool = true, didPickUnit: @escaping (FormUnit) -> ()) {
        self.didPickUnit = didPickUnit
        self.includeServing = includeServing
        _pickedUnit = State(initialValue: pickedUnit)
        _type = State(initialValue: pickedUnit.unitType)
        
        switch pickedUnit {
        case .weight:
            _weightsExpanded = State(initialValue: true)
            _volumesExpanded = State(initialValue: false)
            _sizesExpanded = State(initialValue: false)
        case .volume:
            _weightsExpanded = State(initialValue: false)
            _volumesExpanded = State(initialValue: true)
            _sizesExpanded = State(initialValue: false)
        case .size:
            _weightsExpanded = State(initialValue: false)
            _volumesExpanded = State(initialValue: false)
            _sizesExpanded = State(initialValue: true)
        case .serving:
            _weightsExpanded = State(initialValue: false)
            _volumesExpanded = State(initialValue: false)
            _sizesExpanded = State(initialValue: false)
        }
    }
}

extension UnitPicker {
    
    var body: some View {
        newList
            .onChange(of: pickedUnit) { newValue in
                pickedUnitChanged(to: newValue)
            }
            .onChange(of: type) { newValue in
                if type == .serving {
                    pickedUnit(unit: .serving)
                }
            }
    }
    
    var newList: some View {
        List {
            if includeServing {
                Section {
                    servingButton
                }
            }
            Section {
                weightsGroup
                volumesGroup
                sizesGroup
            }
        }
        .onChange(of: weightsExpanded) { newValue in
            guard newValue else { return }
            withAnimation {
                volumesExpanded = false
                sizesExpanded = false
            }
        }
        .onChange(of: volumesExpanded) { newValue in
            guard newValue else { return }
            withAnimation {
                weightsExpanded = false
                sizesExpanded = false
            }
        }
        .onChange(of: sizesExpanded) { newValue in
            guard newValue else { return }
            withAnimation {
                weightsExpanded = false
                volumesExpanded = false
            }
        }
    }
    
    var weightsGroup: some View {
        DisclosureGroup(isExpanded: $weightsExpanded) {
            ForEach(weightUnits, id: \.self) { weightUnit in
                Button {
                    pickedUnit(unit: .weight(weightUnit))
                } label: {
                    HStack {
//                        HStack {
//                            Text("\(weightUnit.description) • \(weightUnit.shortDescription)")
//                                .textCase(.lowercase)
//                        }
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
        } label: {
            Text("Weights")
                .foregroundColor(weightsExpanded ? Color(.tertiaryLabel) : .primary)
        }
    }
    
    var volumesGroup: some View {
        DisclosureGroup(isExpanded: $volumesExpanded) {
            ForEach(volumeUnits, id: \.self) { volumeUnit in
                Button {
                    pickedUnit(unit: .volume(volumeUnit))
                } label: {
                    HStack {
//                        HStack {
//                            Text("\(volumeUnit.description) • \(volumeUnit.shortDescription)")
//                                .textCase(.lowercase)
//                        }
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
        } label: {
            Text("Volumes")
                .foregroundColor(volumesExpanded ? Color(.tertiaryLabel) : .primary)
        }
    }
    
    var sizesGroup: some View {
        DisclosureGroup(isExpanded: $sizesExpanded) {
            addSizeButton
        } label: {
            Text("Sizes")
                .foregroundColor(sizesExpanded ? Color(.tertiaryLabel) : .primary)
        }
    }
    
    var addSizeButton: some View {
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
    
    var servingButton: some View {
        Button {
            pickedUnit(unit: .serving)
        } label: {
            HStack {
                Text("Serving")
//                    .textCase(.lowercase)
                    .foregroundColor(.primary)
                Spacer()
                if case .serving = pickedUnit {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    var weightUnits: [WeightUnit] {
        [.g, .oz, .mg, .lb, .kg]
    }

    var volumeUnits: [VolumeUnit] {
        [.cup, .mL, .fluidOunce, .teaspoon, .tablespoon, .liter, .pint, .quart, .gallon]
    }
    
    //MARK: - Actions
    func pickedUnitChanged(to newUnit: FormUnit) {
        didPickUnit(newUnit)
        Haptics.feedback(style: .heavy)
        dismiss()
    }
    
    func pickedUnit(unit: FormUnit) {
        self.pickedUnit = unit
//        if unit == .serving {
//            dismiss()
//        }
    }
}

public struct UnitSelectorPreview: View {
    
    public init() { }
    
    public var body: some View {
        UnitPicker { pickedUnit in
            
        }
    }
}

struct UnitSelector_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UnitSelectorPreview()
                .navigationTitle("Pick a unit")
                .navigationBarTitleDisplayMode(.inline)
        }
//        .toolbarBackground(Color.green, for: .navigationBar)
    }
}

