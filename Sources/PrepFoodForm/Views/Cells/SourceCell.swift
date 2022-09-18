import SwiftUI
import ActivityIndicatorView

extension FoodForm {
    struct SourceCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
    }
}

extension FoodForm.SourceCell {
    
    @ViewBuilder
    var body: some View {
        if let source = viewModel.sourceType {
            content(for: source)
        } else {
            Text("Optional")
                .foregroundColor(Color(.quaternaryLabel))
        }
    }
    
    @ViewBuilder
    func content(for source: SourceType) -> some View {
        switch source {
        case .scan:
            scanContent
        case .thirdPartyImport:
            importContent
        case .image:
            Text("Image")
        case .link:
            Text("Link")
        case .manualEntry:
            Text("Manual Entry")
        }
    }
    
    @ViewBuilder
    var scanContent: some View {
        if viewModel.isScanning {
            FormActivityButton(title: "Processing Images") {
            }
        }
    }
    
    @ViewBuilder
    var importContent: some View {
        if viewModel.isImporting {
            FormActivityButton(title: "Importing Food") {
            }
        }
    }
}

struct SourceCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    init() {
        let viewModel = FoodFormViewModel()
        viewModel.isImporting = true
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                FoodForm.SourceCell()
                    .environmentObject(viewModel)
            }
            .navigationTitle("Source Cell Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SourceCell_Previews: PreviewProvider {
    static var previews: some View {
        SourceCellPreview()
    }
}
