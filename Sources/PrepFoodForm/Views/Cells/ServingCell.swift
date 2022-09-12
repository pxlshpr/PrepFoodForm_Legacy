import SwiftUI
import PrepUnits

extension FoodForm {
    struct ServingCell: View {
        @ObservedObject var viewModel: ViewModel
    }
}

extension FoodForm.ServingCell {
    
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
                if viewModel.hasNutrientsPerServingContent {
                    Text(" (\(viewModel.servingAmountDescription))")
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
                FoodForm.ServingForm.AmountFieldSection(viewModel: viewModel)
                Section("Nutrients per") {
                    NavigationLink {
                    } label: {
                        FoodForm.ServingCell(viewModel: viewModel)
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
        viewModel.servingAmountString = "25"
    }
}
struct ServingCell_Previews: PreviewProvider {
    static var previews: some View {
        ServingCellPreview()
    }
}
