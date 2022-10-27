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
        SourcesView(sources: sources,
                    didTapAddSource: tappedAddSource,
                    handleSourcesAction: handleSourcesAction)
    }
    
    var foodLabelSection: some View {
        @ViewBuilder var header: some View {
            if !fields.shouldShowFoodLabel {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
                NutrientsList()
                    .environmentObject(fields)
            } label: {
                if fields.shouldShowFoodLabel {
                    foodLabel
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    var foodLabel: FoodLabel {
        let energyBinding = Binding<FoodLabelValue>(
            get: { fields.energy.value.value ?? .init(amount: 0, unit: .kcal)  },
            set: { newValue in }
        )

        let carbBinding = Binding<Double>(
            get: { fields.carb.value.double ?? 0  },
            set: { newValue in }
        )

        let fatBinding = Binding<Double>(
            get: { fields.fat.value.double ?? 0  },
            set: { newValue in }
        )

        let proteinBinding = Binding<Double>(
            get: { fields.protein.value.double ?? 0  },
            set: { newValue in }
        )

        return FoodLabel(
            energyValue: energyBinding,
            carb: carbBinding,
            fat: fatBinding,
            protein: proteinBinding,
            nutrients: .constant([:]),
            amountPerString: .constant("amountPerString")
        )
    }
}
