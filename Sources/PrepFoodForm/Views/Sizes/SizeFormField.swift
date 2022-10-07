import SwiftUI
import NamePicker

struct SizeFormField: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var formViewModel: SizeFormViewModel
    @ObservedObject var sizeViewModel: FieldValueViewModel
    let existingSizeViewModel: FieldValueViewModel?
}

extension SizeFormField {
    
    var body: some View {
        content
    }
    
    var content: some View {
        HStack {
            Group {
                Spacer()
                button(sizeViewModel.sizeQuantityString) {
                    formViewModel.showingQuantityForm = true
                }
                Spacer()
                symbol("×")
                    .layoutPriority(3)
                Spacer()
            }
            HStack(spacing: 0) {
                if formViewModel.showingVolumePrefix {
                    button(sizeViewModel.sizeVolumePrefixString) {
                        formViewModel.showingUnitPickerForVolumePrefix = true
                    }
                    .layoutPriority(2)
                    symbol(", ")
                        .layoutPriority(3)
                }
                button(sizeViewModel.sizeNameString, placeholder: "name") {
                    formViewModel.showingNamePicker = true
                }
                .layoutPriority(2)
            }
            Group {
                Spacer()
                symbol("=")
                    .layoutPriority(3)
                Spacer()
                button(sizeViewModel.sizeAmountDescription, placeholder: "amount") {
                    formViewModel.showingAmountForm = true
                }
                .layoutPriority(1)
                Spacer()
            }
        }
//        .frame(maxWidth: .infinity)
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
