import SwiftUI
import PrepUnits

extension FoodForm {
    struct NutritionFactsCell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
        
        @State var energyInCalories: Bool = true
    }
}
extension FoodForm.NutritionFactsCell {
    struct Row: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
        var fact: NutritionFact
    }
}

extension FoodForm.NutritionFactsCell.Row {
    
    var body: some View {
        HStack {
            Text(fact.type.description)
                .bold(fact.type == .energy)
//                .foregroundColor(fact.type.textColor(for: colorScheme))
//                .bold()
                .foregroundColor(.primary)
            Spacer()
            if let amountDescription = fact.amountDescription {
                Text(amountDescription)
//                    .foregroundColor(fact.type.textColor(for: colorScheme))
                    .foregroundColor(Color(.secondaryLabel))
                    .bold(fact.type == .energy)
            }
        }
    }
}

extension FoodForm.NutritionFactsCell {
    
    var body: some View {
        Group {
            if !viewModel.hasNutritionFacts {
                emptyContent
            } else {
                legacyContent
            }
        }
    }
    
    var emptyContent: some View {
        Text("Required")
            .foregroundColor(Color(.tertiaryLabel))
    }
    
    var content: some View {
        @ViewBuilder
        func factRow(for fact: NutritionFact) -> some View {
            if !fact.isEmpty {
                Row(fact: fact)
            }
        }

        @ViewBuilder
        var micronutrientsCount: some View {
            if !viewModel.micronutrients.isEmpty {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(.quaternaryLabel))
                    Text("\(viewModel.micronutrients.count) micronutrients")
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.vertical, 5)
                .padding(.leading, 7)
                .padding(.trailing, 9)
                .background(
                    Capsule(style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                )
                .padding(.top, 5)
            }
        }
        
        return VStack(alignment: .leading, spacing: 5) {
            factRow(for: viewModel.energyFact)
            factRow(for: viewModel.carbFact)
            factRow(for: viewModel.fatFact)
            factRow(for: viewModel.proteinFact)
            micronutrientsCount
        }
    }
}
    
extension FoodForm.NutritionFactsCell {
    
