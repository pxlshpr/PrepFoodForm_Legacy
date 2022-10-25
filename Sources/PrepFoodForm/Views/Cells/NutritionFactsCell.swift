import SwiftUI
import PrepDataTypes
import FoodLabel

extension FoodForm {
    struct NutritionFactsCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
        
        @State var energyInCalories: Bool = true
    }
}

extension FoodForm.NutritionFactsCell {
    
    var body: some View {
        Group {
            if !viewModel.hasNutritionFacts {
                emptyContent
            } else {
                foodLabel
//                legacyContent
            }
        }
    }
    
    var emptyContent: some View {
        Text("Required")
            .foregroundColor(Color(.tertiaryLabel))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var foodLabel: some View {
        FoodLabel(dataSource: viewModel)
            .id(viewModel.foodLabelRefreshBool)
    }
}

//MARK: - Preview

public struct NutritionFactsCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                    } label: {
                        FoodForm.NutritionFactsCell()
                            .environmentObject(viewModel)
                    }
                }
            }
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.previewPrefill()
    }
}
struct NutritionFactsCell_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsCellPreview()
    }
}
