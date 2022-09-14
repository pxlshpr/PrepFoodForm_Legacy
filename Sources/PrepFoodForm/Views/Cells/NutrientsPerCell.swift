import SwiftUI
import PrepUnits

extension FoodForm {
    struct NutrientsPerCell: View {
        @EnvironmentObject var viewModel: ViewModel
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
            HStack(spacing: 0) {
                Text(viewModel.amountDescription)
                    .foregroundColor(.primary)
                if viewModel.hasNutrientsPerServingContent {
                    Text(" (\(viewModel.servingDescription))")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

//MARK: - Preview

public struct ServingCellPreview: View {
    
    @StateObject var viewModel = FoodForm.ViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            Form {
                FoodForm.NutrientsPerForm.AmountFieldSection()
                    .environmentObject(viewModel)
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
        viewModel.amountString = "1"
        viewModel.servingString = "25"
    }
}
struct ServingCell_Previews: PreviewProvider {
    static var previews: some View {
        ServingCellPreview()
    }
}
