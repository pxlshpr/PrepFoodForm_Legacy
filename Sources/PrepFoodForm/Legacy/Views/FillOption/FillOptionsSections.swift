import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import MFPScraper
import PrepDataTypes
import SwiftUISugar
import ActivityIndicatorView
import SwiftUISugar

struct FillOptionsSections: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingAutofillInfo = false
    @ObservedObject var fieldViewModel: Field
    @Binding var shouldAnimate: Bool
    
    @State var showingPrefillSource = false
    
    var didTapImage: () -> ()
    var didTapFillOption: (FillOption) -> ()

    var body: some View {
        Group {
            if viewModel.shouldShowFillOptions(for: fieldViewModel.value) {
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
        if fieldViewModel.image != nil {
            return true
        }
        
        if fieldViewModel.fill.isPrefill {
            return true
        }
        
        return false
    }

    @ViewBuilder
    var supplementarySection: some View {
        if shouldShowSupplementarySection {
            FormStyledSection {
                if let image = fieldViewModel.image {
                    imageSection(for: image)
                        .fixedSize(horizontal: true, vertical: false)
                }
                //TODO: Get prefillUrl passed into this (from sources perhaps)
//                if let prefillUrl = fieldViewModel.prefillUrl {
//                    prefillSection(for: prefillUrl)
//                }
            }
        }
    }
    
    func prefillSection(for prefillUrl: String) -> some View {
        NavigationLink {
            WebView(urlString: prefillUrl)
        } label: {
            HStack {
                Label("MyFitnessPal", systemImage: "link")
                    .foregroundColor(.accentColor)
                Spacer()
            }
        }
        .sheet(isPresented: $showingPrefillSource) {
            WebView(urlString: prefillUrl)
        }
    }

    @ViewBuilder
    func imageSection(for image: UIImage) -> some View {
        Group {
            if fieldViewModel.isCropping {
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
                Text("AutoFill")
                Image(systemName: "info.circle")
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    @ViewBuilder
    func croppedImageButton(for image: UIImage) -> some View {
        if fieldViewModel.value.supportsSelectingText {
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
        nil
//        PrepFoodForm.sampleImage(imageFilename: "energy1")
    }
}
