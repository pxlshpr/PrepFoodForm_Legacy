import SwiftUI
import SwiftUISugar
import FoodLabel

extension FoodForm {
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                Details(name: $name, detail: $detail, brand: $brand)
            } label: {
                FoodDetailsView(emoji: $emoji, name: $name, detail: $detail, brand: $brand, didTapEmoji: {
                    showingEmojiPicker = true
                })
            }
        }
    }
    
    var sourcesSection: some View {
        SourcesView(sourcesViewModel: sourcesViewModel,
                    didTapAddSource: tappedAddSource,
                    handleSourcesAction: handleSourcesAction)
    }
    
    var foodLabelSection: some View {
        @ViewBuilder var header: some View {
            if !fieldsViewModel.hasNutritionFacts {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
//                NutritionFactsList()
//                    .environmentObject(viewModel)
                Color.blue
            } label: {
                if fieldsViewModel.hasNutritionFacts {
                    FoodLabel(dataSource: fieldsViewModel)
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
