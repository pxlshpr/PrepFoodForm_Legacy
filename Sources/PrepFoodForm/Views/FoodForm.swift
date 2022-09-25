import SwiftUI
import CameraImagePicker
import SwiftHaptics

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingThirdPartyInfo = false
    @State var showingThirdPartySearch = false
    @State var showingWizard: Bool
    
    public init() {
        _viewModel = StateObject(wrappedValue: FoodFormViewModel.shared)
        _showingWizard = State(wrappedValue: !FoodFormViewModel.shared.hasData)
    }
    
    public var body: some View {
        NavigationView {
            content
                .navigationTitle("New Food")
                .interactiveDismissDisabled(viewModel.hasData)
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            form
            saveButtons
        }
    }
    
    @ViewBuilder
    var saveButtons: some View {
        if viewModel.hasData {
            VStack(spacing: 0) {
                Divider()
                VStack {
                    if viewModel.shouldShowSavePublicButton {
                        FormPrimaryButton(title: "Add to Public Database") {
                            dismiss()
                        }
                        .padding(.top)
                        FormSecondaryButton(title: "Add to Private Database") {
                            dismiss()
                        }
                    } else {
                        FormPrimaryButton(title: "Add to Private Database") {
                            dismiss()
                        }
                        .padding(.top)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    @ViewBuilder
    var form: some View {
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
                        //TODO: Change this to new navigation layout
//                        viewModel.path.append(.foodForm)
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
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }
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

