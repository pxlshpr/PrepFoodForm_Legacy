import SwiftUI
import PrepUnits
import SwiftHaptics

extension FoodForm.NutritionFacts {
    public struct MicronutrientPicker: View {
        
        enum Route: Hashable {
            case form(NutrientType)
        }
        
        @Environment(\.dismiss) var dismiss
        var didTapNutrient: ((NutrientType) -> ())?
        @State var path: [Route] = []
        
        init(didTapNutrient: ((NutrientType) -> Void)? = nil) {
            self.didTapNutrient = didTapNutrient
        }
    }
}

extension FoodFormViewModel {
    
    func hasNutrientsLeftToAdd(in group: NutrientTypeGroup) -> Bool {
        group.nutrients.contains { nutrientType in
            !hasAddedNutrient(nutrientType)
        }
    }
    
    func hasAddedNutrient(_ type: NutrientType) -> Bool {
        micronutrients.contains(where: { $0.nutrientType == type })
    }
}

extension NutritionFact {
    var nutrientType: NutrientType? {
        switch type {
        case .micro(let type):
            return type
        default:
            return nil
        }
    }
}

extension FoodForm.NutritionFacts.MicronutrientPicker {
    public var body: some View {
        NavigationStack(path: $path) {
            form
                .navigationTitle("Micronutrients")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .form(let nutrientType):
                        FoodForm.NutritionFacts.FactForm(
                            type: .micro(nutrientType),
                            isNewMicronutrient: true
                        )
                    }
                }
        }
    }
    
    var form: some View {
        Form {
            ForEach(NutrientTypeGroup.allCases, id: \.self) { group in
                if FoodFormViewModel.shared.hasNutrientsLeftToAdd(in: group) {
                    groupSection(for: group)
                }
            }
        }
    }
    
    func groupSection(for group: NutrientTypeGroup) -> some View {
        Section(group.description) {
            ForEach(group.nutrients, id: \.self) { nutrient in
                if !FoodFormViewModel.shared.hasAddedNutrient(nutrient) {
                    nutrientButton(for: nutrient)
                }
            }
        }
    }
    
    func nutrientButton(for nutrientType: NutrientType) -> some View {
        Button {
            path.append(.form(nutrientType))
        } label: {
            Text(nutrientType.description)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
//        .buttonStyle(.borderless)
    }
    
    func didTap(_ nutrient: NutrientType) {
        didTapNutrient?(nutrient)
        Haptics.feedback(style: .rigid)
        dismiss()
    }
}

extension NutrientTypeGroup {
    var nutrients: [NutrientType] {
        NutrientType.allCases.filter({ $0.group == self })
    }
}

struct MicronutrientPickerPreview: View {
    var body: some View {
        FoodForm.NutritionFacts.MicronutrientPicker()
    }
}

struct MicronutrientPicker_Previews: PreviewProvider {
    static var previews: some View {
        MicronutrientPickerPreview()
    }
}
