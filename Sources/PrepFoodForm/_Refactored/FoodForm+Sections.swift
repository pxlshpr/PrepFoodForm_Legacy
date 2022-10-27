import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepDataTypes

extension FoodForm {
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                DetailsForm(name: $name, detail: $detail, brand: $brand)
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
        
        let energyBinding = Binding<FoodLabelValue>(
            get: { energy.value ?? .init(amount: 0, unit: .kcal)  },
            set: { newValue in }
        )

        return FormStyledSection(header: header) {
            NavigationLink {
                NutrientsList(fieldValues: $fieldValues)
            } label: {
                if shouldShowFoodLabel {
                    FoodLabel(
                        energyValue: energyBinding,
                        carb: .constant(0),
                        fat: .constant(0),
                        protein: .constant(0),
                        nutrients: .constant([:]),
                        amountPerString: .constant("amountPerString")
                    )
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
