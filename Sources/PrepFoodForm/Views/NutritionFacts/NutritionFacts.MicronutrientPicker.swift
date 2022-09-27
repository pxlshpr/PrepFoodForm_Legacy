import SwiftUI
import PrepUnits
import SwiftHaptics

extension FoodForm.NutritionFacts {
    public struct MicronutrientPicker: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.dismiss) var dismiss
    }
}

extension FoodFormViewModel {
    func hasEmptyFieldValuesInMicronutrientsGroup(at index: Int) -> Bool {
        micronutrients[index].fieldValues.contains(where: { $0.isEmpty })
    }
    
    func hasNonEmptyFieldValuesInMicronutrientsGroup(at index: Int) -> Bool {
        micronutrients[index].fieldValues.contains(where: { !$0.isEmpty })
    }
}
extension FoodForm.NutritionFacts.MicronutrientPicker {
    public var body: some View {
        NavigationView {
            form
                .navigationTitle("Micronutrients")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { navigationLeadingContent }
        }
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Done") {
                dismiss()
            }
        }
    }
    var form: some View {
        Form {
            ForEach(viewModel.micronutrients.indices, id: \.self) { g in
                if viewModel.hasEmptyFieldValuesInMicronutrientsGroup(at: g) {
                    Section(viewModel.micronutrients[g].group.description) {
                        ForEach(viewModel.micronutrients[g].fieldValues.indices, id: \.self) { f in
                            if viewModel.micronutrients[g].fieldValues[f].isEmpty {
                                nutrientButton(for: $viewModel.micronutrients[g].fieldValues[f])
                            }
                        }
                    }
                }
            }
        }
    }
    
    func nutrientButton(for fieldValue: Binding<FieldValue>) -> some View {
        NavigationLink {
            MicronutrientForm(fieldValue: fieldValue) { string, nutrientUnit in
                /// Set the value here so the user sees the animation of the micronutrient disappearing, and then clear the `transientString` for the next addition
                withAnimation {
                    fieldValue.wrappedValue.string = string
                    fieldValue.wrappedValue.nutrientUnit = nutrientUnit
                }
            }
        } label: {
            Text(fieldValue.wrappedValue.description)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}

extension NutrientTypeGroup {
    var nutrients: [NutrientType] {
        NutrientType.allCases.filter({ $0.group == self })
    }
}



extension FoodFormViewModel {
    
    func hasNutrientsLeftToAdd(in group: NutrientTypeGroup) -> Bool {
        group.nutrients.contains { nutrientType in
            !hasAddedNutrient(nutrientType)
        }
    }
    
    func hasAddedNutrient(_ type: NutrientType) -> Bool {
        //TODO: Micronutrients
        false
//        micronutrients.contains(where: { $0.identifier.nutrientType == type })
    }
}

struct MicronutrientPickerPreview: View {
    var body: some View {
        FoodForm.NutritionFacts.MicronutrientPicker()
    }
}

struct MicronutrientPicker_Previews: PreviewProvider {
    static var previews: some View {
        MicronutrientPickerPreview()
    }
}
