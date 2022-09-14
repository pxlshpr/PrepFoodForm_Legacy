import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct SizesCell: View {
        @EnvironmentObject var viewModel: FoodForm.ViewModel
    }
}

struct SizeViewModel: Hashable {
    let size: Size
    
    var nameString: String {
        if let volumePrefixUnit = size.volumePrefixUnit {
            return "\(volumePrefixUnit.shortDescription), \(size.name)"
        } else {
            return size.name
        }
    }
    
    var quantityString: String? {
        guard size.quantity != 1 else {
            return nil
        }
        return size.quantity.cleanAmount
    }
    
    var amountString: String {
        "\(size.amount.cleanAmount) \(size.amountUnit.shortDescription)"
    }
}

extension FoodForm.ViewModel {
    var sizesViewModels: [SizeViewModel] {
        sizes.map { SizeViewModel(size: $0) }
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    struct SizeCell: View {
        var sizeViewModel: SizeViewModel
    }
}

extension FoodForm.NutrientsPerForm.SizesCell.SizeCell {
    var body: some View {
        HStack {
            if let quantityString = sizeViewModel.quantityString {
                Text(quantityString)
                    .foregroundColor(Color(.secondaryLabel))
            }
            Text(sizeViewModel.nameString)
                .foregroundColor(.primary)
            Text(sizeViewModel.amountString)
                .foregroundColor(.secondary)
        }
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    
    var body: some View {
        Group {
            if viewModel.sizes.isEmpty {
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
            ForEach(viewModel.sizesViewModels.prefix(4), id: \.self) {
                SizeCell(sizeViewModel: $0)
            }
            if viewModel.sizesViewModels.count > 4 {
                HStack {
                    Text("…")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(viewModel.sizes.count - 4) more")
                        .foregroundColor(Color(.tertiaryLabel))
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
        viewModel.sizes = [
            Size(quantity: 1, name: "small", amount: 80, amountUnit: .weight(.g)),
            Size(quantity: 2, name: "medium", amount: 180, amountUnit: .weight(.g)),
            Size(quantity: 1, name: "large", amount: 240, amountUnit: .weight(.g)),
            Size(quantity: 1, volumePrefixUnit: .volume(.cup), name: "shredded", amount: 155, amountUnit: .weight(.g)),
            Size(quantity: 1, volumePrefixUnit: .volume(.cup), name: "sliced", amount: 110, amountUnit: .weight(.g)),
            Size(quantity: 1, volumePrefixUnit: .volume(.cup), name: "pureed", amount: 205, amountUnit: .weight(.g)),
        ]
    }
}
struct SizesCell_Previews: PreviewProvider {
    static var previews: some View {
        SizesCellPreview()
    }
}
