import SwiftUI
import PrepUnits
import SwiftHaptics

public struct NutritionFactsList: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var showImages = false

    public var body: some View {
        scrollView
            .toolbar { navigationTrailingContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showingMicronutrientsPicker) { microPicker }
    }

    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                energyCell
                macronutrientsGroup
                micronutrientsGroup
            }
            .padding(.horizontal, 20)
        }
        .background(formBackgroundColor)
    }
    
    var microPicker: some View {
        MicroPicker { pickedNutrientTypes in
            withAnimation {
                viewModel.includeMicronutrients(for: pickedNutrientTypes)
            }
        }
        .environmentObject(viewModel)
    }
    
    func macronutrientForm(for fieldViewModel: FieldViewModel) -> some View {
        NavigationLink {
            MacroForm(existingFieldViewModel: fieldViewModel)
                .environmentObject(viewModel)
        } label: {
            NutritionFactCell(fieldViewModel: fieldViewModel, showImage: $showImages)
                .environmentObject(viewModel)
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
    
    var energyCell: some View {
//        Button {
//            showingEnergyForm = true
        NavigationLink {
            EnergyForm(existingFieldViewModel: viewModel.energyViewModel)
                .environmentObject(viewModel)
        } label: {
            NutritionFactCell(fieldViewModel: viewModel.energyViewModel, showImage: $showImages)
                .environmentObject(viewModel)
        }
    }

    var macronutrientsGroup: some View {
        Group {
            titleCell("Macronutrients")
            macronutrientForm(for: viewModel.carbViewModel)
            macronutrientForm(for: viewModel.fatViewModel)
            macronutrientForm(for: viewModel.proteinViewModel)
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
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack {
                showImagesButton
                addButton
            }
        }
    }
    
    var showImagesButton: some View {
        Button {
            Haptics.feedback(style: .medium)
            withAnimation {
                showImages.toggle()
            }
        } label: {
            Image(systemName: "photo.circle\(showImages ? ".fill" : "")")
        }
    }
    
    var addButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            viewModel.showingMicronutrientsPicker = true
        } label: {
            Image(systemName: "plus")
                .padding(.horizontal)
//                .background(.green)
        }
        .buttonStyle(.borderless)
    }
}


struct NutritionFactsPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .spinach)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            NutritionFactsList()
                .environmentObject(viewModel)
                .navigationTitle("Nutrition Facts")
        }
    }
}

struct NutritionFacts_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsPreview()
    }
}
