import SwiftUI
import NamePicker

extension SizeForm {
    struct Field: View {
        @ObservedObject var viewModel: SizeForm.ViewModel
    }
}

extension SizeForm.Field {
    
    var body: some View {
        content
        .navigationDestination(for: SizeForm.Route.self) {
            switch $0 {
            case .name:
                namePicker
            case .quantity:
                Text("Quantity form")
            case .amount:
                SizeForm.AmountForm(viewModel: viewModel)
            case .volumePrefix:
                Text("Volume prefix picker")
            case .sizeAmountUnit:
                UnitPicker(pickedUnit: viewModel.amountUnit) { unit in
                    viewModel.amountUnit = unit
                }
                .navigationTitle("Choose a unit")
            }
        }
    }
    
    var content: some View {
        HStack {
            button(viewModel.quantityString) {
                viewModel.path.append(.quantity)
            }
            Spacer()
            symbol("×")
            Spacer()
            if viewModel.showingVolumePrefix {
                button("cup") {
                    viewModel.path.append(.volumePrefix)
                }
                symbol(", ")
            }
            button(viewModel.nameFieldString, placeholder: "name") {
                viewModel.path.append(.name)
            }
            Spacer()
            symbol("=")
            Spacer()
            button(viewModel.amountFieldString, placeholder: "amount") {
                viewModel.path.append(.amount)
            }
        }
    }
    
    var namePicker: some View {
        NamePicker(
            name: $viewModel.name,
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
                if string.isEmpty {
                    HStack(spacing: 5) {
                        Text(placeholder)
                            .foregroundColor(Color(.tertiaryLabel))
//                        Image(systemName: "chevron.up.chevron.down")
//                            .imageScale(.small)
                    }
                } else {
                    Text(string)
            }
        }
//        .padding()
        .contentShape(Rectangle())
        .foregroundColor(.accentColor)
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
            Text("Volume prefixed size")
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
                SizeForm.Field(viewModel: viewModel)
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

