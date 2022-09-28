import SwiftUI
import ActivityIndicatorView

extension FoodForm {
    struct SourceSection: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
    }
}

extension FoodForm.SourceSection {
    
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
                ForEach(viewModel.imageViewModels, id: \.self) { imageViewModel in
                    SourceImage(imageViewModel: imageViewModel, width: 55, height: 55)
                }
            }
//        }
    }
    
    var imageSetStatusString: String {
        switch viewModel.imageSetStatus {
        case .loading:
            return "Loading images"
        case .classifying:
            return "Detecting nutrition facts"
        case .classified:
            return "\(viewModel.classifiedNutrientCount) nutrition facts detected"
        default:
            return "(not handled)"
        }
    }
    
    var imageSetStatus: some View {
        Text(imageSetStatusString)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    Text("Provide a source if you want this food to be eligible for the public database and award you member points.")
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

struct SourceCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    init() {
        let viewModel = FoodFormViewModel()
        viewModel.simulateImageSelection()
//        viewModel.isImporting = true
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Form {
                FoodForm.SourceSection()
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
