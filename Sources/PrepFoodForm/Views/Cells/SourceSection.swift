import SwiftUI
import ActivityIndicatorView

struct SourceSection: View {
    @ObservedObject var viewModel: FoodFormViewModel
    
    var body: some View {
        Section(header: header, footer: footer) {
            if viewModel.sourceType == .manualEntry {
                notChosenContent
            } else {
                chosenContent
            }
        }
    }
    
    var notChosenContent: some View {
        var title: String {
            if viewModel.sourceType == .manualEntry {
                return "Choose"
            } else {
                return viewModel.sourceType.description
            }
        }
        
        return Menu {
            Button("Images") {
                viewModel.sourceType = .images
                //TODO: We need to pass this back to the form
//                viewModel.path.append(.sourceForm)
            }
            Button("Link") {
                viewModel.sourceType = .link
                //TODO: We need to pass this back to the form
//                viewModel.path.append(.sourceForm)
            }
        } label: {
            Text("Optional")
                .foregroundColor(Color(.tertiaryLabel))
            Spacer()
            Text(title)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    var chosenContent: some View {
        NavigationLink {
            FoodForm.SourceForm()
                .environmentObject(viewModel)
        } label: {
            switch viewModel.sourceType {
            case .images:
                VStack(alignment: .leading, spacing: 15) {
                    imagesGrid
                    imageSetStatus
                }
            default:
                Text("Not handled")
            }
//            HStack(alignment: .top) {
//                Text(viewModel.sourceType.description)
//                    .foregroundColor(.primary)
//                Spacer()
//                Group {
//                    if viewModel.sourceType == .images {
//                        Text("17 nutrition facts extracted")
//                            .multilineTextAlignment(.trailing)
//                    } else if viewModel.sourceType == .link {
//                        Text(verbatim: "https://www.myfitnesspal.com/food/calories/banan-1511734581")
//                            .lineLimit(1)
////                            .frame(maxWidth: 200, alignment: .trailing)
//                    }
//                }
//                .foregroundColor(.secondary)
//            }
        }
    }
    
    var imagesGrid: some View {
//        GeometryReader { geometry in
            HStack {
                ForEach(viewModel.imageViewModels, id: \.self.hashValue) { imageViewModel in
                    SourceImage(imageViewModel: imageViewModel, width: 55, height: 55)
                }
            }
//        }
    }
    
    var imageSetStatus: some View {
        func numberView(_ int: Int) -> some View {
            Text("\(int)")
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
        }
        return HStack {
            Group {
                if viewModel.imageSetStatus == .scanned {
                    Image(systemName: "text.viewfinder")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundColor(Color(.tertiaryLabel))
                    numberView(viewModel.scannedNutrientCount)
                    Text("facts in")
                    numberView(viewModel.scannedColumnCount)
                    Text("column\(viewModel.scannedColumnCount > 1 ? "s" : "")")
                } else {
                    Text(imageSetStatusString)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            if viewModel.imageSetStatus.isWorking {
                ActivityIndicatorView(isVisible: .constant(true), type: .arcs())
                    .frame(width: 12, height: 12)
                    .foregroundColor(.secondary)
            }
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

    var imageSetStatusString: String {
        switch viewModel.imageSetStatus {
        case .loading:
            return "Loading images"
        case .scanning:
            return "Detecting nutrition facts"
        case .scanned:
            return "facts detected"
        default:
            return "(not handled)"
        }
    }

    

    var header: some View {
        Text("Source")
    }
    
    @ViewBuilder
    var footer: some View {
        if viewModel.sourceType == .manualEntry {
            Button {
                
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Provide a source if you want this food to be eligible for the public database and earn member points.")
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.leading)
                    Label("Learn more", systemImage: "info.circle")
                }
                .font(.footnote)
            }
        }
    }
    
//    @ViewBuilder
//    var body: some View {
//        if viewModel.sourceType != .manualEntry {
//            content(for: viewModel.sourceType)
//        } else {
//            Text("Optional")
//                .foregroundColor(Color(.quaternaryLabel))
//        }
//    }
//
//    @ViewBuilder
//    func content(for source: SourceType) -> some View {
//        switch source {
////        case .scan:
////            scanContent
//        case .onlineSource:
//            importContent
//        case .images:
//            Text("Image")
//        case .link:
//            Text("Link")
//        case .manualEntry:
//            Text("Manual Entry")
//        }
//    }
//
//    @ViewBuilder
//    var scanContent: some View {
//        if viewModel.isScanning {
//            FormActivityButton(title: "Processing Images") {
//            }
//        }
//    }
//
//    @ViewBuilder
//    var importContent: some View {
//        if viewModel.isImporting {
//            FormActivityButton(title: "Importing Food") {
//            }
//        }
//    }
}

public struct SourceCellPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        FoodFormViewModel.shared = FoodFormViewModel()
        let viewModel = FoodFormViewModel.shared
        viewModel.simulateImageSelection()
//        viewModel.isImporting = true
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                SourceSection(viewModel: viewModel)
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

extension ImageStatus {
    var isWorking: Bool {
        switch self {
        case .loading, .scanning:
            return true
        default:
            return false
        }
    }
}
