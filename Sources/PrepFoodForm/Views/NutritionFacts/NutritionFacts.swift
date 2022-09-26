import SwiftUI
import PrepUnits

extension FoodForm {
    public struct NutritionFacts: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
    }
}

extension FoodForm.NutritionFacts {
    public var body: some View {
        scrollView
            .toolbar { bottomToolbarContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingMicronutrientsPicker) {
                MicronutrientPicker()
                    .environmentObject(viewModel)
            }
    }

    func macronutrientForm(for fieldValue: Binding<FieldValue>) -> some View {
        NavigationLink {
            MacronutrientForm(fieldValue: fieldValue)
        } label: {
            FoodForm.NutritionFacts.Cell(fieldValue: fieldValue)
        }
    }

    func micronutrientForm(for fieldValue: Binding<FieldValue>) -> some View {
        NavigationLink {
            MicronutrientForm(fieldValue: fieldValue, isBeingEdited: true) { string, nutrientUnit in
                withAnimation {
                    fieldValue.wrappedValue.identifier.string = string
                    fieldValue.wrappedValue.identifier.nutrientUnit = nutrientUnit
                }
            }
        } label: {
            FoodForm.NutritionFacts.Cell(fieldValue: fieldValue)
        }
    }

    var energyForm: some View {
        NavigationLink {
            EnergyForm(fieldValue: $viewModel.energy)
        } label: {
            FoodForm.NutritionFacts.Cell(fieldValue: $viewModel.energy)
        }
    }

    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyForm
                macronutrientsGroup
                micronutrientsGroup
            }
            .padding(.horizontal, 20)
        }
        .background(formBackgroundColor)
    }
    
    var macronutrientsGroup: some View {
        Group {
            titleCell("Macronutrients")
            macronutrientForm(for: $viewModel.carb)
            macronutrientForm(for: $viewModel.fat)
            macronutrientForm(for: $viewModel.protein)
        }
    }
    
    var micronutrientsGroup: some View {
        var addMicronutrientButton: some View {
            Button {
                viewModel.showingMicronutrientsPicker = true
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
            ForEach(viewModel.micronutrients.indices, id: \.self) { g in
                if viewModel.hasNonEmptyFieldValuesInMicronutrientsGroup(at: g) {
                    subtitleCell(viewModel.micronutrients[g].group.description)
                    ForEach(viewModel.micronutrients[g].fieldValues.indices, id: \.self) { f in
                        if !viewModel.micronutrients[g].fieldValues[f].isEmpty {
                            micronutrientForm(for: $viewModel.micronutrients[g].fieldValues[f])
                        }
                    }
                }
            }
            if viewModel.micronutrientsIsEmpty {
                addMicronutrientButton
            }
        }
    }
    
    func button(fact: NutritionFact) -> some View {
        Color.red
//        NavigationLink {
//            FoodForm.NutritionFacts.FactForm(fact: fact, type: fact.type)
//                .environmentObject(viewModel)
//        } label: {
//            FoodForm.NutritionFacts.Cell(fact: fact)
//        }
    }
    
    func titleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 15)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }
    
    func subtitleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 5)
            HStack {
                Spacer().frame(width: 3)
                Text(title)
                    .font(.headline)
//                    .bold()
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }
    
    //MARK: - Legacy

    var formBackgroundColor: Color {
//        colorScheme == .dark ? .black: Color(.systemGroupedBackground)
        Color(.systemGroupedBackground)
    }
    
    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            addButton
            Spacer()
            scanButton
        }
    }
    
    var addButton: some View {
        Button {
            viewModel.showingMicronutrientsPicker = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(.borderless)
    }
    
    var scanButton: some View {
        Button {
            
        } label: {
            Image(systemName: "text.viewfinder")
        }
    }
}

//MARK: - Preview

struct NutritionFactsPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    var body: some View {
        NavigationView {
            FoodForm.NutritionFacts()
                .environmentObject(viewModel)
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
    }
}

struct NutritionFacts_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsPreview()
    }
}
