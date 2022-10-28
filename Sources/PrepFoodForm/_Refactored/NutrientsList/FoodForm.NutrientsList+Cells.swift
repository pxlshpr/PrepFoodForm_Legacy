import SwiftUI

extension FoodForm.NutrientsList {
    
    var energyCell: some View {
        NavigationLink {
            FoodForm.EnergyForm(existingField: fields.energy)
                .environmentObject(fields)
                .environmentObject(sources)
        } label: {
            Cell(field: fields.energy, showImage: $showingImages)
        }
    }

//    func micronutrientCell(for fieldViewModel: FieldViewModel) -> some View {
//        NavigationLink {
//            MicroForm(existingFieldViewModel: fieldViewModel)
//                .environmentObject(viewModel)
//        } label: {
//            NutritionFactCell(fieldViewModel: fieldViewModel, showImage: $showImages)
//                .environmentObject(viewModel)
//        }
//    }
//
    func macronutrientCell(for field: Field) -> some View {
        NavigationLink {
            MacroForm(existingField: field)
                .environmentObject(fields)
                .environmentObject(sources)
        } label: {
            Cell(field: field, showImage: $showingImages)
//            NutritionFactCell(fieldViewModel: fieldViewModel, showImage: $showImages)
//                .environmentObject(viewModel)
        }
    }
    var macronutrientsGroup: some View {
        Group {
            titleCell("Macronutrients")
            macronutrientCell(for: fields.carb)
            macronutrientCell(for: fields.fat)
            macronutrientCell(for: fields.protein)
        }
    }
    
    //MARK: - Nutrient Groups
    
//    var micronutrientsGroup: some View {
//        var addMicronutrientButton: some View {
//            Button {
//                viewModel.showingMicronutrientsPicker = true
//            } label: {
//                Text("Add a micronutrient")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 13)
//                    .padding(.top, 13)
//                    .background(Color(.secondarySystemGroupedBackground))
//                    .cornerRadius(10)
//                    .padding(.bottom, 10)
//                    .contentShape(Rectangle())
//            }
//            .buttonStyle(.borderless)
//        }
//
//        return Group {
//            titleCell("Micronutrients")
//            ForEach(viewModel.micronutrients.indices, id: \.self) { g in
//                if viewModel.hasIncludedFieldValuesInMicronutrientsGroup(at: g) {
//                    subtitleCell(viewModel.micronutrients[g].group.description)
//                    ForEach(viewModel.micronutrients[g].fieldViewModels.indices, id: \.self) { f in
//                        if viewModel.micronutrients[g].fieldViewModels[f].fieldValue.microValue.isIncluded {
//                            micronutrientCell(for: viewModel.micronutrients[g].fieldViewModels[f])
//                        }
//                    }
//                }
//            }
//            if viewModel.micronutrientsIsEmpty {
//                addMicronutrientButton
//            }
//        }
//    }
}
