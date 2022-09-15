import SwiftUI
import CameraImagePicker

public struct FoodForm: View {
    
    @State public var isPresentingDetails = false
    @State public var isPresentingNutrientsPer = false
    @State public var isPresentingNutrients = false
    @State public var isPresentingSource = false
    @State public var isPresentingFoodLabelScanner = false
    
    @State public var capturedImage: UIImage? = nil
    @State public var capturedImages: [UIImage] = []

    @StateObject var viewModel: ViewModel
    
    public init(prefilledWithMockData: Bool = false, onlyServing: Bool = false) {
        let viewModel = ViewModel(prefilledWithMockData: prefilledWithMockData, onlyServing: onlyServing)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            contents
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .nutrientsPerForm:
                        NutrientsPerForm()
                            .environmentObject(viewModel)
                    case .detailsForm:
                        DetailsForm()
                            .environmentObject(viewModel)
                    case .nutrientsList:
                        NutrientsList()
                    case .sourceForm:
                        SourceForm()
                    case .detailsFormEmoji:
                        FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji)
                    case .densityForm:
                        FoodForm.NutrientsPerForm.DensityForm(orderWeightFirst: viewModel.isWeightBased)
                            .environmentObject(viewModel)
                    case .sizesList:
                        SizesList()
                            .environmentObject(viewModel)
                    }
                }
        }
        .sheet(isPresented: $isPresentingFoodLabelScanner) {
            CameraImagePicker(capturedImage: $capturedImage)
        }
        .onChange(of: capturedImage) { newValue in
            guard let image = newValue else {
                return
            }
            capturedImages.append(image)
            capturedImage = nil
        }
    }
    
    var contents: some View {
        VStack {
            formNavigationView
            savePublicallyButton
            savePrivatelyButton
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("New Food")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var savePublicallyButton: some View {
        FormPrimaryButton(title: "Save") {
            
        }
    }

    var savePrivatelyButton: some View {
        FormSecondaryButton(title: "Save Privately") {
            
        }
    }

    var formNavigationView: some View {
        Form {
            detailsSection
            servingSection
            nutrientsSection
            sourceSection
            imagesSection
        }
    }
    
    //MARK: - Sections
    
    var detailsSection: some View {
        Section("Details") {
            NavigationLinkButton {
                viewModel.path.append(.detailsForm)
            } label: {
                DetailsCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var servingSection: some View {
        Section("Nutrients per") {
            NavigationLinkButton {
                viewModel.path.append(.nutrientsPerForm)
            } label: {
                NutrientsPerCell()
                    .environmentObject(viewModel)
            }
        }

    }
    
    var nutrientsSection: some View {
        Section("Nutrients") {
            NavigationLinkButton {
                viewModel.path.append(.nutrientsList)
            } label: {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
    
    var sourceSection: some View {
        Section("Source") {
            NavigationLinkButton {
                viewModel.path.append(.sourceForm)
            } label: {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    
    @ViewBuilder
    var imagesSection: some View {
        if !capturedImages.isEmpty {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(capturedImages, id: \.self) { image in
                            Menu {
                                Button("View") {
                                    
                                }
                                Button(role: .destructive) {
                                    
                                } label: {
                                    Text("Delete")
                                }
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                    .shadow(radius: 1.0)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    var servingCell: some View {
        Text("Set serving")
    }
    
    var nutrientsCell: some View {
        FoodForm.NutrientsCell()
    }
    
    var foodLabelScanCell: some View {
//        Label("Scan food label", systemImage: "text.viewfinder")
        HStack {
            Text("Scan food label")
            Spacer()
            Image(systemName: "text.viewfinder")
        }
    }
    
    var sourceCell: some View {
        Text("Add source")
    }
    
    func addDummyImageForSimulator() {
        guard capturedImages.isEmpty,
              let image = UIImage(named: "Test Image 1")
        else {
            return
        }
        capturedImages = [image]
    }
}
