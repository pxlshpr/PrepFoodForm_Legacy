import SwiftUI
import CameraImagePicker
import SwiftHaptics

public struct FoodForm: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingThirdPartyInfo = false
    @State var showingThirdPartySearch = false
    @State var showingWizard = true
    
    public init() {
        _viewModel = StateObject(wrappedValue: FoodFormViewModel.shared)
    }
    
    public var body: some View {
        NavigationView {
            contents
                .navigationTitle("New Food")
                .interactiveDismissDisabled(viewModel.hasData)
        }
    }
    
    @ViewBuilder
    var contents: some View {
        Form {
            if showingWizard {
                manualEntrySection
                imageSection
                thirdPartyFoodSection
            } else {
                detailsSection
                servingSection
                foodLabelSection
                sourceSection
            }
        }
    }
    
    //MARK: - Wizard Contents
    var manualEntrySection: some View {
        Section("Start with an empty food") {
            Button {
                Haptics.successFeedback()
                withAnimation {
                    showingWizard = false
                }
            } label: {
                Label("Empty Food", systemImage: "square.and.pencil")
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    var imageSection: some View {
        var header: some View {
            Text("Scan food labels")
        }
        var footer: some View {
            Text("Provide images of nutrition fact labels or screenshots of other apps. These will be processed to extract any data from them. They will also be used to verify this food.")
        }
        
        return Section(header: header) {
            Button {
                showingScan = true
            } label: {
                Label("Choose Images", systemImage: SourceType.images.systemImage)
            }
            Button {
                showingScan = true
            } label: {
                Label("Take Photos", systemImage: "camera")
            }
        }
        .sheet(isPresented: $showingScan) {
            ScanForm()
                .environmentObject(viewModel)
                .onDisappear {
                    if viewModel.isScanning {
                        viewModel.path.append(.foodForm)
                    }
                }
        }
    }
    
    var thirdPartyFoodSection: some View {
        var header: some View {
            Text("Copy a third-party food")
        }
        var footer: some View {
            Button {
                showingThirdPartyInfo = true
            } label: {
                Label("Learn more", systemImage: "info.circle")
                    .font(.footnote)
            }
            .sheet(isPresented: $showingThirdPartyInfo) {
                MFPInfoSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        return Section(header: header, footer: footer) {
            Button {
                showingThirdPartySearch = true
//                viewModel.path.append(.mfpSearch)
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                Spacer()
//                Image(systemName: "chevron.right")
//                    .foregroundColor(Color(.tertiaryLabel))
//                    .imageScale(.small)
//                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderless)
        }
        .sheet(isPresented: $showingThirdPartySearch) {
            MFPSearch()
        }
    }
    
    //MARK: - FoodForm Contents
    
    var detailsSection: some View {
        Section("Details") {
            NavigationLink {
                DetailsForm()
                    .environmentObject(viewModel)
            } label: {
                DetailsCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var servingSection: some View {
        Section("Amount Per") {
            NavigationLink {
                NutrientsPerForm()
                    .environmentObject(viewModel)
                //TODO: Run this before going to the next screen
//                if !viewModel.hasNutrientsPerContent {
//                    /// If it's empty, prefill it before going to the screen
//                    viewModel.amountString = "1"
//                }
            } label: {
                NutrientsPerCell()
                    .environmentObject(viewModel)
            }
        }

    }
    
    var foodLabelSection: some View {
        @ViewBuilder
        var header: some View {
            if !viewModel.hasNutritionFacts {
                Text("Nutrition Facts")
            }
        }
        
        return Section(header: header) {
            NavigationLink {
                NutritionFacts()
                    .environmentObject(viewModel)
            } label: {
                NutritionFactsCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var sourceSection: some View {
        FoodForm.SourceSection()
            .environmentObject(viewModel)
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
}


//MARK: - Legacy (To Remove)
extension FoodForm {
    @ViewBuilder
    func navigationDestination(for route: FoodFormRoute) -> some View {
        switch route {
        case .foodForm:
            FoodForm()
                .environmentObject(viewModel)
        case .nutrientsPerForm:
            FoodForm.NutrientsPerForm()
                .environmentObject(viewModel)
        case .detailsForm:
            FoodForm.DetailsForm()
                .environmentObject(viewModel)
        case .nutritionFacts:
            FoodForm.NutritionFacts()
                .environmentObject(viewModel)
        case .sourceForm:
            FoodForm.SourceForm()
                .environmentObject(viewModel)
        case .detailsFormEmoji:
            FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji)
        case .densityForm:
            FoodForm.NutrientsPerForm.DensityForm(orderWeightFirst: viewModel.isWeightBased)
                .environmentObject(viewModel)
        
        case .amountForm:
            FoodForm.NutrientsPerForm.AmountForm()
                .environmentObject(viewModel)
        case .servingForm:
            FoodForm.NutrientsPerForm.ServingForm()
                .environmentObject(viewModel)
            
            
            
        case .sizesList:
            SizesList()
                .environmentObject(viewModel)
        case .nutritionFactForm(let type):
            FoodForm.NutritionFacts.FactForm(type: type)
                .environmentObject(viewModel)
        case .sourceImage(let sourceImageViewModel):
            SourceImageView(sourceImageViewModel: sourceImageViewModel)
                .environmentObject(viewModel)
        case .mfpSearch:
            MFPSearch()
        }
    }
}
