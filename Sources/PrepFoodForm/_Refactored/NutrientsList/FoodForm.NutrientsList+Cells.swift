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

    func micronutrientCell(for field: Field) -> some View {
        NavigationLink {
            MicroForm(existingField: field)
                .environmentObject(fields)
                .environmentObject(sources)
        } label: {
            Cell(field: field, showImage: $showingImages)
        }
    }

    func macronutrientCell(for field: Field) -> some View {
        NavigationLink {
            MacroForm(existingField: field)
                .environmentObject(fields)
                .environmentObject(sources)
        } label: {
            Cell(field: field, showImage: $showingImages)
        }
    }
    
    
    //MARK: - Groups

    var macronutrientsGroup: some View {
        Group {
            titleCell("Macronutrients")
            macronutrientCell(for: fields.carb)
            macronutrientCell(for: fields.fat)
            macronutrientCell(for: fields.protein)
        }
    }

    var micronutrientsGroup: some View {
        var addMicronutrientButton: some View {
            Button {
                showingMicronutrientsPicker = true
            } label: {
                Text("Add a micronutrient")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 13)
                    .padding(.top, 13)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
        }

        return Group {
            titleCell("Micronutrients")
            ForEach(fields.micronutrients.indices, id: \.self) { g in
                if fields.hasIncludedFieldValuesInMicronutrientsGroup(at: g) {
                    group(at: g)
                }
            }
            if fields.micronutrientsIsEmpty {
                addMicronutrientButton
            }
        }
    }
    
    func group(at index: Int) -> some View {
        Group {
            subtitleCell(fields.micronutrients[index].group.description)
            ForEach(fields.micronutrients[index].fields.indices, id: \.self) { f in
                let field = fields.micronutrients[index].fields[f]
                if field.value.microValue.isIncluded {
                    micronutrientCell(for: fields.micronutrients[index].fields[f])
                }
            }
        }
    }
}
