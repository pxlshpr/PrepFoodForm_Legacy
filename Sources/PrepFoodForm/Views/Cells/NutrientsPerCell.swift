import SwiftUI
import PrepUnits

extension FoodForm {
    struct NutrientsPerCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
    }
}

extension FoodForm.NutrientsPerCell {
    
    var body: some View {
        Group {
            if !viewModel.hasNutrientsPerContent {
                emptyContent
            } else {
                filledContent
            }
        }
    }
    
    var emptyContent: some View {
        Text("Required")
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var filledContent: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.amountDescription)
                    .foregroundColor(.primary)
                if viewModel.hasNutrientsPerServingContent {
                    Text("•")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(viewModel.servingDescription)")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

//MARK: - Preview

public struct ServingCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Nutrients per") {
                    NavigationLink {
                    } label: {
                        FoodForm.NutrientsPerCell()
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
        viewModel.amount = FieldValue.amount(double: 1, string: "1", unit: .serving)
        viewModel.serving = FieldValue.serving(double: 25, string: "25", unit: .weight(.g))
    }
}
struct ServingCell_Previews: PreviewProvider {
    static var previews: some View {
        ServingCellPreview()
    }
}
