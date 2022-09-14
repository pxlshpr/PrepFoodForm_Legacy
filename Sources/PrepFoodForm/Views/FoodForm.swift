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

    @StateObject var viewModel = ViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            contents
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .amountUnitSelector:
                        UnitPicker(pickedUnit: viewModel.amountUnit) { unit in
                            viewModel.amountUnit = unit
                        }
                    case .servingUnitSelector:
                        UnitPicker(pickedUnit: viewModel.servingUnit, includeServing: false) { unit in
                            viewModel.servingUnit = unit
                        }
                    case .nutrientsPerForm:
                        ServingForm(viewModel: viewModel)
                    case .detailsForm:
                        DetailsForm(viewModel: viewModel)
                    case .nutrientsList:
                        NutrientsList()
                    case .sourceForm:
                        SourceForm()
                    case .detailsFormEmoji:
                        FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji)
                    case .densityForm:
                        DensityForm()
                    }
                }
        }
        .sheet(isPresented: $isPresentingDetails) {
            FoodForm.DetailsForm(viewModel: viewModel)
        }
        .sheet(isPresented: $isPresentingNutrientsPer) {
            FoodForm.ServingForm(viewModel: viewModel)
        }
        .sheet(isPresented: $isPresentingNutrients) {
            FoodForm.NutrientsList()
        }
        .sheet(isPresented: $isPresentingSource) {
            FoodForm.SourceForm()
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
        Button {
//            tappedAdd()
        } label: {
            Text("Save")
                .bold()
                .foregroundColor(.white)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.accentColor)
                )
                .padding(.horizontal)
                .padding(.horizontal)
        }
//        .disabled(name.isEmpty)
    }

    var savePrivatelyButton: some View {
        Button {
            
        } label: {
            Text("Save Privately")
                .bold()
                .foregroundColor(.accentColor)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.clear)
                )
                .padding(.horizontal)
                .padding(.horizontal)
                .contentShape(Rectangle())
        }
//        .disabled(name.isEmpty)
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
                DetailsCell(viewModel: viewModel)
            }
        }
    }
    
    var servingSection: some View {
        Section("Nutrients per") {
            NavigationLinkButton {
                viewModel.path.append(.nutrientsPerForm)
            } label: {
                ServingCell(viewModel: viewModel)
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
