import SwiftUI
import CameraImagePicker

public struct FoodFormStartPage: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingImport = false
    
    public init() {
//        FoodFormViewModel.shared = FoodFormViewModel()
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
        }
    }
    
    var contents: some View {
        Form {
            imageSection
            importSection
            manualEntrySection
        }
    }
    
    var manualEntrySection: some View {
        var header: some View {
            Text(SourceType.manualEntry.headerString)
        }
        var footer: some View {
            Text(SourceType.manualEntry.footerString)
        }
        
        return Section {
            NavigationLinkButton {
                viewModel.path.append(.foodForm)
            } label: {
                Label(SourceType.manualEntry.actionString,
                      systemImage: SourceType.manualEntry.systemImage)
            }
        }
    }
    
    var imageSection: some View {
        var header: some View {
            Text(SourceType.images.headerString)
        }
        var footer: some View {
            Text(SourceType.images.footerString)
        }
        
        return Section(header: header, footer: footer) {
            Button {
                showingScan = true
            } label: {
                Label(SourceType.images.actionString,
                      systemImage: SourceType.images.systemImage)
            }
        }
    }
    
    var importSection: some View {
        var header: some View {
            Text(SourceType.onlineSource.headerString)
        }
        var footer: some View {
            VStack {
                Text(SourceType.onlineSource.footerString)
            }
        }
        
        return Section(header: header, footer: footer) {
            Button {
                showingImport = true
            } label: {
                Label(SourceType.onlineSource.actionString,
                      systemImage: SourceType.onlineSource.systemImage)
            }
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
        }
    }
}

