import SwiftUI
import PrepUnits
import SwiftHaptics

struct UnitPicker: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var type: UnitType
    @State var pickedUnit: FormUnit

    @State var pickedVolumePrefixUnit: FormUnit = .volume(.cup)
    
    var includeServing: Bool
    var allowAddSize: Bool
    var filteredType: UnitType?
    var servingDescription: String?
    
    var didPickUnit: (FormUnit) -> ()
    var didTapAddSize: (() -> ())?

    init(
        pickedUnit unit: FormUnit = .weight(.g),
        includeServing: Bool = true,
        servingDescription: String? = nil,
        allowAddSize: Bool = true,
        filteredType: UnitType? = nil,
        didTapAddSize: (() -> ())? = nil,
        didPickUnit: @escaping (FormUnit) -> ())
    {
        self.didPickUnit = didPickUnit
        self.didTapAddSize = didTapAddSize
        self.includeServing = includeServing
        self.servingDescription = servingDescription
        self.allowAddSize = allowAddSize
        self.filteredType = filteredType
        
        _pickedUnit = State(initialValue: unit)
        _type = State(initialValue: unit.unitType)
    }
}

extension UnitPicker {
    
    var body: some View {
        NavigationView {
            longList
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: pickedUnit) { newValue in
            pickedUnitChanged(to: newValue)
        }
        .onChange(of: type) { newValue in
            if type == .serving {
                pickedUnit(unit: .serving)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    //MARK: - Components
    
    var shouldShowAddSizeButton: Bool {
        allowAddSize && viewModel.standardSizeViewModels.isEmpty && viewModel.volumePrefixedSizeViewModels.isEmpty
    }
    
    var longList: some View {
        List {
            if let filteredType = filteredType {
                Section {
                    filteredList(for: filteredType)
                }
            } else {
                if !viewModel.standardSizeViewModels.isEmpty {
                    Section("Sizes") {
                        standardSizeContents
                    }
                }
                if !viewModel.volumePrefixedSizeViewModels.isEmpty {
                    Section("Volume Prefixed Sizes") {
                        volumePrefixedSizeContents
                    }
                }
                if shouldShowAddSizeButton {
                    Section {
                        addSizeButton
                    }
                }
                if shouldShowServing {
                    Section {
                        servingButton
                    }
                }
                Section {
                    weightUnitButton(for: .g)
                    volumeUnitButton(for: .mL)
                }
                Section("Other Units") {
                    DisclosureGroup("Weights") {
                        weightsGroupContents
                    }
                    DisclosureGroup("Volumes") {
                        volumesGroupContents
                    }
                }
            }
        }
    }
    
    var shouldShowServing: Bool {
        includeServing && filteredType == nil
    }
    
    @ViewBuilder
    func filteredList(for type: UnitType) -> some View {
        switch type {
        case .weight:
            weightsGroupContents
        case .volume:
            volumesGroupContents
        case .size:
            sizesGroupContents
        default:
            EmptyView()
        }
    }
    
    //MARK: - Components
    
    var typesWithOptions: [UnitType] {
        [UnitType.weight, UnitType.volume, UnitType.size]
    }
    
    var typePicker: some View {
        Picker("", selection: $type) {
            ForEach(typesWithOptions, id: \.self) {
                Text($0.description).tag($0)
            }
        }
    }
    
    var navigationTitleString: String {
        let name: String
        if let filteredType = filteredType {
            name = filteredType.description.lowercased() + " unit"
        } else {
            name = "unit"
        }
        return "Choose a \(name)"
    }
    
    func weightUnitButton(for weightUnit: WeightUnit) -> some View {
        Button {
            pickedUnit(unit: .weight(weightUnit))
        } label: {
            HStack {
                Text(weightUnit.description)
                    .textCase(.lowercase)
                    .foregroundColor(.primary)
                Spacer()
                Text(weightUnit.shortDescription)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.borderless)
    }
    
    func volumeUnitButton(for volumeUnit: VolumeUnit) -> some View {
        Button {
            pickedUnit(unit: .volume(volumeUnit))
        } label: {
            HStack {
                Text(volumeUnit.description)
                    .textCase(.lowercase)
                    .foregroundColor(.primary)
                Spacer()
                Text(volumeUnit.shortDescription)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.borderless)
    }
    
    //MARK: - Group Contents
    var weightsGroupContents: some View {
        ForEach(weightUnits, id: \.self) { weightUnit in
            weightUnitButton(for: weightUnit)
        }
    }
    
    var volumesGroupContents: some View {
        ForEach(volumeUnits, id: \.self) { volumeUnit in
            volumeUnitButton(for: volumeUnit)
        }
    }
    
    func volumePrefixes(for size: Size) -> some View {
        ForEach(volumeUnits, id: \.self) { volumeUnit in
            Button {
                pickedUnit(unit: .size(size, volumeUnit))
            } label: {
                HStack {
                    HStack(spacing: 0) {
                        Text(volumeUnit.description)
                            .textCase(.lowercase)
                            .foregroundColor(.primary)
                        Text(", ")
                            .foregroundColor(Color(.tertiaryLabel))
                        Text(size.name)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    Spacer()
                    Text(volumeUnit.shortDescription)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.borderless)
        }
    }
    
//    var standardSizeViewModels: [SizeViewModel] {
//        sizes.filter({ !$0.isVolumePrefixed }).map { SizeViewModel(size: $0) }
//    }
//    var volumePrefixedSizeViewModels: [SizeViewModel] {
//        sizes.filter({ $0.isVolumePrefixed }).map { SizeViewModel(size: $0) }
//    }

    var standardSizeContents: some View {
        ForEach(viewModel.standardSizeViewModels, id: \.self) { sizeViewModel in
            sizeButton(for: sizeViewModel)
        }
    }
    
    @ViewBuilder
    func sizeButton(for sizeViewModel: FieldValueViewModel) -> some View {
        if let size = sizeViewModel.size {
            Button {
                pickedUnit(unit: .size(size, nil))
            } label: {
                HStack {
                    Text(size.name)
                        .foregroundColor(.primary)
                    Spacer()
                    HStack {
                        Text(size.scaledAmountString)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
            .buttonStyle(.borderless)
        }
    }
    
    var volumePrefixedSizeContents: some View {
        ForEach(viewModel.volumePrefixedSizeViewModels, id: \.self) { sizeViewModel in
            volumePrefixedSizeGroup(for: sizeViewModel)
        }
    }
    
    @ViewBuilder
    func volumePrefixedSizeGroup(for sizeViewModel: FieldValueViewModel) -> some View {
        if let size = sizeViewModel.size {
            DisclosureGroup(size.name) {
                volumePrefixes(for: size)
            }
        }
    }
    
    var sizesGroupContents: some View {
        Group {
            if !viewModel.standardSizeViewModels.isEmpty {
                Section {
                    standardSizeContents
                }
            }
            if !viewModel.volumePrefixedSizeViewModels.isEmpty {
                Section("Volume-prefixed") {
                    volumePrefixedSizeContents
                }
            }
            if allowAddSize {
                Section {
                    addSizeButton
                }
            }
        }
    }

    //MARK: - Buttons
    
    var addSizeButton: some View {
        Button {
            didTapAddSize?()
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
                    .textCase(.lowercase)
                    .foregroundColor(.primary)
                Spacer()
                if let servingDescription = servingDescription {
                    Text(servingDescription)
                        .foregroundColor(Color(.secondaryLabel))
                }
//                if case .serving = pickedUnit {
//                    Image(systemName: "checkmark")
//                        .foregroundColor(.accentColor)
//                }
            }
        }
        .buttonStyle(.borderless)
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
//        didPickUnit(newUnit)
//        Haptics.feedback(style: .heavy)
//        dismiss()
    }
    
    func pickedUnit(unit: FormUnit) {
//        self.pickedUnit = unit
        didPickUnit(unit)
        Haptics.feedback(style: .heavy)
        dismiss()
    }
}

public struct NewUnitPickerPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel.shared
    @State var showingUnitPicker = false
    
//    @State var pickedUnit: FormUnit = .weight(.g)
    @State var pickedUnit: FormUnit = .size(mockVolumePrefixedSizes.first!, .cup)
    
    public init() { }
    
    public var body: some View {
        Button("Pick Unit") {
            showingUnitPicker = true
        }
        .sheet(isPresented: $showingUnitPicker) {
            unitPicker
                .preferredColorScheme(.dark)
        }
    }
    
    var unitPicker: some View {
        UnitPicker(
            pickedUnit: pickedUnit
        ) { pickedUnit in
            
        }
        .environmentObject(viewModel)
    }
}

struct NewUnitPicker_Previews: PreviewProvider {
    static var previews: some View {
        NewUnitPickerPreview()
            .preferredColorScheme(.dark)
    }
}

