import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import MFPScraper
import PrepUnits
import SwiftUISugar

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
    @Binding var fieldValue: FieldValue

    var body: some View {
        Group {
            if viewModel.shouldShowFillOptions(for: fieldValue) {
                FormStyledSection(header: autofillHeader) {
                    FillOptionsGrid(fieldValue: $fieldValue)
                }
                FormStyledSection {
                    croppedImageButton
                }
            }
        }
        .sheet(isPresented: $showingAutofillInfo) {
            AutofillInfo()
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
    
    var croppedImageButton: some View {
        Button {
//            fieldFormViewModel.showingImageTextPicker = true
        } label: {
            VStack {
                HStack {
                    Spacer()
                    imageView
                        .frame(maxWidth: 350, maxHeight: 150, alignment: .bottom)
                    Spacer()
                }
            }
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var imageView: some View {
//        if showingImage {
//        if let image = sampleImage {
            imageView(for: sampleImage!)
//        }
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

struct AutofillInfo: View {
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
        viewModel.imageViewModels.append(ImageViewModel(image: image, scanResult: scanResult))
        viewModel.processScanResults()
        viewModel.imageSetStatus = .classified
        
        return viewModel
    }
}

extension Value: CustomStringConvertible {
    public var fillOptionString: String {
        if let unit = unit {
            return "\(amount.cleanAmount) \(unit.description)"
        } else {
            return "\(amount.cleanAmount)"
        }
    }
}

extension FieldValue.EnergyValue {
    var altValues: [Value] {
        guard let double else { return [] }
        var values: [Value] = []
        switch unit {
        case .kJ:
            values.append(Value(amount: double, unit: .kcal))
            values.append(Value(amount: Double(Int(double/KcalsPerKilojule)), unit: .kj))
            values.append(Value(amount: Double(Int(double/KcalsPerKilojule)), unit: .kcal))
            values.append(Value(amount: Double(Int(double*KcalsPerKilojule)), unit: .kj))
            values.append(Value(amount: Double(Int(double*KcalsPerKilojule)), unit: .kcal))
        case .kcal:
            values.append(Value(amount: double, unit: .kj))
            values.append(Value(amount: Double(Int(double/KcalsPerKilojule)), unit: .kj))
            values.append(Value(amount: Double(Int(double/KcalsPerKilojule)), unit: .kcal))
            values.append(Value(amount: Double(Int(double*KcalsPerKilojule)), unit: .kj))
            values.append(Value(amount: Double(Int(double*KcalsPerKilojule)), unit: .kcal))
        }
        return values
    }
}

extension FieldValue {
    var altValues: [Value] {
        switch self {
        case .energy(let energyValue):
            return energyValue.altValues
//        case .macro(let macroValue):
//            <#code#>
//        case .micro(let microValue):
//            <#code#>
//        case .name(let stringValue):
//            <#code#>
//        case .emoji(let stringValue):
//            <#code#>
//        case .brand(let stringValue):
//            <#code#>
//        case .barcode(let stringValue):
//            <#code#>
//        case .detail(let stringValue):
//            <#code#>
//        case .amount(let doubleValue):
//            <#code#>
//        case .serving(let doubleValue):
//            <#code#>
//        case .density(let densityValue):
//            <#code#>
        default:
            return []
        }
    }
}

extension FillType {
    var value: Value? {
        get {
            switch self {
            case .imageSelection(_, _, _, let value):
                return value
            case .imageAutofill(_, _, let value):
                return value
            default:
                return nil
            }
        }
        set {
            switch self {
            case .imageSelection(let recognizedText, let scanResultId, let supplementaryTexts, _):
                self = .imageSelection(recognizedText: recognizedText, scanResultId: scanResultId, supplementaryTexts: supplementaryTexts, value: newValue)
            case .imageAutofill(let valueText, let scanResultId, _):
                self = .imageAutofill(valueText: valueText, scanResultId: scanResultId, value: newValue)
            default:
                break
            }
        }
    }
}

extension FieldValue {
    func matchesFieldValue(_ fieldValue: FieldValue, withValue value: Value?) -> Bool {
        var selfWithValue = self
        selfWithValue.fillType.value = value
        return selfWithValue == fieldValue
    }
}

enum FillOptionType: Hashable {
    case fillType(FillType)
    case chooseText
}

//MARK: - FFVM + FillOptions
extension FoodFormViewModel {

    func shouldShowFillOptions(for fieldValue: FieldValue) -> Bool {
        !fillOptions(for: fieldValue).isEmpty
    }

    func fillOptions(for fieldValue: FieldValue) -> [FillOption] {
        var fillOptions: [FillOption] = []
        
        /// Detected text option (if its available) + its alts
        if let autofillFieldValue = autofillOptionFieldValue(for: fieldValue) {
            fillOptions.append(
                FillOption(
                    string: fieldValue.fillButtonString,
                    systemImage: fieldValue.fillType.iconSystemImage,
                    isSelected: fieldValue == autofillFieldValue,
                    type: .fillType(autofillFieldValue.fillType)
                )
            )
            /// Show alts if selected (only check the text because it might have a different value attached to it)
            if fieldValue.fillType.text == autofillFieldValue.fillType.text {
                for alternateValue in fieldValue.altValues {
                    guard let valueText = fieldValue.fillType.valueText, let scanResultId = fieldValue.fillType.scanResultId else {
                        continue
                    }
                    fillOptions.append(
                        FillOption(
                            string: alternateValue.fillOptionString,
                            systemImage: fieldValue.fillType.iconSystemImage,
                            isSelected: autofillFieldValue.matchesFieldValue(fieldValue, withValue: alternateValue),
                            type: .fillType(.imageAutofill(valueText: valueText, scanResultId: scanResultId, value: alternateValue))
                        )
                    )
                }
            }
        }
            
        /// Selected text option (if its available) + its alts
        
        /// Prefill Options
        for prefillFieldValue in prefillOptionFieldValues(for: fieldValue) {
            let option = FillOption(
                string: prefillFieldValue.stringValue.string,
                systemImage: FillType.SystemImage.prefill,
                isSelected: fieldValue.fillType.isThirdPartyFoodPrefill,
                type: .fillType(.prefill())
            )
            fillOptions.append(option)
        }
        
        /// Choose Option
        if hasAvailableTexts(for: fieldValue) {
            let option = FillOption(
                string: "Choose",
                systemImage: FillType.SystemImage.imageSelection,
                isSelected: fieldValue.fillType.isImageSelection,
                type: .chooseText
            )
            fillOptions.append(option)
        }
        
        return fillOptions
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

//TODO: Write an extension on FieldValue or RecognizedText that provides alternative `Value`s for a specific type of `FieldValue`—so if its energy and we have a number, return it as the value with both units, or the converted value in kJ or kcal. If its simply a macro/micro value—use the stuff where we move the decimal place back or forward or correct misread values such as 'g' for '9', 'O' for '0' and vice versa.

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
        var texts: [RecognizedText] = []
        for scanResult in scanResults {
            let filtered = scanResult.texts.filter {
                isNotUsingText($0) && $0.isFillOptionFor(fieldValue)
            }
            texts.append(contentsOf: filtered)
        }
        return texts
    }
    
    func isNotUsingText(_ text: RecognizedText) -> Bool {
        fieldValueUsing(text: text) == nil
    }
    /**
     Returns the `fieldValue` (if any) that is using the `RecognizedText`
     */
    func fieldValueUsing(text: RecognizedText) -> FieldValue? {
        allFields.first(where: {
            $0.fillType.uses(text: text)
        })
    }
}

extension RecognizedText {
    /// Returns true ift his recognized text is a possible `FillOption` for the provided `FieldValue`
    func isFillOptionFor(_ fieldValue: FieldValue) -> Bool {
        switch fieldValue {
        case .energy, .macro, .micro:
            return containsNumber
        case .amount:
            //TODO: Revisit this
            return true
        case .serving:
            //TODO: Revisit this
            return true
        case .density:
            return false
        default:
            return true
        }
    }
    
    var containsNumber: Bool {
        string.matchesRegex(#"(^|[ ]+)[0-9]+"#)
    }
}

extension FillType {
    func uses(text: RecognizedText) -> Bool {
        switch self {
        case .imageSelection(let recognizedText, _, _, _):
            return recognizedText.id == text.id
        case .imageAutofill(let valueText, _, _):
            return valueText.text.id == text.id || valueText.attributeText?.id == text.id
        default:
            return false
        }
    }
}

//MARK: - Preview

public struct FillOptionSectionsPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    @State var string: String
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
        _string = State(initialValue: viewModel.energy.energyValue.string)
    }
    
    var fieldSection: some View {
        Section("Enter or auto-fill a value") {
            HStack {
                TextField("Required", text: $string)
            }
        }
    }
    
    var optionsSections: some View {
        FillOptionSections(fieldValue: $viewModel.energy)
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
        .onChange(of: viewModel.energy.energyValue.double) { newValue in
            string = newValue?.cleanAmount ?? ""
        }
        .onChange(of: string) { newValue in
            withAnimation {
                viewModel.energy.energyValue.fillType = .userInput
            }
        }
    }
}

struct FillOptionSections_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionSectionsPreview()
    }
}
