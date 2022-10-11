import SwiftUI
import PrepUnits

struct MicroForm: View {
    
    @ObservedObject var existingFieldViewModel: FieldViewModel
    @StateObject var fieldViewModel: FieldViewModel
    
    @State var unit: NutrientUnit

    init(existingFieldViewModel: FieldViewModel) {
        self.existingFieldViewModel = existingFieldViewModel
        
        let fieldViewModel = existingFieldViewModel
        _fieldViewModel = StateObject(wrappedValue: fieldViewModel)
        
        _unit = State(initialValue: existingFieldViewModel.fieldValue.microValue.unit)
    }

    
    var body: some View {
        FieldValueForm(
            fieldViewModel: fieldViewModel,
            existingFieldViewModel: existingFieldViewModel,
            unitView: unitPicker,
            supplementaryView: percentageInfoView,
            supplementaryViewHeaderString: supplementaryViewHeaderString,
            supplementaryViewFooterString: supplementaryViewFooterString,
            tappedPrefillFieldValue: tappedPrefillFieldValue,
            setNewValue: setNewValue
        )
        .onChange(of: unit) { newValue in
            withAnimation {
                fieldViewModel.fieldValue.microValue.unit = newValue
            }
        }
    }
    
    var supplementaryViewHeaderString: String? {
        if fieldViewModel.fieldValue.microValue.unit == .p {
            return "Equivalent Value"
        }
        return nil
    }

    var supplementaryViewFooterString: String? {
        if fieldViewModel.fieldValue.microValue.unit == .p {
            return "% values will be converted and saved as their equivalent amounts."
        }
        
        return nil
    }

    @ViewBuilder
    var percentageInfoView: some View {
        if let valueAndUnit = fieldViewModel.fieldValue.microValue.convertedFromPercentage {
            HStack {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(valueAndUnit.amount.cleanAmount)
                        .foregroundColor(Color.secondary)
                        .font(.system(size: 30, weight: .regular, design: .rounded))
//                        .font(.title)
                    Text(valueAndUnit.1.shortDescription)
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.system(size: 25, weight: .regular, design: .rounded))
//                        .font(.title3)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var unitPicker: some View {
        if supportedUnits.count > 1 {
            Picker("", selection: $unit) {
                ForEach(supportedUnits, id: \.self) { unit in
                    Text(unit.shortDescription).tag(unit)
                }
            }
            .pickerStyle(.menu)
        } else {
            Text(fieldViewModel.fieldValue.microValue.unitDescription)
                .foregroundColor(.secondary)
                .font(.title3)
        }
    }

    func tappedPrefillFieldValue(_ fieldValue: FieldValue) {
        guard case .micro(let microValue) = fieldValue else {
            return
        }
        fieldViewModel.fieldValue.microValue = microValue
    }

    func setNewValue(_ value: FoodLabelValue) {
        fieldViewModel.fieldValue.microValue.string = value.amount.cleanAmount
        if let unit = value.unit?.nutrientUnit(for: fieldViewModel.fieldValue.microValue.nutrientType),
           supportedUnits.contains(unit)
        {
            fieldViewModel.fieldValue.microValue.unit = unit
        } else {
            fieldViewModel.fieldValue.microValue.unit = defaultUnit
        }
    }

    var supportedUnits: [NutrientUnit] {
        existingFieldViewModel.fieldValue.microValue.nutrientType.supportedNutrientUnits
    }
    
    var defaultUnit: NutrientUnit {
        supportedUnits.first ?? .g
    }
}

//MARK: - Preview

struct MicronutrientFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        MicroForm(existingFieldViewModel: viewModel.micronutrientFieldViewModel(for: .vitaminC)!)
            .environmentObject(viewModel)
    }
}

struct MicronutrientFormForm_Previews: PreviewProvider {
    static var previews: some View {
        MicronutrientFormPreview()
    }
}
