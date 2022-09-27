import SwiftUI
import NamePicker

extension SizeForm {
    struct SizeField: View {
        @EnvironmentObject var sizeFormViewModel: SizeForm.ViewModel
        
        @State var showingUnitPickerForVolumePrefix = false
    }
}

extension SizeForm.SizeField {
    
    var body: some View {
        content
        .navigationDestination(for: SizeForm.Route.self) {
            switch $0 {
            case .name:
                namePicker
            case .quantity:
                QuantityForm()
                    .environmentObject(sizeFormViewModel)
            case .amount:
                AmountForm()
                    .environmentObject(sizeFormViewModel)
            case .volumePrefix:
                unitPickerForVolumePrefix
            case .amountUnit:
                EmptyView()
            }
        }
        .sheet(isPresented: $showingUnitPickerForVolumePrefix) {
            unitPickerForVolumePrefix
        }
    }
    
    var unitPickerForVolumePrefix: some View {
        UnitPicker(
            pickedUnit: sizeFormViewModel.volumePrefixUnit,
            filteredType: .volume)
        { unit in
            sizeFormViewModel.volumePrefixUnit = unit
        }
    }
    
    var content: some View {
        HStack {
            Group {
                Spacer()
                button(sizeFormViewModel.quantityString) {
                    sizeFormViewModel.path.append(.quantity)
                }
                Spacer()
                symbol("×")
                    .layoutPriority(3)
                Spacer()
            }
            HStack(spacing: 0) {
                if sizeFormViewModel.showingVolumePrefix {
                    button(sizeFormViewModel.volumePrefixUnit.shortDescription) {
                        showingUnitPickerForVolumePrefix = true
                    }
                    .layoutPriority(2)
                    symbol(", ")
                        .layoutPriority(3)
                }
                button(sizeFormViewModel.nameFieldString, placeholder: "name") {
                    sizeFormViewModel.path.append(.name)
                }
                .layoutPriority(2)
            }
            Group {
                Spacer()
                symbol("=")
                    .layoutPriority(3)
                Spacer()
                button(sizeFormViewModel.amountFieldString, placeholder: "amount") {
                    sizeFormViewModel.path.append(.amount)
                }
                .layoutPriority(1)
                Spacer()
            }
        }
//        .frame(maxWidth: .infinity)
    }
    
    var namePicker: some View {
        NamePicker(
            name: $sizeFormViewModel.name,
            showClearButton: true,
            lowercased: true,
            presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
        )
        .navigationTitle("Size Name")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func button(_ string: String, placeholder: String = "", action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Group {
                if string.isEmpty {
                    HStack(spacing: 5) {
                        Text(placeholder)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                } else {
                    Text(string)
                }
            }
            .foregroundColor(.accentColor)
            .frame(maxHeight: .infinity)
            .frame(minWidth: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }

    func symbol(_ string: String) -> some View {
        Text(string)
            .font(.title3)
            .foregroundColor(Color(.tertiaryLabel))
    }

}

public struct SizeFormFieldPreview: View {
    
    @StateObject var viewModel = SizeForm.ViewModel()
    
    @State var showingVolumePrefix: Bool = false
    
    public init() {
        
    }
    
    var volumePrefixToggle: some View {
        var header: some View {
            Text("Volume-prefixed name")
        }
        
        var footer: some View {
            Text("This will let you log this food in volumes of a different density or thickness, like – ‘cups shredded’, ‘cups sliced’.")
        }
        
        return Section(footer: footer) {
            Toggle("Use a volume prefix", isOn: $showingVolumePrefix)
        }
    }

    
    public var body: some View {
        NavigationView {
            Form {
                SizeForm.SizeField()
                    .environmentObject(viewModel)
                volumePrefixToggle
            }
        }
        .onAppear {
            populateData()
        }
        .onChange(of: showingVolumePrefix) { newValue in
            withAnimation {
                viewModel.showingVolumePrefix = newValue
            }
        }
    }
    
    func populateData() {
    }
}
struct SizeFormField_Previews: PreviewProvider {
    static var previews: some View {
        SizeFormFieldPreview()
    }
}

