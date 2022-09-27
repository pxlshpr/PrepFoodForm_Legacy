import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct SizesCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        let maxNumberOfSizes = 4
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    struct SizeCell: View {
        @Binding var size: NewSize
    }
}

extension FoodForm.NutrientsPerForm.SizesCell.SizeCell {
    var body: some View {
        HStack {
            Text(size.fullNameString)
                .foregroundColor(.primary)
            Spacer()
            HStack {
                Text(size.scaledAmountString)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    
    var body: some View {
        content
    }
    
    var numberOfStandardSizes: Int {
        min(viewModel.standardNewSizes.count, maxNumberOfSizes)
    }

    /// We're displaying standard sizes first, so these take the remaining availble slots
    var numberOfVolumePrefixedSizes: Int {
        min(maxNumberOfSizes - numberOfStandardSizes, viewModel.volumePrefixedSizes.count)
    }
    
    var numberOfExcessSizes: Int {
        max((viewModel.standardNewSizes.count + viewModel.volumePrefixedNewSizes.count) - maxNumberOfSizes, 0)
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(0..<numberOfStandardSizes, id: \.self) { index in
                SizeCell(size: $viewModel.standardNewSizes[index])
            }
            ForEach(0..<numberOfVolumePrefixedSizes, id: \.self) { index in
                SizeCell(size: $viewModel.volumePrefixedNewSizes[index])
            }
            if numberOfExcessSizes > 0 {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(numberOfExcessSizes) more")
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
//    var maxNumberOfSummarySizeViewModels: Int {
//        4
//    }
//
//    var shouldShowExcessSizesCount: Bool {
//        numberOfExcessSizes != nil
//    }
//
//    var numberOfExcessSizes: Int? {
//        guard allSizes.count > 4 else {
//            return nil
//        }
//        return allSizes.count - maxNumberOfSummarySizeViewModels
//    }
//
//    func getSummarySizeViewModels() -> [SizeViewModel] {
//        Array(allSizesViewModels.prefix(maxNumberOfSummarySizeViewModels))
//    }
//
//    func updateSummary() {
//        summarySizeViewModels = getSummarySizeViewModels()
//    }
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
