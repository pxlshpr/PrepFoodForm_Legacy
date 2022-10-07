import SwiftUI

//MARK: - SizeCell
extension FoodForm.NutrientsPerForm.SizesCell {
    struct SizeCell: View {
        @ObservedObject var fieldValueViewModel: FieldValueViewModel
    }
}

extension FoodForm.NutrientsPerForm.SizesCell.SizeCell {
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.primary)
            Spacer()
            HStack {
                Text(amountString)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
    
    var size: Size? {
        fieldValueViewModel.fieldValue.size
    }
    
    var name: String {
        size?.fullNameString ?? ""
    }
    
    var amountString: String {
        size?.scaledAmountString ?? ""
    }
}

//MARK: - SizesCell
extension FoodForm.NutrientsPerForm {
    struct SizesCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        let maxNumberOfSizes = 4
    }
}

extension FoodForm.NutrientsPerForm.SizesCell {
    
    var body: some View {
        content
    }
    
    var numberOfStandardSizes: Int {
        min(viewModel.standardSizeViewModels.count, maxNumberOfSizes)
    }

    /// We're displaying standard sizes first, so these take the remaining availble slots
    var numberOfVolumePrefixedSizes: Int {
        min(maxNumberOfSizes - numberOfStandardSizes, viewModel.volumePrefixedSizeViewModels.count)
    }
    
    var numberOfExcessSizes: Int {
        max((viewModel.standardSizeViewModels.count + viewModel.volumePrefixedSizeViewModels.count) - maxNumberOfSizes, 0)
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(0..<numberOfStandardSizes, id: \.self) { index in
                SizeCell(fieldValueViewModel: viewModel.standardSizeViewModels[index])
            }
            ForEach(0..<numberOfVolumePrefixedSizes, id: \.self) { index in
                SizeCell(fieldValueViewModel: viewModel.volumePrefixedSizeViewModels[index])
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
        viewModel.standardSizeViewModels = mockStandardSizes.fieldValueViewModels
        viewModel.volumePrefixedSizeViewModels = mockVolumePrefixedSizes.fieldValueViewModels
    }
}

struct SizesCell_Previews: PreviewProvider {
    static var previews: some View {
        SizesCellPreview()
    }
}

let mockStandardSizes: [Size] = [
    Size(quantity: 1, quantityString: "1", name: "small", amount: 80, amountString: "80", unit: .weight(.g)),
    Size(quantity: 2, quantityString: "2", name: "medium", amount: 180, amountString: "180", unit: .weight(.g)),
    Size(quantity: 1, quantityString: "1", name: "large", amount: 240, amountString: "240", unit: .weight(.g)),
]

let mockVolumePrefixedSizes: [Size] = [
    Size(quantity: 1, quantityString: "1", volumePrefixUnit: .volume(.cup), name: "shredded", amount: 155, amountString: "155", unit: .weight(.g)),
    Size(quantity: 1, quantityString: "1", volumePrefixUnit: .volume(.cup), name: "sliced", amount: 110, amountString: "110", unit: .weight(.g)),
    Size(quantity: 1, quantityString: "1", volumePrefixUnit: .volume(.cup), name: "pureed", amount: 205, amountString: "205", unit: .weight(.g)),
]

extension Array where Element == Size {
    var fieldValueViewModels: [FieldValueViewModel] {
        map {
            FieldValueViewModel(fieldValue: .size(.init(size: $0, fillType: .userInput)))
        }
    }
}
