import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

extension FoodForm {
    struct NutritionFactsList: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @State var showImages = true
        @State var showingMenu = false
        @State var showingMicronutrientsPicker = false
    }
}

extension FoodForm.NutritionFactsList {
    
    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMicronutrientsPicker) { microPicker }
            .bottomMenu(isPresented: $showingMenu, menu: bottomMenu)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyCell
//                macronutrientsGroup
//                micronutrientsGroup
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    //MARK: - Cells
    
    var energyCell: some View {
        NavigationLink {
            EnergyForm(existingFieldViewModel: viewModel.energyViewModel)
                .environmentObject(viewModel)
        } label: {
            NutritionFactCell(fieldViewModel: viewModel.energyViewModel, showImage: $showImages)
        }
    }

    func micronutrientCell(for fieldViewModel: FieldViewModel) -> some View {
        NavigationLink {
            MicroForm(existingFieldViewModel: fieldViewModel)
                .environmentObject(viewModel)
        } label: {
            NutritionFactCell(fieldViewModel: fieldViewModel, showImage: $showImages)
                .environmentObject(viewModel)
        }
    }
    
    func macronutrientCell(for fieldViewModel: FieldViewModel) -> some View {
        NavigationLink {
            MacroForm(existingFieldViewModel: fieldViewModel)
                .environmentObject(viewModel)
        } label: {
            NutritionFactCell(fieldViewModel: fieldViewModel, showImage: $showImages)
                .environmentObject(viewModel)
        }
    }

    var macronutrientsGroup: some View {
        Group {
            titleCell("Macronutrients")
            NavigationLink {
                MacroForm(existingFieldViewModel: viewModel.carbViewModel)
                    .environmentObject(viewModel)
            } label: {
                NutritionFactCell(fieldViewModel: viewModel.carbViewModel, showImage: $showImages)
                    .environmentObject(viewModel)
            }
//            macronutrientForm(for: viewModel.carbViewModel)
            macronutrientCell(for: viewModel.fatViewModel)
            macronutrientCell(for: viewModel.proteinViewModel)
        }
    }
    
    //MARK: - Nutrient Groups
    
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
                if viewModel.hasIncludedFieldValuesInMicronutrientsGroup(at: g) {
                    subtitleCell(viewModel.micronutrients[g].group.description)
                    ForEach(viewModel.micronutrients[g].fieldViewModels.indices, id: \.self) { f in
                        if viewModel.micronutrients[g].fieldViewModels[f].fieldValue.microValue.isIncluded {
                            micronutrientCell(for: viewModel.micronutrients[g].fieldViewModels[f])
                        }
                    }
                }
            }
            if viewModel.micronutrientsIsEmpty {
                addMicronutrientButton
            }
        }
    }
    
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
            viewModel.showingMicronutrientsPicker = true
        } label: {
            Image(systemName: "plus")
                .padding(.vertical)
//                .background(.green)
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var menuButton: some View {
        if viewModel.shouldShowImagesButton {
            Button {
                showingMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .padding(.vertical)
            }
        }
    }
    
    var microPicker: some View {
        MicroPicker { pickedNutrientTypes in
            withAnimation {
                viewModel.includeMicronutrients(for: pickedNutrientTypes)
            }
        }
        .environmentObject(viewModel)
    }
    
    //MARK: Menu
    
    var bottomMenu: BottomMenu {
        BottomMenu(action: showHideAction)
    }

    var showHideAction: BottomMenuAction {
        BottomMenuAction(
            title: "\(showImages ? "Hide" : "Show") Detected Texts",
            systemImage: "eye\(showImages ? ".slash" : "")",
            tapHandler: {
                withAnimation {
                    showImages.toggle()
                }
            })
    }
}
