import SwiftUI
import PrepUnits

extension FoodForm.NutritionFacts {
    struct Cell: View {
        @Environment(\.colorScheme) var colorScheme
        @Binding var fieldValue: FieldValue
    }
}

extension FoodForm.NutritionFacts.Cell {
    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.bottom, 13)
            .padding(.top, 13)
            .background(cellBackgroundColor)
            .cornerRadius(10)
            .padding(.bottom, 10)
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    //MARK: - Components
    
    var topRow: some View {
        HStack {
            Spacer().frame(width: 2)
            HStack(spacing: 4) {
                Image(systemName: fieldValue.iconImageName)
                    .font(.system(size: 14))
                Text(fieldValue.description)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            Spacer()
            inputIcon
            disclosureArrow
        }
        .foregroundColor(fieldValue.labelColor(for: colorScheme))
    }
    
    var bottomRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(fieldValue.amountString)
                .foregroundColor(fieldValue.amountColor)
                .font(.system(size: fieldValue.isEmpty ? 20 : 28, weight: .medium, design: .rounded))
            if fieldValue.double != nil {
                Text(fieldValue.unitString)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .bold()
                    .foregroundColor(Color(.secondaryLabel))
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var inputIcon: some View {
        if let imageName = fieldValue.fillTypeIconImage {
            Image(systemName: imageName)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
    var cellBackgroundColor: Color {
//        colorScheme == .dark ? Color(.systemGroupedBackground) : Color(.secondarySystemGroupedBackground)
        Color(.secondarySystemGroupedBackground)
    }
}

public struct NutritionFacts_CellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        NavigationView {
            FoodForm.NutritionFacts()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.previewPrefill()
        }
    }
    
    public init() { }
}

struct NutritionFacts_Cell_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsCellPreview()
    }
}
