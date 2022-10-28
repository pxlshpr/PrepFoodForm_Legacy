import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

extension FoodForm.NutrientsList {
    struct MicronutrientsPicker: View {
        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme

        @EnvironmentObject var fields: FoodForm.Fields
        let didAddNutrientTypes: ([NutrientType]) -> ()

        @State var pickedNutrientTypes: [NutrientType] = []

        @State var searchText = ""
        @State var searchIsFocused: Bool = false
    }
}

extension FoodForm.NutrientsList.MicronutrientsPicker {
    
    var body: some View {
        NavigationView {
            SearchableView(
                searchText: $searchText,
                focused: $searchIsFocused,
                content: {
                    form
                }
            )
            .navigationTitle("Add Micronutrients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { navigationLeadingContent }
            .toolbar { navigationTrailingContent }
//            .interactiveDismissDisabled(searchIsFocused)
        }
    }
    
    func didSubmit() { }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !pickedNutrientTypes.isEmpty {
                Button("Add \(pickedNutrientTypes.count)") {
                    didAddNutrientTypes(pickedNutrientTypes)
                    Haptics.successFeedback()
                    dismiss()
                }
            }
        }
    }
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(pickedNutrientTypes.isEmpty ? "Done" : "Cancel") {
                Haptics.feedback(style: .soft)
                dismiss()
            }
        }
    }

    var form: some View {
        Form {
            ForEach(fields.micronutrients.indices, id: \.self) {
                group(atIndex: $0)
            }
        }
    }
    
    func group(atIndex index: Int) -> some View {
        let groupTuple = fields.micronutrients[index]
        return Group {
            if fields.hasEmptyFieldValuesInMicronutrientsGroup(at: index, matching: searchText) {
                Section(groupTuple.group.description) {
                    ForEach(groupTuple.fieldViewModels.indices, id: \.self) {
                        micronutrientButton(atIndex: $0, forGroupAtIndex: index)
                    }
                }
            }
        }
    }
    
    func micronutrientButton(atIndex index: Int, forGroupAtIndex groupIndex: Int) -> some View {
        let fieldViewModel = fields.micronutrients[groupIndex].fieldViewModels[index]
        var searchBool: Bool
        if !searchText.isEmpty {
            searchBool = fieldViewModel.value.microValue.matchesSearchString(searchText)
        } else {
            searchBool = true
        }
        return Group {
            if fieldViewModel.value.isEmpty, searchBool, let nutrientType = fieldViewModel.nutrientType {
                nutrientButton(for: nutrientType)
            }
        }
    }
    
    func nutrientButton(for nutrientType: NutrientType) -> some View {
        Button {
            if pickedNutrientTypes.contains(nutrientType) {
                pickedNutrientTypes.removeAll(where: { $0 == nutrientType })
            } else {
                pickedNutrientTypes.append(nutrientType)
            }
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .opacity(pickedNutrientTypes.contains(nutrientType) ? 1 : 0)
                    .animation(.default, value: pickedNutrientTypes)
                Text(nutrientType.description)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
}
