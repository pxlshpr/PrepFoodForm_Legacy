import SwiftUI

extension FoodForm {
 
    struct NutrientsList: View {
        @Environment(\.colorScheme) var colorScheme
        
        var energy: NutrientCellData = NutrientCellData(nutrientType: .energy,
                                                        name: "Energy",
                                                        amount: "343",
                                                        unit: "kJ",
                                                        inputType: .filledIn)
        
        var macros: [NutrientCellData] = [
            NutrientCellData(nutrientType: .macro(.carb), name: "Carb", amount: "24", unit: "g", inputType: .filledIn),
            NutrientCellData(nutrientType: .macro(.fat), name: "Fat", amount: "15", unit: "g", inputType: .filledIn),
            NutrientCellData(nutrientType: .macro(.protein), name: "Protein", amount: "18", unit: "g", inputType: .manuallyEntered),
        ]
        
        var micros: [NutrientCellData] = [
            NutrientCellData(nutrientType: .micro, name: "Saturated Fat", amount: "7.5", unit: "g", inputType: .manuallyEntered),
            NutrientCellData(nutrientType: .micro, name: "Sodium", amount: "950", unit: "mg", inputType: .selected)
        ]
    }
}

extension FoodForm.NutrientsList {
    var body: some View {
//        NavigationView {
//            form
//            list
            scrollView
                .toolbar { bottomToolbarContent }
                .navigationTitle("Nutrients")
                .navigationBarTitleDisplayMode(.inline)
//        }
    }

    var formBackgroundColor: Color {
        colorScheme == .dark ? .black: Color(.systemGroupedBackground)
    }
    
    var cellBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGroupedBackground) : Color(.secondarySystemGroupedBackground)
    }
    
    var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                cell(for: energy)
                titleCell("Macronutrients")
                ForEach(macros) { macro in
                    cell(for: macro)
                }
                titleCell("Micronutrients")
                ForEach(micros) { micro in
                    cell(for: micro)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(formBackgroundColor)
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
            
        } label: {
            Image(systemName: "plus")
        }
    }
    
    var scanButton: some View {
        Button {
            
        } label: {
            Image(systemName: "text.viewfinder")
        }
    }
    
    func titleCell(_ title: String) -> some View {
        Group {
            Spacer().frame(height: 15)
            HStack {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.secondary)
                Spacer()
            }
            Spacer().frame(height: 7)
        }
    }
    
    func cell(for datum: NutrientCellData) -> some View {
        navigationLink(for: datum)
//        label(for: datum)
    }
    
    func navigationLink(for datum: NutrientCellData) -> some View {
        NavigationLink {
            FoodForm.NutrientsList.Form(amount: datum.amount, unit: datum.unit, title: datum.name)
        } label: {
            label(for: datum)
        }
        .listRowInsets(.none)
    }
    
    func label(for datum: NutrientCellData) -> some View {
        FoodForm.NutrientsList.Cell(nutrientType: datum.nutrientType,
                             name: datum.name,
                             amount: datum.amount,
                             unit: datum.unit,
                             inputType: datum.inputType)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(cellBackgroundColor)
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    struct NutrientCellData: Identifiable {
        var nutrientType: FoodForm.NutrientsList.Cell.NutrientType
        var name: String
        var amount: String
        var unit: String
        var inputType: FoodForm.NutrientsList.Cell.NutrientInputType
        
        var id: UUID {
            UUID()
        }
    }
}
