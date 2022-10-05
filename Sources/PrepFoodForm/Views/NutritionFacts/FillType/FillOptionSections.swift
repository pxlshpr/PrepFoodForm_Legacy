import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import MFPScraper
import PrepUnits
import SwiftUISugar
import ActivityIndicatorView

//MARK: Button

struct FillOptionButton: View {
    
    let selectionColorDark = Color(hex: "6c6c6c")
    let selectionColorLight = Color(hex: "959596")
    @Environment(\.colorScheme) var colorScheme
    
    let fillOption: FillOption
    let didTap: () -> ()
    
    init(fillOption: FillOption, didTap: @escaping () -> Void) {
        self.fillOption = fillOption
        self.didTap = didTap
    }

    var body: some View {

        var backgroundColor: Color {
            guard fillOption.isSelected else {
                return Color(.secondarySystemFill)
            }
            if fillOption.disableWhenSelected {
                return .accentColor
            } else {
                return colorScheme == .light ? selectionColorLight : selectionColorDark
            }
        }
        
        return Button {
            didTap()
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(backgroundColor)
                HStack(spacing: 5) {
                    Image(systemName: fillOption.systemImage)
                        .foregroundColor(fillOption.isSelected ? .white : .secondary)
                        .imageScale(.small)
                        .frame(height: 25)
                    Text(fillOption.string)
                        .foregroundColor(fillOption.isSelected ? .white : .primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
//            .background(
//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .foregroundColor(isSelected.wrappedValue ? .accentColor : Color(.secondarySystemFill))
//            )
        }
        .grayscale(fillOption.isSelected ? 1 : 0)
        .disabled(fillOption.disableWhenSelected ? fillOption.isSelected : false)
    }
}

//MARK: - FillOption

struct FillOption: Hashable {
    let string: String
    let systemImage: String
    let isSelected: Bool
    let disableWhenSelected: Bool
    let type: FillOptionType
    
    init(string: String, systemImage: String, isSelected: Bool, disableWhenSelected: Bool = true, type: FillOptionType) {
        self.string = string
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.disableWhenSelected = disableWhenSelected
        self.type = type
    }
}

//MARK: Sections

struct FillOptionSections: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingAutofillInfo = false
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
    @Binding var shouldAnimate: Bool
    var didTapImage: () -> ()
    var didTapFillOption: (FillOption) -> ()

    var body: some View {
        Group {
            if viewModel.shouldShowFillOptions(for: fieldValueViewModel.fieldValue) {
                FormStyledSection(header: autofillHeader) {
                    FillOptionsGrid(
                        fieldValueViewModel: fieldValueViewModel,
                        shouldAnimate: $shouldAnimate
                    ) { fillOption in
                        didTapFillOption(fillOption)
                    }
                }
                if let image = fieldValueViewModel.imageToDisplay {
                    FormStyledSection {
                        ZStack {
                            if fieldValueViewModel.isCroppingNextImage {
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
                Text("Auto-fill")
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

struct AutofillInfoSheet: View {
    var body: some View {
        Text("Talk about autofill here")
    }
}

//MARK: - FFVM

extension FoodFormViewModel {
    public static var mock: FoodFormViewModel {
        let viewModel = FoodFormViewModel()
        
        guard let image = sampleImage(10),
              let mfpProcessedFood = sampleMFPProcessedFood(10),
              let scanResult = sampleScanResult(10)
        else {
            fatalError("Couldn't load mock files")
        }
        
        viewModel.shouldShowWizard = false
        
        viewModel.prefilledFood = mfpProcessedFood
        
        viewModel.sourceType = .images
        viewModel.imageViewModels.append(
            ImageViewModel(image: image,
                           scanResult: scanResult
                           
                          )
        )
        viewModel.processScanResults()
        viewModel.imageSetStatus = .classified
        
        return viewModel
    }
}

extension FoodLabelValue: CustomStringConvertible {
    public var fillOptionString: String {
        if let unit = unit {
            return "\(amount.cleanAmount) \(unit.description)"
        } else {
            return "\(amount.cleanAmount)"
        }
    }
}

extension FieldValue {
    func matchesFieldValue(_ fieldValue: FieldValue, withValue value: FoodLabelValue?) -> Bool {
        var selfWithValue = self
        selfWithValue.fillType.value = value
        return selfWithValue == fieldValue
    }
}

enum FillOptionType: Hashable {
    case fillType(FillType)
    case chooseText
}

extension String {
    var energyValue: FoodLabelValue? {
        let values = FoodLabelValue.detect(in: self)
        /// Returns the first energy value detected, otherwise the first value regardless of the unit
        let value = values.first(where: { $0.unit?.isEnergy == true }) ?? values.first
        
        if let value, value.unit != .kj {
            ///  Always set the unit to kcal as a fallback for energy values
            return FoodLabelValue(amount: value.amount, unit: .kcal)
        }
        
        /// This would either be `nil` for `FoodLabelValue` with an energy unit
        return value
    }
    
    var energyValueDescription: String {
        guard let energyValue else { return "" }
        
        /// If the found `energyValue` actually has an energy unit—return its entire description, otherwise only return the number
        if energyValue.unit?.isEnergy == true {
            return energyValue.description
        } else {
            return "\(energyValue.amount.cleanAmount) kcal"
        }
    }
}

extension RecognizedText {
    func fillButtonString(for fieldValue: FieldValue) -> String {
        switch fieldValue {
        case .energy:
            return string.energyValueDescription
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
        default:
            return string
        }
    }
}
extension MFPProcessedFood {
    var detailStrings: [String] {
        [name, detail, brand].compactMap { $0 }
    }
}

extension FieldValue {
    static func prefillOptionForName(with string: String) -> FieldValue {
        FieldValue.name(StringValue(string: string, fillType: .prefill(prefillFields: [.name])))
    }
}

//TODO: Write an extension on FieldValue or RecognizedText that provides alternative `FoodLabelValue`s for a specific type of `FieldValue`—so if its energy and we have a number, return it as the value with both units, or the converted value in kJ or kcal. If its simply a macro/micro value—use the stuff where we move the decimal place back or forward or correct misread values such as 'g' for '9', 'O' for '0' and vice versa.

//MARK: FFVM + FillOptions Helpers
extension FoodFormViewModel {
    
    func autofillOptionFieldValue(for fieldValue: FieldValue) -> FieldValue? {
        
        switch fieldValue {
        case .energy:
            return autofillFieldValues.first(where: { $0.isEnergy })
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
        default:
            return nil
        }
    }
    func hasPrefillOptions(for fieldValue: FieldValue) -> Bool {
        !prefillOptionFieldValues(for: fieldValue).isEmpty
    }
    
    func prefillOptionFieldValues(for fieldValue: FieldValue) -> [FieldValue] {
        guard let food = prefilledFood else {
            return []
        }
        
        switch fieldValue {
        case .name:
            return food.detailStrings.map { FieldValue.prefillOptionForName(with: $0) }
//            return FieldValue.name(FieldValue.StringValue(string: food.name, fillType: .prefill))
//        case .brand(let stringValue):
//            return FieldValue.brand(FieldValue.StringValue(string: detail, fillType: .prefill))
//            return food.detail
//        case .barcode(let stringValue):
//            return nil
//        case .detail(let stringValue):
//
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
//        case .energy(let energyValue):
//            <#code#>
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
        default:
            return []
        }
    }

    /**
     Returns true if there is at least one available (unused`RecognizedText` in all the `ScanResult`s that is compatible with the `fieldValue`
     */
    func hasAvailableTexts(for fieldValue: FieldValue) -> Bool {
        !availableTexts(for: fieldValue).isEmpty
    }
    
    func availableTexts(for fieldValue: FieldValue) -> [RecognizedText] {
        var availableTexts: [RecognizedText] = []
        for imageViewModel in imageViewModels {
            let texts = fieldValue.usesValueBasedTexts ? imageViewModel.textsWithValues : imageViewModel.texts
            let filtered = texts.filter { isNotUsingText($0) }
            availableTexts.append(contentsOf: filtered)
        }
        return availableTexts
    }

//    func texts(for fieldValue: FieldValue) -> [RecognizedText] {
//        var texts: [RecognizedText] = []
//        for scanResult in scanResults {
//            let filtered = scanResult.texts.filter {
//                $0.isFillOptionFor(fieldValue)
//            }
//            texts.append(contentsOf: filtered)
//        }
//        return texts
//    }

    func isNotUsingText(_ text: RecognizedText) -> Bool {
        fieldValueUsing(text: text) == nil
    }
    /**
     Returns the `fieldValue` (if any) that is using the `RecognizedText`
     */
    func fieldValueUsing(text: RecognizedText) -> FieldValue? {
        allFieldValues.first(where: {
            $0.fillType.uses(text: text)
        })
    }
}

extension FieldValue {
    var usesValueBasedTexts: Bool {
        switch self {
        case .amount, .serving, .density, .energy, .macro, .micro:
            return true
        default:
            return false
        }
    }
}

extension RecognizedText {
//    /// Returns true ift his recognized text is a possible `FillOption` for the provided `FieldValue`
//    func isFillOptionFor(_ fieldValue: FieldValue) -> Bool {
//        switch fieldValue {
//        case .energy, .macro, .micro:
//            return containsNumber
//        case .amount:
//            //TODO: Revisit this
//            return true
//        case .serving:
//            //TODO: Revisit this
//            return true
//        case .density:
//            return false
//        default:
//            return true
//        }
//    }
//    
//    var containsNumber: Bool {
//        string.matchesRegex(#"(^|[ ]+)[0-9]+"#)
//    }
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
        FillOptionSections(fieldValueViewModel: viewModel.energyViewModel,
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
