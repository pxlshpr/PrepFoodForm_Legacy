import SwiftUI
import ActivityIndicatorView
import SwiftUISugar
import FoodLabelScanner

extension ScanResult {
    var dataPointsCount: Int {
        var count = nutrientsCount
        if serving?.amount != nil {
            count += 1
        }
        let count1 = allSizeViewModels(at: 1).count
        let count2 = allSizeViewModels(at: 2).count
        count += max(count1, count2)
//        if let serving {
//            if serving.amount != nil {
//                count += 1
//            }
//            if serving.perContainer != nil {
//                count += 1
//            }
//            if serving.equivalentSize != nil {
//                count += 1
//            }
//        }
//        if let headers {
//            
//            if headers.header1Type != nil {
//                count += 1
//            }
//            if headers.header2Type != nil {
//                count += 1
//            }
//        }
        if densityFieldValue != nil {
            count += 1
        }
        count += barcodes.count
        return count
    }
}
extension FoodFormViewModel {
    var scannedNutrientCount: Int {
        imageViewModels.reduce(0) { partialResult, imageViewModel in
            partialResult + (imageViewModel.scanResult?.nutrients.rows.count ?? 0)
        }
    }

    var dataPointsCount: Int {
        imageViewModels.reduce(0) {
            $0 + $1.dataPointsCount
        }
    }

    var autoFilledCount: Int? {
        let count = allFieldViewModels.filter({
            $0.fill.isImageAutofill && !$0.fieldValue.isBarcode
        }).count
        return count != 0 ? count : nil
    }
    
    var selectedFillCount: Int? {
        let count = allFieldViewModels.filter({ $0.fill.isImageSelection }).count
        return count != 0 ? count : nil
    }
    
    var barcodesCount: Int? {
        let count = uniqueBarcodeStrings.count
        return count == 0 ? nil : count
    }
    
    var uniqueBarcodeStrings: [String] {
        imageViewModels
            .reduce([]) {
                $0 + $1.recognizedBarcodes
            }
            .map { $0.string }
            .removingDuplicates()
    }
}
struct ImagesSummary: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    var body: some View {
        HStack {
            Group {
                if viewModel.imageSetStatus == .scanned {
                    summary
                } else {
                    Text(viewModel.imageSetStatusString)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            activityIndicatorView
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color(.secondarySystemFill))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var summary: some View {
        VStack(alignment: .leading) {
            scannedLine
            Group {
                autoFilledLine
                selectedLine
                barcodesLine
            }
            .padding(.leading, 10)
        }
    }
    
    var scannedLine: some View {
        HStack {
            Text("Detected")
            numberView(viewModel.dataPointsCount)
            Text("data point\(viewModel.dataPointsCount == 1 ? "s": "")")
        }
    }
    
    @ViewBuilder
    var autoFilledLine: some View {
        if let count = viewModel.autoFilledCount {
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundColor(Color(.tertiaryLabel))
                Image(systemName: "text.viewfinder")
                    .frame(width: 15, alignment: .center)
                Text("AutoFilled")
                    .frame(width: 70, alignment: .leading)
                numberView(count)
            }
        }
    }
    
    @ViewBuilder
    var selectedLine: some View {
        if let count = viewModel.selectedFillCount {
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundColor(Color(.tertiaryLabel))
                Image(systemName: "hand.tap")
                    .frame(width: 15, alignment: .center)
                Text("Selected")
                    .frame(width: 70, alignment: .leading)
                numberView(count)
            }
        }
    }
    
    @ViewBuilder
    var barcodesLine: some View {
        if let count = viewModel.barcodesCount {
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundColor(Color(.tertiaryLabel))
                Image(systemName: "barcode")
                    .frame(width: 15, alignment: .center)
                Text("Barcodes")
                    .frame(width: 70, alignment: .leading)
                numberView(count)
            }
        }
    }
    
    @ViewBuilder
    var activityIndicatorView: some View {
        if viewModel.imageSetStatus.isWorking {
            ActivityIndicatorView(
                isVisible: .constant(true),
                type: .arcs(count: 3, lineWidth: 1)
            )
                .frame(width: 12, height: 12)
                .foregroundColor(.secondary)
        }
    }
    
    func numberView(_ int: Int) -> some View {
        Text("\(int)")
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
            )
    }
}

struct ImagesSummaryPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
//        let viewModel = FoodFormViewModel.mock(for: [.pumpkinSeeds])
        let viewModel = FoodFormViewModel.mockWith5Images
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        FormStyledScrollView {
            FormStyledSection {
                ImagesSummary()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct ImagesSummary_Previews: PreviewProvider {
    static var previews: some View {
        ImagesSummaryPreview()
    }
}
