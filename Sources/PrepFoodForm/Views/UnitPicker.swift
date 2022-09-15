import SwiftUI
import PrepUnits
import SwiftHaptics

struct UnitPicker: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var path: [Route] = []
    
    @State var type: UnitType
    @State var pickedUnit: FormUnit

    @State var pickedVolumePrefixUnit: FormUnit = .volume(.cup)
    
    var sizes: [Size]
    var includeServing: Bool
    var allowAddSize: Bool
    var filteredType: UnitType?
    var didPickUnit: (FormUnit) -> ()
    var didTapAddSize: (() -> ())?

    init(sizes: [Size] = [], pickedUnit unit: FormUnit = .weight(.g), includeServing: Bool = true, allowAddSize: Bool = true, filteredType: UnitType? = nil, didTapAddSize: (() -> ())? = nil, didPickUnit: @escaping (FormUnit) -> ())
    {
        self.sizes = sizes
        self.didPickUnit = didPickUnit
        self.didTapAddSize = didTapAddSize
        self.includeServing = includeServing
        self.allowAddSize = allowAddSize
        self.filteredType = filteredType
        
        _pickedUnit = State(initialValue: unit)
        _type = State(initialValue: unit.unitType)
    }
    
    enum Route: Hashable {
        case weights
        case volumes
        case sizes
        case volumePrefixes(Size)
    }
}

extension UnitPicker {
    
    var body: some View {
        NavigationStack(path: $path) {
            finalList
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                navigationDestination(for: route)
            }
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
    
    @ViewBuilder
    func navigationDestination(for route: Route) -> some View {
        switch route {
        case .weights:
            weightsList
        case .volumes:
            volumesList
        case .sizes:
            sizesList
        case .volumePrefixes(let size):
            List {
                volumePrefixes(for: size)
            }
            .navigationTitle("\(size.name.capitalizingFirstLetter()) Volumes")
        }
    }
    
    var weightsList: some View {
        List {
            weightsGroupContents
        }
        .navigationTitle("Weights")
    }
    
    var volumesList: some View {
        List {
            volumesGroupContents
        }
        .navigationTitle("Volumes")
    }
    
    var sizesList: some View {
        List {
            sizesGroupContents
        }
        .navigationTitle("Sizes")
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
    
    var finalList: some View {
        List {
            if let filteredType = filteredType {
                Section {
                    filteredList(for: filteredType)
                }
            } else {
                Section {
                    if shouldShowServing {
                        servingButton
                    }
                    weightUnitButton(for: .g)
                    volumeUnitButton(for: .mL)
                }
                Section("Other Units") {
                    NavigationLinkButton {
                        path.append(.weights)
                    } label: {
                        Text("Weights")
                            .foregroundColor(.primary)
                    }
                    NavigationLinkButton {
                        path.append(.volumes)
                    } label: {
                        Text("Volumes")
                            .foregroundColor(.primary)
                    }
                    if allowAddSize || !sizes.isEmpty {
                        NavigationLinkButton {
                            path.append(.sizes)
                        } label: {
                            Text("Sizes")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
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
            name = filteredType.description.lowercased()
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
    }
    
    var standardSizeViewModels: [SizeViewModel] {
        sizes.filter({ !$0.isVolumePrefixed }).map { SizeViewModel(size: $0) }
    }
    var volumePrefixedSizeViewModels: [SizeViewModel] {
        sizes.filter({ $0.isVolumePrefixed }).map { SizeViewModel(size: $0) }
    }

    var sizesGroupContents: some View {
        Group {
            if !standardSizeViewModels.isEmpty {
                Section {
                    ForEach(standardSizeViewModels, id: \.self) { sizeViewModel in
                        Button {
                            pickedUnit(unit: .size(sizeViewModel.size, nil))
                        } label: {
                            HStack {
                                Text(sizeViewModel.nameString)
                                    .foregroundColor(.primary)
                                Spacer()
                                HStack {
                                    Text(sizeViewModel.scaledAmountString)
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            if !volumePrefixedSizeViewModels.isEmpty {
                Section("Volume prefixed") {
                    ForEach(volumePrefixedSizeViewModels, id: \.self) { sizeViewModel in
                        NavigationLinkButton {
                            path.append(.volumePrefixes(sizeViewModel.size))
                        } label: {
                            HStack {
                                Text(sizeViewModel.nameString)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
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
            sizes: (mockStandardSizes + mockVolumePrefixedSizes),
            pickedUnit: pickedUnit
        ) { pickedUnit in
            
        }
    }
}

struct NewUnitPicker_Previews: PreviewProvider {
    static var previews: some View {
        NewUnitPickerPreview()
            .preferredColorScheme(.dark)
    }
}

