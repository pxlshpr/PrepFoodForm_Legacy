import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct SizesCell: View {
        @EnvironmentObject var viewModel: FoodForm.ViewModel
    }
}

struct SizeViewModel: Hashable {
    let size: Size
    
    var volumePrefixString: String? {
        guard let unit = size.volumePrefixUnit else {
            return nil
        }
        return unit.shortDescription
    }
    var nameString: String {
        size.name
    }
    
    var fullNameString: String {
        if let volumePrefixUnit = size.volumePrefixUnit {
            return "\(volumePrefixUnit.shortDescription), \(nameString)"
        } else {
            return nameString
        }
    }
    
    var quantity: Double {
        size.quantity
    }
    var quantityString: String {
        size.quantity.cleanAmount
    }
    
    var amountString: String {
        "\(size.amount.cleanAmount) \(size.amountUnit.shortDescription)"
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    struct SizeCell: View {
        var sizeViewModel: SizeViewModel
    }
}

extension FoodForm.NutrientsPerForm.SizesCell.SizeCell {
    var body: some View {
        HStack(spacing: 0) {
            Text(sizeViewModel.fullNameString)
                .foregroundColor(.primary)
            Text(", ")
                .foregroundColor(Color(.quaternaryLabel))
            HStack {
                if sizeViewModel.quantity != 1 {
                    Text(sizeViewModel.quantityString)
                        .foregroundColor(Color(.tertiaryLabel))
                    Text("=")
                        .foregroundColor(Color(.quaternaryLabel))
                }
                Text(sizeViewModel.amountString)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    
    var body: some View {
        Group {
            if viewModel.allSizes.isEmpty {
                emptyContent
            } else {
                filledContent
            }
        }
    }
    
    var emptyContent: some View {
        Text("Add a size")
            .foregroundColor(.accentColor)
    }
    
    var filledContent: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.allSizesViewModels.prefix(4), id: \.self) {
                SizeCell(sizeViewModel: $0)
            }
            if viewModel.allSizesViewModels.count > 4 {
                HStack {
                    Text("…")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(viewModel.allSizes.count - 4) more")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
    }
}

//MARK: - Preview

struct SizesCellPreview: View {
    
    @StateObject var viewModel = FoodForm.ViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                    } label: {
                        FoodForm.NutrientsPerForm.SizesCell()
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
        viewModel.standardSizes = mockStandardSizes
        viewModel.volumePrefixedSizes = mockVolumePrefixedSizes
    }
}
struct SizesCell_Previews: PreviewProvider {
    static var previews: some View {
        SizesCellPreview()
    }
}

let mockStandardSizes = [
    Size(quantity: 1, name: "small", amount: 80, amountUnit: .weight(.g)),
    Size(quantity: 2, name: "medium", amount: 180, amountUnit: .weight(.g)),
    Size(quantity: 1, name: "large", amount: 240, amountUnit: .weight(.g)),
]

let mockVolumePrefixedSizes = [
    Size(quantity: 1, volumePrefixUnit: .volume(.cup), name: "shredded", amount: 155, amountUnit: .weight(.g)),
    Size(quantity: 1, volumePrefixUnit: .volume(.cup), name: "sliced", amount: 110, amountUnit: .weight(.g)),
    Size(quantity: 1, volumePrefixUnit: .volume(.cup), name: "pureed", amount: 205, amountUnit: .weight(.g)),
]
