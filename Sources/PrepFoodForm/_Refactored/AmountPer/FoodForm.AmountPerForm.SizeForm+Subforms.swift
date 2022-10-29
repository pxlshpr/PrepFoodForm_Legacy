import SwiftUI
import NamePicker

extension FoodForm.AmountPerForm.SizeForm {
    var quantityForm: some View {
        NavigationView {
            Quantity(sizeViewModel: field)
        }
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    var nameForm: some View {
        let binding = Binding<String>(
            get: { field.value.string },
            set: {
                if $0 != field.value.string {
                    withAnimation {
                        field.registerUserInput()
                    }
                }
                field.value.string = $0
            }
        )

        return NavigationView {
            NamePicker(
                name: binding,
                showClearButton: true,
                focusOnAppear: true,
                lowercased: true,
                title: "Size Name",
                titleDisplayMode: .large,
                presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
            )
        }
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    var amountForm: some View {
        NavigationView {
            Amount(sizeViewModel: field)
                .environmentObject(formViewModel)
        }
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
    var unitPickerForVolumePrefix: some View {
        FoodForm.AmountPerForm.UnitPicker(
            pickedUnit: field.sizeVolumePrefixUnit,
            filteredType: .volume)
        { unit in
            field.value.size?.volumePrefixUnit = unit
        }
        .environmentObject(fields)
        .onDisappear {
            refreshBool.toggle()
        }
    }
    
}
