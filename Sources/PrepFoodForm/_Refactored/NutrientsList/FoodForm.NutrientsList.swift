import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

extension FoodForm {
    struct NutrientsList: View {
        @EnvironmentObject var fields: FoodForm.Fields
        @EnvironmentObject var sources: FoodForm.Sources

        @State var showingMenu = false
        @State var showingMicronutrientsPicker = false

        @State var showingImages = true
    }
}

extension FoodForm.NutrientsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { micronutrientsPicker }
            .bottomMenu(isPresented: $showingMenu, menu: bottomMenu)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyCell
                macronutrientsGroup
//                micronutrientsGroup
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    //MARK: - Cells
    
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
    
    //MARK: - Decorator Views
    
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
    
    //MARK: - UI
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            addButton
            menuButton
        }
    }

    var addButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingMicronutrientsPicker = true
        } label: {
            Image(systemName: "plus")
                .padding(.vertical)
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    var menuButton: some View {
        if fields.containsFieldWithFillImage {
            Button {
                showingMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .padding(.vertical)
            }
        }
    }

    var micronutrientsPicker: some View {
        MicronutrientsPicker { nutrientTypes in
            withAnimation {
                fields.includeMicronutrients(for: nutrientTypes)
            }
        }
        .environmentObject(fields)
    }
    
    //MARK: Menu
    
    var bottomMenu: BottomMenu {
        BottomMenu(action: showHideAction)
    }

    var showHideAction: BottomMenuAction {
        BottomMenuAction(
            title: "\(showingImages ? "Hide" : "Show") Images",
            systemImage: "eye\(showingImages ? ".slash" : "")",
            tapHandler: {
                withAnimation {
                    showingImages.toggle()
                }
            })
    }
}
