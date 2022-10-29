import SwiftUI
import NamePicker

extension FoodForm.AmountPerForm.SizeForm {
    struct Editor: View {
        @EnvironmentObject var formViewModel: SizeFormViewModel
        @ObservedObject var field: Field
        
        @Binding var showingUnitPickerForVolumePrefix: Bool
        @Binding var showingQuantityForm: Bool
        @Binding var showingNamePicker: Bool
        @Binding var showingAmountForm: Bool
    }
}

extension FoodForm.AmountPerForm.SizeForm.Editor {
    
    var body: some View {
        content
    }
    
    var content: some View {
        HStack {
            Group {
                Spacer()
                button(field.sizeQuantityString) {
                    showingQuantityForm = true
                }
                Spacer()
                symbol("×")
                    .layoutPriority(3)
                Spacer()
            }
            HStack(spacing: 0) {
                if formViewModel.showingVolumePrefix {
                    button(field.sizeVolumePrefixString) {
                        showingUnitPickerForVolumePrefix = true
                    }
                    .layoutPriority(2)
                    symbol(", ")
                        .layoutPriority(3)
                }
                button(field.sizeNameString, placeholder: "name") {
                    showingNamePicker = true
                }
                .layoutPriority(2)
            }
            Group {
                Spacer()
                symbol("=")
                    .layoutPriority(3)
                Spacer()
                button(field.sizeAmountDescription, placeholder: "amount") {
                    showingAmountForm = true
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