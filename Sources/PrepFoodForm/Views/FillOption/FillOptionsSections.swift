import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import MFPScraper
import PrepUnits
import SwiftUISugar
import ActivityIndicatorView

struct NutritionFactsPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .spinach)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            FoodForm.NutritionFacts()
                .environmentObject(viewModel)
                .navigationTitle("Nutrition Facts")
        }
    }
}

struct EnergyForm_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsPreview()
    }
}

struct FoodFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .pumpkinSeeds)
        FoodFormViewModel.shared = viewModel
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        FoodForm()
            .environmentObject(viewModel)
    }
}

struct FoodForm_Previews: PreviewProvider {
    static var previews: some View {
        FoodFormPreview()
    }
}

extension SizeForm {
    
    var form_test: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                SizeFormField(sizeViewModel: sizeViewModel, existingSizeViewModel: existingSizeViewModel)
                    .environmentObject(viewModel)
                    .environmentObject(formViewModel)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(.secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
//                if sizeViewModel.sizeAmountUnit.unitType == .weight || !sizeViewModel.sizeAmountIsValid {
//                    volumePrefixSection
//                }
                Group {
                    if viewModel.shouldShowFillOptions(for: sizeViewModel.fieldValue) {
                        Group {
                            if let image = sizeViewModel.imageToDisplay {
                                Group {
                                    if sizeViewModel.isCroppingNextImage {
                                        ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(.tertiaryLabel))
                                    } else {
                                        Group {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 350)
                                                .fixedSize()
                                                .clipShape(
                                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                )
                                                .shadow(radius: 3, x: 0, y: 3)
                                                .padding(.top, 5)
                                                .padding(.bottom, 8)
                                                .padding(.horizontal, 3)
                                        }
//                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            } else {
                                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(.secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all) /// requireds to cover the area that would be covered by the keyboard during its dismissal animation
        )
    }
    
    var form: some View {
        FormStyledScrollView {
            FormStyledSection {
                SizeFormField(sizeViewModel: sizeViewModel, existingSizeViewModel: existingSizeViewModel)
                    .environmentObject(viewModel)
                    .environmentObject(formViewModel)
            }
            if sizeViewModel.sizeAmountUnit.unitType == .weight || !sizeViewModel.sizeAmountIsValid {
                volumePrefixSection
            }
            fillOptionsSections
        }
    }
}
struct FillOptionsSections: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingAutofillInfo = false
    @ObservedObject var fieldViewModel: FieldViewModel
    @Binding var shouldAnimate: Bool
    
    @State var showingPrefillSource = false
    
    var didTapImage: () -> ()
    var didTapFillOption: (FillOption) -> ()

    var body: some View {
        Group {
            if viewModel.shouldShowFillOptions(for: fieldViewModel.fieldValue) {
                gridSection
                supplementarySection
            }
        }
        .sheet(isPresented: $showingAutofillInfo) {
            AutofillInfoSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    var gridSection: some View {
        FormStyledSection(header: autofillHeader) {
            grid
        }
    }
    
    var grid: some View {
        FillOptionsGrid(
            fieldViewModel: fieldViewModel,
            shouldAnimate: $shouldAnimate
        ) { fillOption in
            didTapFillOption(fillOption)
        }
    }
    
    var shouldShowSupplementarySection: Bool {
        if fieldViewModel.imageToDisplay != nil {
            return true
        }
        
        if fieldViewModel.prefillUrl != nil, fieldViewModel.isPrefilled {
            return true
        }
        
        return false
    }

    @ViewBuilder
    var supplementarySection_test: some View {
        Group {
            if let image = fieldViewModel.imageToDisplay {
                imageSection(for: image)
            } else {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    var supplementarySection: some View {
        if shouldShowSupplementarySection {
            FormStyledSection {
                if let image = fieldViewModel.imageToDisplay {
                    imageSection(for: image)
                        .fixedSize(horizontal: true, vertical: false)
                }
                if let prefillUrl = fieldViewModel.prefillUrl {
                    prefillSection(for: prefillUrl)
                }
            }
        }
    }
    
    func prefillSection(for prefillUrl: String) -> some View {
//        Button {
//            showingPrefillSource = true
        NavigationLink {
            SourceWebView(urlString: prefillUrl)
        } label: {
            HStack {
                Label("MyFitnessPal", systemImage: "link")
                    .foregroundColor(.accentColor)
                Spacer()
            }
        }
        .sheet(isPresented: $showingPrefillSource) {
            SourceWebView(urlString: prefillUrl)
        }
    }

    @ViewBuilder
    func imageSection(for image: UIImage) -> some View {
        Group {
            if fieldViewModel.isCroppingNextImage {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                croppedImageButton(for: image)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var autofillHeader: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingAutofillInfo = true
        } label: {
            HStack {
                Text("Autofill")
                Image(systemName: "info.circle")
                    .foregroundColor(.accentColor)
            }
//            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func croppedImageButton(for image: UIImage) -> some View {
        if fieldViewModel.fieldValue.supportsSelectingText {
            Button {
                didTapImage()
            } label: {
                imageView(for: image)
            }
            .buttonStyle(.borderless)
        } else {
            imageView(for: image)
        }
    }
    
    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 350)
            .fixedSize()
            .clipShape(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.top, 5)
            .padding(.bottom, 8)
            .padding(.horizontal, 3)
    }
    
    var sampleImage: UIImage? {
        PrepFoodForm.sampleImage(imageFilename: "energy1")
    }
}

//MARK: - Preview

public struct FillOptionSectionsPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    @State var string: String
    @State var shouldAnimate: Bool = true
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
        _string = State(initialValue: viewModel.energyViewModel.fieldValue.energyValue.string)
    }
    
    var fieldSection: some View {
        Section("Enter or auto-fill a value") {
            HStack {
                TextField("Required", text: $string)
            }
        }
    }
    
    var optionsSections: some View {
        FillOptionsSections(fieldViewModel: viewModel.energyViewModel,
                           shouldAnimate: $shouldAnimate,
                           didTapImage: {
            
        }, didTapFillOption: { fillOption in
            
        })
        .environmentObject(viewModel)
    }
    
    public var scrollView: some View {
        FormStyledScrollView {
            fieldSection
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            optionsSections
        }
    }
    public var body: some View {
        NavigationView {
//            form
            scrollView
        }
        .onChange(of: viewModel.energyViewModel.fieldValue.energyValue.double) { newValue in
            string = newValue?.cleanAmount ?? ""
        }
        .onChange(of: string) { newValue in
            withAnimation {
                viewModel.energyViewModel.fieldValue.energyValue.fill = .userInput
            }
        }
    }
}

struct FillOptionSections_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionSectionsPreview()
    }
}