    var legacyContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            calories
            Color.clear.frame(height: 3)
            macros
            if viewModel.hasMicronutrients {
//                macrosMicrosSeparator
                micros
            }
        }
        .padding(15)
        .border(borderColor, width: 5.0)
        .padding(.vertical)
    }
   
    //MARK: - Components
    var calories: some View {
        Group {
            caloriesRow
            Color.clear.frame(height: 10)
            rectangle(height: 8, color: Color(.label))
//            Color.clear.frame(height: 6)
        }
    }
    
    var header: some View {
        Group {
            nutritionFactsRow
            Color.clear.frame(height: 6)
//            amountPerRow
//            Color.clear.frame(height: 10)
            rectangle(height: 15)
            Color.clear.frame(height: 12)
        }
    }
    
    var nutritionFactsRow: some View {
        Text("Nutrition Facts")
            .fontWeight(.black)
            .font(.largeTitle)
            .foregroundColor(.primary)
    }

    var caloriesRow: some View {
        HStack(alignment: .bottom) {
            Text(energyInCalories ? "Calories" : "Energy")
                .fontWeight(.black)
                .font(.title)
                .transition(.opacity)
                .foregroundColor(.primary)
            Spacer()
            labelCaloriesAmount
        }
    }

    var labelCaloriesAmount: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(formattedEnergy)
                .fontWeight(.black)
                .font(.largeTitle)
                .multilineTextAlignment(.trailing)
                .transition(.opacity)
                .foregroundColor(Color(.label))
            if !energyInCalories {
                Text("kJ")
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .offset(y: 2)
                    .transition(.scale)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
    
    var macros: some View {
        Group {
            fatRows
            highlightedMacroRows
            carbRows
            proteinRow
        }
    }
    
    var micros: some View {
        Group {
            vitaminRows
            mineralRows
            miscRows
        }
    }
    
    var macrosMicrosSeparator: some View {
        Group {
            Color.clear.frame(height: 6)
            rectangle(height: 15)
//            Color.clear.frame(height: 3)
        }
    }

    var proteinRow: some View {
        row(title: "Protein", value: viewModel.proteinAmount, unit: "g", bold: true)
    }

    var fatRows: some View {
        Group {
            row(title: "Total Fat", value: viewModel.fatAmount, unit: "g", bold: true)
            nutrientRow(forType: .saturatedFat, indentLevel: 1)
            nutrientRow(forType: .polyunsaturatedFat, indentLevel: 1)
            nutrientRow(forType: .monounsaturatedFat, indentLevel: 1)
            nutrientRow(forType: .transFat, indentLevel: 1)
        }
    }
    
    var highlightedMacroRows: some View {
        Group {
            nutrientRow(forType: .cholesterol, indentLevel: 0)
            nutrientRow(forType: .sodium, indentLevel: 0)
        }
    }
    
    var carbRows: some View {
        Group {
            row(title: "Total Carbohydrate", value: viewModel.carbAmount, unit: "g", bold: true)
            nutrientRow(forType: .dietaryFiber, indentLevel: 1)
            nutrientRow(forType: .solubleFiber, indentLevel: 2)
            nutrientRow(forType: .insolubleFiber, indentLevel: 2)
            nutrientRow(forType: .sugars, indentLevel: 1)
            nutrientRow(forType: .addedSugars, indentLevel: 2, prefixedWithIncludes: true) /// Displays as "Includes xg Added Sugar"
            nutrientRow(forType: .sugarAlcohols, indentLevel: 2)
        }
    }
    
    var vitaminRows: some View {
        Group {
            ForEach(NutrientType.vitamins, id: \.self) {
                nutrientRow(forType: $0)
            }
        }
    }
    
    var mineralRows: some View {
        Group {
            ForEach(NutrientType.minerals.filter { $0 != .sodium }, id: \.self) {
                nutrientRow(forType: $0)
            }
        }
    }
    
    var miscRows: some View {
        Group {
            ForEach(NutrientType.misc, id: \.self) {
                nutrientRow(forType: $0)
            }
        }
    }
    
    //MARK: - Helpers
    
    var formattedEnergy: String {
        var energy = viewModel.energyAmount
        if !energyInCalories {
            energy = EnergyUnit.convertToKilojules(fromKilocalories: energy)
        }
        return "\(Int(energy))"
    }

    @ViewBuilder
    func nutrientRow(forType type: NutrientType, indentLevel: Int = 0, prefixedWithIncludes: Bool = false) -> some View {
        let prefix = type == .transFat ? "Trans" : nil
        let title = type == .transFat ? "Fat" : type.description
        let bold = type == .cholesterol || type == .sodium
        
        if let value = viewModel.nutrientValue(for: type) {
            row(title: title,
                prefix: prefix,
                value: value,
                unit: type.dailyValue?.1.shortDescription ?? "g",
                indentLevel: indentLevel,
                bold: bold,
                prefixedWithIncludes: prefixedWithIncludes
            )
        }
    }

    func row(title: String, prefix: String? = nil, suffix: String? = nil, value: Double, rdaValue: Double? = nil, unit: String = "g", indentLevel: Int = 0, bold: Bool = false, includeDivider: Bool = true, prefixedWithIncludes: Bool = false) -> some View {
        let prefixView = Group {
            if let prefix = prefix {
                Text(prefix)
                    .fontWeight(.regular)
                    .font(.headline)
                    .italic()
                    .foregroundColor(.primary)
                Color.clear.frame(width: 3)
            }
        }
        
        let titleView = Group {
            HStack(spacing: 0) {
                prefixView
                Text(title)
                    .fontWeight(bold ? .black : .regular)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        
        let valueAndSuffix = Group {
            Text(valueString(for: value, with: unit))
                .fontWeight(.regular)
                .font(.headline)
                .foregroundColor(.primary)
            if let suffix = suffix {
                Text(suffix)
                    .fontWeight(bold ? .bold : .regular)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        
        let divider = Group {
            HStack {
                if indentLevel > 1 {
                    Color.clear.frame(width: CGFloat(indentLevel) * 20.0)
                }
                VStack {
                    rectangle(height: 0.3)
                    Color.clear.frame(height: 5)
                }
            }
            .frame(height: 6.0)
        }
        
        let includesPrefixView = Group {
            if prefixedWithIncludes {
                Text("Includes")
                    .foregroundColor(Color(.label))
            }
        }
        
        return VStack(spacing: 0) {
            if includeDivider {
                divider
            } else {
                Color.clear.frame(height: 2)
            }
//            Color.clear.frame(height: 2)
            HStack {
                if indentLevel > 0 {
                    Color.clear.frame(width: CGFloat(indentLevel) * 20.0)
                }
                VStack {
                    HStack {
                        includesPrefixView
                        if prefixedWithIncludes {
                            valueAndSuffix
                            titleView
                        } else {
                            titleView
                            valueAndSuffix
                        }
                        Spacer()
                        if rdaValue != nil {
                            Text("\(Int((value/rdaValue!)*100.0))%")
                                .fontWeight(.bold)
                                .font(.headline)
                        }
                    }
                }
            }
            Color.clear.frame(height: 5)
        }
    }
    
    var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    func rectangle(height: CGFloat, color: Color? = nil) -> some View {
        Rectangle()
            .frame(height: height)
//            .foregroundColor(Color(.quaternaryLabel))
            .foregroundColor(color ?? borderColor)
    }

    func valueString(for value: Double, with unit: String) -> String {
        if value < 0.5 {
            if value == 0 {
                return "0" + unit
            } else if value < 0.1 {
                return "< 0.1" + unit
            } else {
                return "\(String(format: "%.1f", value))" + unit
            }
        } else {
            return "\(Int(value))" + unit
        }
    }
}

//MARK: - Preview

public struct NutritionFactsCellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                    } label: {
                        FoodForm.NutritionFactsCell()
                            .environmentObject(viewModel)
                    }
                }
            }
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.prefill()
    }
}
struct NutritionFactsCell_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsCellPreview()
    }
}
