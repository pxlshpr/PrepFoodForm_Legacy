import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct SizesCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
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
            Text(sizeViewModel.fullNameString)
                .foregroundColor(.primary)
            Spacer()
//            Text("•")
//                .foregroundColor(Color(.tertiaryLabel))
            HStack {
                Text(sizeViewModel.scaledAmountString)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    
    var body: some View {
        content
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(viewModel.summarySizeViewModels, id: \.self.size.hashValue) {
                SizeCell(sizeViewModel: $0)
            }
            if let excessCount = viewModel.numberOfExcessSizes {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(excessCount) more")
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.vertical, 5)
                .padding(.leading, 7)
                .padding(.trailing, 9)
                .background(
                    Capsule(style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
                .padding(.top, 5)
            }
        }
    }
}

extension FoodFormViewModel {
    var maxNumberOfSummarySizeViewModels: Int {
        4
    }
    
    var shouldShowExcessSizesCount: Bool {
        numberOfExcessSizes != nil
    }
    
    var numberOfExcessSizes: Int? {
        guard allSizes.count > 4 else {
            return nil
        }
        return allSizes.count - maxNumberOfSummarySizeViewModels
    }
    
    func getSummarySizeViewModels() -> [SizeViewModel] {
        Array(allSizesViewModels.prefix(maxNumberOfSummarySizeViewModels))
    }
    
    func updateSummary() {
        summarySizeViewModels = getSummarySizeViewModels()
    }
}

//MARK: - Preview

struct SizesCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
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
