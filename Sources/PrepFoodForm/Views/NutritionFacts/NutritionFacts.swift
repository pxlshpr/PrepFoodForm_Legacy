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
                button(fact: viewModel.energyFact, type: .energy)
                titleCell("Macronutrients")
                button(fact: viewModel.carbFact, type: .macro(.carb))
                button(fact: viewModel.fatFact, type: .macro(.fat))
                button(fact: viewModel.proteinFact, type: .macro(.protein))
            }
            .padding(.horizontal, 20)
        }
        .background(formBackgroundColor)
    }
    
    func button(fact: NutritionFact?, type: NutritionFactType) -> some View {
        Button {
            viewModel.path.append(.nutritionFactForm(type))
        } label: {
            FoodForm.NutritionFacts.Cell(
                nutritionFactType: type,
                nutritionFact: fact
            )
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
