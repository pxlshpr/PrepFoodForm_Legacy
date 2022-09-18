import SwiftUI

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
                MicronutrientPicker { pickedNutrient in
                    
                }
            }
    }

    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                button(fact: viewModel.energyFact)
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
            button(fact: viewModel.carbFact)
            button(fact: viewModel.fatFact)
            button(fact: viewModel.proteinFact)
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
            ForEach(viewModel.micronutrients, id: \.self.id) {
                button(fact: $0)
            }
            if viewModel.micronutrients.isEmpty {
                addMicronutrientButton
            }
        }
    }
    
    func button(fact: NutritionFact) -> some View {
        Button {
            viewModel.path.append(.nutritionFactForm(fact.type))
        } label: {
            FoodForm.NutritionFacts.Cell(fact: fact)
        }
        .buttonStyle(.borderless)
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
