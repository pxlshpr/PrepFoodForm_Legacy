import SwiftUI

extension FoodForm {
    public struct NutritionFacts: View {
        @EnvironmentObject var viewModel: FoodForm.ViewModel
        
        @Environment(\.colorScheme) var colorScheme
    }
}

extension FoodForm.NutritionFacts {
    public var body: some View {
        scrollView
            .toolbar { bottomToolbarContent }
            .navigationTitle("Nutrition Facts")
            .navigationBarTitleDisplayMode(.inline)
    }

    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                button(fact: viewModel.energyFact)
                titleCell("Macronutrients")
                button(fact: viewModel.carbFact)
                button(fact: viewModel.fatFact)
                button(fact: viewModel.proteinFact)
            }
            .padding(.horizontal, 20)
        }
        .background(formBackgroundColor)
    }
    
    func button(fact: NutritionFact) -> some View {
        Button {
            viewModel.path.append(.nutritionFactForm(fact.type))
        } label: {
            FoodForm.NutritionFacts.Cell(fact: fact)
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
    
    //MARK: - Legacy

    var formBackgroundColor: Color {
        colorScheme == .dark ? .black: Color(.systemGroupedBackground)
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
}

//MARK: - Preview

struct NutritionFactsPreview: View {
    
    @StateObject var viewModel = FoodForm.ViewModel()
    
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
