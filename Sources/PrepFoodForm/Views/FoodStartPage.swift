import SwiftUI

public struct FoodFormStartPage: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingImport = false
    
    public init() {
        FoodFormViewModel.shared = FoodFormViewModel()
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
            scanSection
            importSection
            manualEntrySection
        }
    }
    
    var manualEntrySection: some View {
        var header: some View {
            Text("Manual entry")
        }
        var footer: some View {
            Text("Manually enter in details from a nutrition fact label or elsewhere.")
        }
        
        return Section {
            NavigationLinkButton {
                viewModel.path.append(.foodForm)
            } label: {
                Label("Enter details",
                      systemImage: "character.cursor.ibeam")
            }
        }
    }
    
    var scanSection: some View {
        var header: some View {
            Text("Scan images")
        }
        var footer: some View {
            Text("Scan nutrition fact labels or screenshots from other apps to read in their data.")
        }
        
        return Section(header: header, footer: footer) {
            Button {
                showingScan = true
            } label: {
                Label("Scan",
                      systemImage: "text.viewfinder")
            }
        }
    }
    
    var importSection: some View {
        var header: some View {
            Text("Import an online source")
        }
        var footer: some View {
            VStack {
                Text("Use data from a third-party source when you need to roughly estimate the nutrition facts for this food. This method is slow and the data can sometimes be unreliable.")
            }
        }
        
        return Section(header: header, footer: footer) {
            Button {
                showingImport = true
            } label: {
                Label("Import",
                      systemImage: "link")
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
        }
    }
}
