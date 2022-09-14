import SwiftUI
import PrepUnits
import SwiftHaptics

struct UnitPicker: View {
    
    @Environment(\.dismiss) var dismiss
    @State var type: UnitType
    @State var pickedUnit: FormUnit

    var includeServing: Bool
    var filteredType: UnitType?
    var didPickUnit: (FormUnit) -> ()

    @State private var date = Date.now
    @State private var datePickerShown = false
    @State private var weightsExpanded: Bool
    @State private var volumesExpanded: Bool
    @State private var sizesExpanded: Bool

    init(pickedUnit: FormUnit = .weight(.g), includeServing: Bool = true, filteredType: UnitType? = nil, didPickUnit: @escaping (FormUnit) -> ())
    {
        self.didPickUnit = didPickUnit
        self.includeServing = includeServing
        self.filteredType = filteredType
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
        list
            .onChange(of: pickedUnit) { newValue in
                pickedUnitChanged(to: newValue)
            }
            .onChange(of: type) { newValue in
                if type == .serving {
                    pickedUnit(unit: .serving)
                }
            }
            .navigationTitle(navigationTitleString)
    }
    
    var navigationTitleString: String {
        let name: String
        if let filteredType = filteredType {
            name = filteredType.description.lowercased()
        } else {
            name = "unit"
        }
        return "Pick a \(name)"
    }
    
    //MARK: - Components
    
    var list: some View {
        List {
            if let filteredType = filteredType {
                singleGroup(for: filteredType)
            } else {
                sectionedListContents
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
    
    var sectionedListContents: some View {
        Group {
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
    }
    
    @ViewBuilder
    func singleGroup(for type: UnitType) -> some View {
        switch type {
        case .weight:
            weightsGroupContents
        case .volume:
            volumesGroupContents
        case .serving:
            EmptyView()
        case .size:
            sizesGroupContents
        }
    }
    
    //MARK: - Groups
    
    var weightsGroup: some View {
        DisclosureGroup(isExpanded: $weightsExpanded) {
            weightsGroupContents
        } label: {
            Text("Weights")
                .foregroundColor(weightsExpanded ? Color(.tertiaryLabel) : .primary)
        }
    }
    
    var volumesGroup: some View {
        DisclosureGroup(isExpanded: $volumesExpanded) {
            volumesGroupContents
        } label: {
            Text("Volumes")
                .foregroundColor(volumesExpanded ? Color(.tertiaryLabel) : .primary)
        }
    }
    
    var sizesGroup: some View {
        DisclosureGroup(isExpanded: $sizesExpanded) {
            sizesGroupContents
        } label: {
            Text("Sizes")
                .foregroundColor(sizesExpanded ? Color(.tertiaryLabel) : .primary)
        }
    }
    
    //MARK: - Group Contents
    var weightsGroupContents: some View {
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
    
    var volumesGroupContents: some View {
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
    }
    
    var sizesGroupContents: some View {
        addSizeButton
    }
    
    //MARK: - Buttons
    
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
    
    //MARK: - Units
    
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
                .navigationBarTitleDisplayMode(.inline)
        }
//        .toolbarBackground(Color.green, for: .navigationBar)
    }
}

