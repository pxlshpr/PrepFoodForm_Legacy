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
                if let image = fieldViewModel.imageToDisplay {
                    FormStyledSection {
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
                }
            }
        }
        .sheet(isPresented: $showingAutofillInfo) {
            AutofillInfoSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
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
        Button {
//            fieldFormViewModel.showingImageTextPicker = true
            didTapImage()
        } label: {
            VStack {
                HStack {
                    Spacer()
                    imageView(for: image)
                        .frame(maxWidth: 350, maxHeight: 150, alignment: .bottom)
                    Spacer()
                }
            }
        }
        .buttonStyle(.borderless)
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


extension MFPProcessedFood {
    var detailStrings: [String] {
        [name, detail, brand].compactMap { $0 }
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
                viewModel.energyViewModel.fieldValue.energyValue.fillType = .userInput
            }
        }
    }
}

struct FillOptionSections_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionSectionsPreview()
    }
}
