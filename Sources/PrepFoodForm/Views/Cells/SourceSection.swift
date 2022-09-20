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
        
        return HStack {
            Text("Optional")
                .foregroundColor(Color(.tertiaryLabel))
            Spacer()
            Menu {
                Button("Images") {
                    viewModel.sourceType = .images
                    viewModel.path.append(.sourceForm)
                }
                Button("Link") {
                    viewModel.sourceType = .link
                    viewModel.path.append(.sourceForm)
                }
            } label: {
                Text(title)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    var chosenContent: some View {
        Button {
            viewModel.path.append(.sourceForm)
        } label: {
            HStack(alignment: .top) {
                Text(viewModel.sourceType.description)
                Spacer()
                Group {
                    if viewModel.sourceType == .images {
                        Text("17 nutrition facts")
                            .multilineTextAlignment(.trailing)
                    } else if viewModel.sourceType == .link {
                        Text(verbatim: "https://www.myfitnesspal.com/food/calories/banan-1511734581")
                            .lineLimit(1)
                            .frame(maxWidth: 200, alignment: .trailing)
                    }
                }
                .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
                    .imageScale(.small)
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(.borderless)
    }
    
    var header: some View {
        Text("Source")
    }
    
    var footer: some View {
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
        viewModel.isImporting = true
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
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
