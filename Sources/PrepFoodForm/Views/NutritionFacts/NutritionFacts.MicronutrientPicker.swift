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
        micronutrients[index].fieldValueViewModels.contains(where: { $0.fieldValue.isEmpty })
    }
    
    func hasNonEmptyFieldValuesInMicronutrientsGroup(at index: Int) -> Bool {
        micronutrients[index].fieldValueViewModels.contains(where: { !$0.fieldValue.isEmpty })
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
                        ForEach(viewModel.micronutrients[g].fieldValueViewModels.indices, id: \.self) { f in
                            if viewModel.micronutrients[g].fieldValueViewModels[f].fieldValue.isEmpty {
                                nutrientButton(for: $viewModel.micronutrients[g].fieldValueViewModels[f])
                            }
                        }
                    }
                }
            }
        }
    }
    
    func nutrientButton(for fieldValueViewModel: Binding<FieldValueViewModel>) -> some View {
        NavigationLink {
            MicronutrientForm(fieldValueViewModel: fieldValueViewModel) { fieldValueCopy in
                /// Set the value here so the user sees the animation of the micronutrient disappearing, and then clear the `transientString` for the next addition
                withAnimation {
                    fieldValueViewModel.wrappedValue.fieldValue.microValue.string = fieldValueCopy.microValue.string
                    fieldValueViewModel.wrappedValue.fieldValue.microValue.unit = fieldValueCopy.microValue.unit
                    fieldValueViewModel.wrappedValue.fieldValue.fillType = fieldValueCopy.microValue.fillType
                }
            }
            .environmentObject(viewModel)
        } label: {
            Text(fieldValueViewModel.wrappedValue.fieldValue.description)
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
