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
        
//        navigationStack
        navigationView
            .sheet(isPresented: $isPresentingDetails) {
                FoodForm.DetailsForm(viewModel: viewModel)
            }
            .sheet(isPresented: $isPresentingNutrientsPer) {
                FoodForm.NutrientsPerForm()
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
    
    var navigationStack: some View  {
        NavigationStack {
            formNavigationView
                .navigationBarTitle("New Food")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var navigationView: some View {
        NavigationView {
            formNavigationView
                .navigationBarTitle("New Food")
                .navigationBarTitleDisplayMode(.inline)
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
            Button {
                isPresentingDetails = true
            } label: {
                DetailsCell(viewModel: viewModel)
            }
        }
    }
    
    var servingSection: some View {
        Section("Nutrients Per") {
            Button {
                isPresentingNutrientsPer = true
            } label: {
                servingCell
            }
        }

    }
    
    var nutrientsSection: some View {
        Group {
            Section("Nutrients") {
                Button {
                    isPresentingNutrients = true
                } label: {
                    nutrientsCell
                }
                Button {
                    #if targetEnvironment(simulator)
                    addDummyImageForSimulator()
                    #else
                    isPresentingFoodLabelScanner = true
                    #endif
                } label: {
                    foodLabelScanCell
                }
            }
        }
    }
    
    var sourceSection: some View {
        Section("Source") {
            Button {
                isPresentingSource = true
            } label: {
                sourceCell
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
        Text("Set serving size")
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
