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
                self.title = String(htmlEncodedString: htmlTitle)
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
                self.faviconImage = image
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
            maxSelectionCount: 5,
            matching: .images
        )
    }
    
    var notChosenContentSection: some View {
        FormStyledSection(header: header, footer: footer) {
            Button {
                viewModel.showingSourceMenu = true
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
                            .padding(.leading, 17)
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
    
    var photosPickerButton: some View {
        Button {
            showingPhotosPicker = true
        } label: {
            Label("Choose Photos", systemImage: SourceType.images.systemImage)
        }
    }
    
    var cameraButton: some View {
        Button {
            viewModel.showingCamera = true
        } label: {
            Label("Take Photo", systemImage: "camera")
        }
    }
    
    var addALinkButton: some View {
        Button {
            
        } label: {
            Label("Add a Link", systemImage: "link")
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
                    Text("Scanned")
                    numberView(viewModel.scannedNutrientCount)
                    Text("nutrition facts")
                } else {
                    Text(viewModel.imageSetStatusString)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            if viewModel.imageSetStatus.isWorking {
                ActivityIndicatorView(
                    isVisible: .constant(true),
                    type: .arcs(count: 3, lineWidth: 1)
                )
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
