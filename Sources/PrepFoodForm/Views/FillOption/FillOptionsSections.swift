import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import MFPScraper
import PrepUnits
import SwiftUISugar
import ActivityIndicatorView

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
                FormStyledSection(header: autofillHeader) {
                    FillOptionsGrid(
                        fieldViewModel: fieldViewModel,
                        shouldAnimate: $shouldAnimate
                    ) { fillOption in
                        didTapFillOption(fillOption)
                    }
                }
                supplementarySection
            }
        }
        .sheet(isPresented: $showingAutofillInfo) {
            AutofillInfoSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
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
    var supplementarySection: some View {
        if shouldShowSupplementarySection {
            FormStyledSection {
                if let image = fieldViewModel.imageToDisplay {
                    imageSection(for: image)
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
        ZStack {
            if fieldViewModel.isCroppingNextImage {
                ZStack {
                    ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .frame(maxWidth: .infinity)
            } else {
                croppedImageButton(for: image)
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
    
    func croppedImageButton(for image: UIImage) -> some View {
        var label: some View {
            VStack {
                HStack {
                    Spacer()
                    imageView(for: image)
                        .frame(maxWidth: 350, maxHeight: 150, alignment: .bottom)
                    Spacer()
                }
            }
        }
        var button: some View {
            Button {
                didTapImage()
            } label: {
                label
            }
            .buttonStyle(.borderless)
        }
        
        return Group {
            if fieldViewModel.fieldValue.supportsSelectingText {
                button
            } else {
                label
            }
        }
    }
    
    func imageView(for image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.top, 5)
            .padding(.bottom, 8)
            .padding(.horizontal, 3)
//            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    var sampleImage: UIImage? {
        PrepFoodForm.sampleImage(4)
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
