import SwiftUI
import PrepUnits

extension FieldValue.MicroValue {
    var convertedFromPercentage: (amount: Double, unit: NutrientUnit)? {
        guard let double, unit == .p else {
            return nil
        }
        return nutrientType.convertRDApercentage(double)
    }
}
struct MicronutrientForm: View {
    
    @ObservedObject var fieldValueViewModel: FieldValueViewModel
    @StateObject var formViewModel: FieldValueViewModel
    
    @State var unit: NutrientUnit

    init(fieldValueViewModel: FieldValueViewModel) {
        self.fieldValueViewModel = fieldValueViewModel
        
        let formViewModel = fieldValueViewModel.copy
        _formViewModel = StateObject(wrappedValue: formViewModel)
        
        _unit = State(initialValue: fieldValueViewModel.fieldValue.microValue.unit)
    }

    
    var body: some View {
        FieldValueForm(
            formViewModel: formViewModel,
            fieldValueViewModel: fieldValueViewModel,
            unitView: unitPicker,
            supplementaryView: percentageInfoView,
            supplementaryViewHeaderString: supplementaryViewHeaderString,
            supplementaryViewFooterString: supplementaryViewFooterString,
            setNewValue: setNewValue
        )
        .onChange(of: unit) { newValue in
            withAnimation {
                formViewModel.fieldValue.microValue.unit = newValue
            }
        }
    }
    
    var supplementaryViewHeaderString: String? {
        if formViewModel.fieldValue.microValue.unit == .p {
            return "Equivalent Value"
        }
        return nil
    }

    var supplementaryViewFooterString: String? {
        if formViewModel.fieldValue.microValue.unit == .p {
            return "% values will be converted and saved as their equivalent amounts."
        }
        return nil
    }

    @ViewBuilder
    var percentageInfoView: some View {
        if let valueAndUnit = formViewModel.fieldValue.microValue.convertedFromPercentage {
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
            Text(formViewModel.fieldValue.microValue.unitDescription)
                .foregroundColor(.secondary)
                .font(.title3)
        }
    }

    func setNewValue(_ value: FoodLabelValue) {
        formViewModel.fieldValue.microValue.string = value.amount.cleanAmount
        if let unit = value.unit?.nutrientUnit(for: formViewModel.fieldValue.microValue.nutrientType),
           supportedUnits.contains(unit)
        {
            formViewModel.fieldValue.microValue.unit = unit
        } else {
            formViewModel.fieldValue.microValue.unit = defaultUnit
        }
    }

    var supportedUnits: [NutrientUnit] {
        fieldValueViewModel.fieldValue.microValue.supportedNutrientUnits
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
        MicronutrientForm(fieldValueViewModel: viewModel.micronutrientFieldValueViewModel(for: .vitaminC)!)
            .environmentObject(viewModel)
    }
}

extension FoodFormViewModel {
    func micronutrientFieldValueViewModel(for nutrientType: NutrientType) -> FieldValueViewModel? {
        for group in micronutrients {
            for fieldValueViewModel in group.fieldValueViewModels {
                if case .micro(let microValue) = fieldValueViewModel.fieldValue, microValue.nutrientType == nutrientType {
                    return fieldValueViewModel
                }
            }
        }
        return nil
    }
}
struct MicronutrientFormForm_Previews: PreviewProvider {
    static var previews: some View {
        MicronutrientFormPreview()
    }
}
