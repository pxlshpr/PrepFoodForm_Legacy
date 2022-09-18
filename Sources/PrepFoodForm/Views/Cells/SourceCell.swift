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
        }
    }
    
    func activityButton(text: String) -> some View {
        Button {
            
        } label: {
            HStack {
                Text(text)
//                    .foregroundColor(.primary)
                Spacer()
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots(count: 3, inset: 2))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .equalizer(count: 5))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .gradient([.white, .accentColor], lineWidth: 3))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .arcs(count: 3, lineWidth: 2))
//                    ActivityIndicatorView(isVisible: $viewModel.isScanning, type: .flickeringDots(count: 8))
                    .frame(width: 20.0, height: 20.0)
            }
        }
    }
    
    @ViewBuilder
    var scanContent: some View {
        if viewModel.isScanning {
            activityButton(text: "Processing Images")
        }
    }
    
    @ViewBuilder
    var importContent: some View {
        if viewModel.isImporting {
            activityButton(text: "Importing Food")
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
