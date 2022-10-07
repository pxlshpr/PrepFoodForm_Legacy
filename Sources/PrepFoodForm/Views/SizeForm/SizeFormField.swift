import SwiftUI
import NamePicker

struct SizeFormField: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @EnvironmentObject var formViewModel: SizeFormViewModel
    @ObservedObject var sizeViewModel: FieldValueViewModel
    let existingSizeViewModel: FieldValueViewModel?

    @State var showingUnitPickerForVolumePrefix = false
    @State var showingQuantityForm = false
    @State var showingNamePicker = false
    @State var showingAmountForm = false
}

extension SizeFormField {
    
    var body: some View {
        content
            .sheet(isPresented: $showingQuantityForm) { quantityForm }
            .sheet(isPresented: $showingNamePicker) { nameForm }
            .sheet(isPresented: $showingAmountForm) { amountForm }
            .sheet(isPresented: $showingUnitPickerForVolumePrefix) { unitPickerForVolumePrefix }
    }
    
    var content: some View {
        HStack {
            Group {
                Spacer()
                button(sizeViewModel.sizeQuantityString) {
                    showingQuantityForm = true
                }
                Spacer()
                symbol("×")
                    .layoutPriority(3)
                Spacer()
            }
            HStack(spacing: 0) {
                if formViewModel.showingVolumePrefix {
                    button(sizeViewModel.sizeVolumePrefixString) {
                        showingUnitPickerForVolumePrefix = true
                    }
                    .layoutPriority(2)
                    symbol(", ")
                        .layoutPriority(3)
                }
                button(sizeViewModel.sizeNameString, placeholder: "name") {
                    showingNamePicker = true
                }
                .layoutPriority(2)
            }
            Group {
                Spacer()
                symbol("=")
                    .layoutPriority(3)
                Spacer()
                button(sizeViewModel.sizeAmountDescription, placeholder: "amount") {
                    showingAmountForm = true
                }
                .layoutPriority(1)
                Spacer()
            }
        }
//        .frame(maxWidth: .infinity)
    }

    var namePicker: some View {
        NamePicker(
            name: $sizeViewModel.fieldValue.string,
            showClearButton: true,
            lowercased: true,
            presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
        )
        .navigationTitle("Size Name")
        .navigationBarTitleDisplayMode(.inline)
    }

    var unitPickerForVolumePrefix: some View {
        UnitPicker(
            pickedUnit: sizeViewModel.sizeVolumePrefixUnit,
            filteredType: .volume)
        { unit in
            sizeViewModel.fieldValue.size?.volumePrefixUnit = unit
        }
        .environmentObject(viewModel)
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                formViewModel.updateFormState(of: sizeViewModel, comparedToExisting: existingSizeViewModel)
            }
        }
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
    
    //MARK: - Sheets
    var quantityForm: some View {
        NavigationView {
            SizeQuantityForm(formViewModel: sizeViewModel)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                formViewModel.updateFormState(of: sizeViewModel, comparedToExisting: existingSizeViewModel)
            }
        }

    }
    
    var nameForm: some View {
        NavigationView {
            namePicker
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                formViewModel.updateFormState(of: sizeViewModel, comparedToExisting: existingSizeViewModel)
            }
        }
    }
    
    var amountForm: some View {
        NavigationView {
            SizeAmountForm(sizeViewModel: sizeViewModel)
                .environmentObject(viewModel)
                .environmentObject(formViewModel)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                formViewModel.updateFormState(of: sizeViewModel, comparedToExisting: existingSizeViewModel)
            }
        }
    }
}
