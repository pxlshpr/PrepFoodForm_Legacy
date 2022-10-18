import SwiftUI
import ActivityIndicatorView
import PhotosUI
import SwiftHaptics
import SwiftUISugar

struct FavIcon {
    enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
    private let domain: String
    init(_ domain: String) { self.domain = domain }
    subscript(_ size: Size) -> String {
        "https://www.google.com/s2/favicons?sz=32&domain=\(domain)"
    }
}

extension String {

    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)

    }

}

class LinkInfo: ObservableObject {
    let url: URL
    @Published var title: String?
    @Published var faviconImage: UIImage?
    
    var urlString: String {
        url.absoluteString
    }
    
    var urlDisplayString: String {
        url.host ?? urlString
    }
    
    init?(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
        self.title = nil
        self.faviconImage = nil
        getTitle()
        getFavicon()
    }
    
    func getTitle() {
        Task {
            let content = try String(contentsOf: url, encoding: .utf8)
            guard let htmlTitle = content.htmlTitle else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.title = String(htmlEncodedString: htmlTitle)
                }
            }
        }
    }
    
    func getFavicon() {
        let urlString = "https://www.google.com/s2/favicons?sz=32&domain=\(urlString)"
        guard let url = URL(string: urlString) else {
            return
        }
        Task {
            let request = URLRequest.init(url: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            await MainActor.run {
                withAnimation {
                    self.faviconImage = image
                }
            }
        }
    }
    
}

struct SourceSection: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingPhotosPicker = false
    
    var body: some View {
        
        Group {
            if viewModel.hasSources {
                chosenContentSection
            } else {
                notChosenContentSection
            }
        }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: viewModel.availableImagesCount,
            matching: .images
        )
    }
    
    var notChosenContentSection: some View {
        FormStyledSection(header: header, footer: footer) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.showingSourceMenu = true
                }
            } label: {
                Text("Add a source")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    var chosenContentSection: some View {
        FormStyledSection(header: header, footer: footer, horizontalPadding: 0, verticalPadding: 0) {
            NavigationLink {
                SourceForm()
                    .environmentObject(viewModel)
            } label: {
                VStack(spacing: 0) {
                    if viewModel.hasSourceImages {
                        HStack(alignment: .top, spacing: LabelSpacing) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.secondary)
                                .frame(width: LabelImageWidth)
                            VStack(alignment: .leading, spacing: 15) {
                                imagesGrid
                                imageSetStatus
                            }
                        }
                        .padding(.horizontal, 17)
                        .padding(.vertical, 15)
                        if viewModel.hasSourceLink {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                    if let linkInfo = viewModel.linkInfo {
                        LinkCell(linkInfo, titleColor: .secondary, imageColor: .secondary, detailColor: Color(.tertiaryLabel))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                    }
                }
            }
        }
    }

    var imagesGrid: some View {
//        GeometryReader { geometry in
            HStack {
                ForEach(viewModel.imageViewModels, id: \.self.hashValue) { imageViewModel in
                    SourceImage(imageViewModel: imageViewModel, imageSize: .small)
                }
            }
//        }
    }
    
    var imageSetStatus: some View {
        ImagesSummary()
            .environmentObject(viewModel)
    }

    var header: some View {
        Text("Sources")
    }
    
    @ViewBuilder
    var footer: some View {
        if !viewModel.hasSources {
            Button {
                
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Provide a source if you want this food to be eligible for the public database and earn member points.")
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.leading)
                    Label("Learn more", systemImage: "info.circle")
                        .foregroundColor(.accentColor)
                }
                .font(.footnote)
            }
        }
    }
}

public struct SourceCellPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    public init() {
        FoodFormViewModel.shared = FoodFormViewModel.mock(for: .pumpkinSeeds)
        let viewModel = FoodFormViewModel.shared
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            FormStyledScrollView {
                SourceSection()
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
