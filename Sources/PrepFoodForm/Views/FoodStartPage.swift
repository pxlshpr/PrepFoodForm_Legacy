import SwiftUI
import CameraImagePicker

public struct FoodFormStartPage: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingImport = false
    @State var showingThirdPartyInfo = false
    @State var showingThirdPartySearch = false
    
    public init() {
        _viewModel = StateObject(wrappedValue: FoodFormViewModel.shared)
    }
    
    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            contents
                .navigationTitle("Create Food")
                .navigationDestination(for: FoodFormRoute.self) { route in
                    navigationDestination(for: route)
                }
                .interactiveDismissDisabled(viewModel.hasData)
                .sheet(isPresented: $showingScan) {
                    ScanForm()
                        .environmentObject(viewModel)
                        .onDisappear {
                            if viewModel.isScanning {
                                viewModel.path.append(.foodForm)
                            }
                        }
                }
                .sheet(isPresented: $showingImport) {
                    ImportForm()
                        .environmentObject(viewModel)
                        .onDisappear {
                            if viewModel.isImporting {
                                viewModel.path.append(.foodForm)
                            }
                        }
                }
                .sheet(isPresented: $showingThirdPartyInfo) {
                    MFPInfoSheet()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
                .sheet(isPresented: $showingThirdPartySearch) {
                    MFPSearch()
                }
        }
    }
    
    var contents: some View {
        Form {
            manualEntrySection
            imageSection
            importSection
        }
    }
    
    var manualEntrySection: some View {
        Section("Start with an empty food") {
            NavigationLinkButton {
                viewModel.path.append(.foodForm)
            } label: {
                Label("New Food", systemImage: "square.and.pencil")
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
    }
    
    var importSection: some View {
        var header: some View {
            Text("Start with a third-party food")
        }
        var footer: some View {
            Button {
                showingThirdPartyInfo = true
            } label: {
                Label("Learn more", systemImage: "info.circle")
                    .font(.footnote)
            }
        }
        
        return Section(header: header, footer: footer) {
            Button {
                showingThirdPartySearch = true
//                viewModel.path.append(.mfpSearch)
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
                    .imageScale(.small)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderless)
        }
    }
    
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

