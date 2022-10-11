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
                Text(viewModel.amountViewModel.doubleValueDescription)
                    .foregroundColor(.primary)
                if viewModel.hasNutrientsPerServingContent {
                    Text("•")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(viewModel.servingViewModel.doubleValueDescription)")
                        .foregroundColor(.secondary)
                }
                Spacer()
                sizesCount
            }
        }
    }
    
    @ViewBuilder
    var sizesCount: some View {
        if viewModel.numberOfSizes > 0 {
            HStack {
//                Image(systemName: "plus.circle.fill")
//                    .foregroundColor(Color(.quaternaryLabel))
                Text("\(viewModel.numberOfSizes) size\(viewModel.numberOfSizes > 1 ? "s" : "")")
                    .foregroundColor(Color(.secondaryLabel))
            }
            .padding(.vertical, 5)
            .padding(.leading, 7)
            .padding(.trailing, 9)
            .background(
                Capsule(style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
            )
            .padding(.vertical, 5)
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
        viewModel.amountViewModel.fieldValue = FieldValue.amount(FieldValue.DoubleValue(double: 1, string: "1", unit: .serving))
        viewModel.servingViewModel.fieldValue = FieldValue.serving(FieldValue.DoubleValue(double: 25, string: "25", unit: .weight(.g)))
    }
}
struct ServingCell_Previews: PreviewProvider {
    static var previews: some View {
        ServingCellPreview()
    }
}
