import SwiftUI
import CameraImagePicker
import SwiftHaptics
import PrepUnits

let WizardAnimation = Animation.interpolatingSpring(mass: 0.5, stiffness: 120, damping: 10, initialVelocity: 2)

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FoodFormViewModel
    @State var showingScan = false
    @State var showingThirdPartyInfo = false
    
    public init() {
        _viewModel = StateObject(wrappedValue: FoodFormViewModel.shared)
    }
    
    public var body: some View {
        NavigationView {
            content
                .navigationTitle("New Food")
                .interactiveDismissDisabled(viewModel.hasData)
                .onAppear {
                    DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.6) {
                        Haptics.transientHaptic()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(WizardAnimation) {
                            if viewModel.shouldShowWizard {
                                viewModel.showingWizard = true
                                viewModel.shouldShowWizard = false
                            }
                        }
                    }
                }
        }
    }
    
    var content: some View {
        ZStack {
            form
                .safeAreaInset(edge: .bottom) {
                    //TODO: Programmatically get this inset (67516AA6)
                    Spacer().frame(height: 135)
                }
                .overlay(
                    Color(.quaternarySystemFill)
                        .opacity(viewModel.showingWizard ? 0.3 : 0)
//                        .onTapGesture {
//                            Haptics.successFeedback()
//                            withAnimation(wizardAnimation) {
//                                showingWizard = false
//                            }
//                        }
                )
                .blur(radius: viewModel.showingWizard ? 5 : 0)
                .disabled(viewModel.showingWizard)
//            dismissTapGesture
            wizard
            VStack {
                Spacer()
                saveButtons
            }
        }
        .sheet(isPresented: $viewModel.showingThirdPartySearch) {
            MFPSearch()
                .environmentObject(viewModel)
        }
    }
    
    @ViewBuilder
    var wizard: some View {
        if viewModel.showingWizard {
            VStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        startWithEmptyFood()
                    }
                Form {
                    manualEntrySection
                    imageSection
                    thirdPartyFoodSection
                }
//                .scrollContentBackground(.hidden)
//                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .frame(height: 400)
                .frame(maxWidth: 350)
                .padding(.horizontal, 30)
                .shadow(color: colorScheme == .dark ? .black : .gray, radius: 30, x: 0, y: 0)
                .opacity(viewModel.showingWizard ? 1 : 0)
    //            .padding(.bottom)
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        startWithEmptyFood()
                    }
            }
            .zIndex(1)
            .transition(.move(edge: .bottom))
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
//            .background(Color(.systemGroupedBackground))
            .background(.thinMaterial)
        }
    }

    @ViewBuilder
    var form: some View {
        Form {
            detailsSection
            servingSection
            foodLabelSection
            sourceSection
            prefillSection
        }
    }
    
    func startWithEmptyFood() {
        Haptics.transientHaptic()
        withAnimation(WizardAnimation) {
            viewModel.showingWizard = false
        }
    }
    
    //MARK: - Wizard Contents
    var manualEntrySection: some View {
        Section("Start with an empty food") {
            Button {
                startWithEmptyFood()
            } label: {
                Label("Empty Food", systemImage: "square.and.pencil")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
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
//                showingScan = true
                viewModel.simulateImageSelection()
            } label: {
                Label("Choose Images", systemImage: SourceType.images.systemImage)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            Button {
//                showingScan = true
                viewModel.simulateImageSelection()
            } label: {
                Label("Take Photos", systemImage: "camera")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
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
//                viewModel.showingThirdPartySearch = true
                viewModel.simulateThirdPartyImport()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
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
                    .buttonStyle(.borderless)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var sourceSection: some View {
        FoodForm.SourceSection()
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var prefillSection: some View {
        if let url = viewModel.prefilledFood?.sourceUrl {
            Section("Prefilled Food") {
                NavigationLink {
                    SourceWebView(urlString: url)
                } label: {
                    Label("MyFitnessPal", systemImage: "link")
                        .foregroundColor(.accentColor)
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
}

struct FoodFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel.shared
    
    var body: some View {
        FoodForm()
            .environmentObject(viewModel)
            .onAppear {
                viewModel.prefill(MockProcessedFood.Banana)
            }
    }
}

struct FoodForm_Previews: PreviewProvider {
    static var previews: some View {
        FoodFormPreview()
    }
}

import Foundation
import MFPScraper

extension FoodFormViewModel {
    
    func simulateThirdPartyImport() {
        prefill(MockProcessedFood.Banana)
    }
    
    func simulateAddingImage(_ number: Int) {
        let image = labelImage(number)!

        let imageViewModel = ImageViewModel(image)
        imageViewModels.append(imageViewModel)
    }
    
    func simulateImageSelection() {
        
        sourceType = .images
        imageSetStatus = .classifying
        
//        simulateAddingImage(6)
        simulateAddingImage(1)
        simulateAddingImage(2)
        simulateAddingImage(3)
        simulateAddingImage(4)

        withAnimation {
            showingWizard = false
        }
    }
    
    func prefill(_ food: MFPProcessedFood) {

        self.showingThirdPartySearch = false

        prefillDetails(from: food)
        
        /// Create sizes first as we might have one as the amount or serving unit
        prefillSizes(from: food)
        
        prefillAmountPer(from: food)
        prefillDensity(from: food)
        prefillNutrients(from: food)
        
        prefilledFood = food
        
        withAnimation {
            showingWizard = false
        }
    }
    
    func prefillDetails(from food: MFPProcessedFood) {
        if !food.name.isEmpty {
            name = FieldValue.name(FieldValue.StringValue(string: food.name, fillType: .thirdPartyFoodPrefill))
        }
        if let detail = food.detail, !detail.isEmpty {
            self.detail = FieldValue.detail(FieldValue.StringValue(string: detail, fillType: .thirdPartyFoodPrefill))
        }
        if let brand = food.brand, !brand.isEmpty {
            self.brand = FieldValue.brand(FieldValue.StringValue(string: brand, fillType: .thirdPartyFoodPrefill))
        }
    }

    func prefillSizes(from food: MFPProcessedFood) {
        
    }

    func prefillAmountPer(from food: MFPProcessedFood) {
        prefillAmount(from: food)
        prefillServing(from: food)
    }
    
    func prefillAmount(from food: MFPProcessedFood) {
        guard food.amount > 0 else {
            return
        }
        
        let size: Size?
        if case .size(let mfpSize) = food.amountUnit {
            size = nil
        } else {
            size = nil
        }
        
        self.amount = FieldValue.amount(FieldValue.DoubleValue(
            double: food.amount,
            string: food.amount.cleanAmount,
            unit: food.amountUnit.formUnit(withSize: size),
            fillType: .thirdPartyFoodPrefill)
        )
    }
    
    func prefillDensity(from food: MFPProcessedFood) {
    }
    
    func prefillServing(from food: MFPProcessedFood) {
    }
    
    func prefillNutrients(from food: MFPProcessedFood) {
        self.energy = food.energyFieldValue
        self.carb = food.carbFieldValue
        self.fat = food.fatFieldValue
        self.protein = food.proteinFieldValue
    }
}

extension MFPProcessedFood {
    var energyFieldValue: FieldValue {
        .energy(FieldValue.EnergyValue(double: energy, string: energy.cleanAmount, unit: .kcal, fillType: .thirdPartyFoodPrefill))
    }
    
    func macroFieldValue(macro: Macro, double: Double) -> FieldValue {
        .macro(FieldValue.MacroValue(macro: macro, double: double, string: double.cleanAmount, fillType: .thirdPartyFoodPrefill))
    }
    
    var carbFieldValue: FieldValue {
        macroFieldValue(macro: .carb, double: carbohydrate)
    }
    var fatFieldValue: FieldValue {
        macroFieldValue(macro: .fat, double: fat)
    }

    var proteinFieldValue: FieldValue {
        macroFieldValue(macro: .protein, double: protein)
    }
}

extension AmountUnit {
    func formUnit(withSize size: Size? = nil) -> FormUnit {
        switch self {
        case .weight(let weightUnit):
            return .weight(weightUnit)
        case .volume(let volumeUnit):
            return .volume(volumeUnit)
        case .serving:
            return .serving
        case .size:
            /// We should have had a size (pre-created from the actual `MFPProcessedFood.Size`) and passed into this function—otherwise fallback to a serving unit
            guard let size else {
                return .serving
            }
            return .size(size, nil)
        }
    }
}
