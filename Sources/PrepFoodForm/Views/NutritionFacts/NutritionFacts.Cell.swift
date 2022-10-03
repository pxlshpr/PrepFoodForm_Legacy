import SwiftUI
import PrepUnits

extension FoodForm.NutritionFacts {
    struct Cell: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.colorScheme) var colorScheme
        @Binding var fieldValueViewModel: FieldValueViewModel
        @State var imageToDisplay: UIImage? = nil
    }
}

extension FoodForm.NutritionFacts.Cell {
    
    var body: some View {
        ZStack {
            content
            imageLayer
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(cellBackgroundColor)
        .cornerRadius(10)
        .padding(.bottom, 10)
//        .onAppear {
//            getCroppedImage(for: fieldValue.fillType)
//        }
    }
    
    var imageLayer: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                Spacer()
                VStack {
                    Spacer()
                    croppedImage
//                    Color.blue
                        .frame(maxWidth: 200, alignment: .trailing)
                        .grayscale(1.0)
//                        .opacity(0.5)
                }
                .frame(height: 40)
//                .background(.green)
                .padding(.trailing, 16)
                .padding(.bottom, 6)
            }
        }
    }
    
    @ViewBuilder
    var croppedImage: some View {
        if let image = imageToDisplay {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .shadow(radius: 3, x: 0, y: 3)
        }
    }
    
    var content: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                topRow
                bottomRow
            }
        }
    }
    
    var fieldValue: FieldValue {
        fieldValueViewModel.fieldValue
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
            fillTypeIcon
            disclosureArrow
        }
        .foregroundColor(fieldValue.labelColor(for: colorScheme))
    }
    
    var bottomRow: some View {
//        HStack(alignment: .bottom) {
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
//            croppedImage
//        }
    }
    
    func getCroppedImage(for fillType: FillType) {
        guard fillType.usesImage else {
            withAnimation {
                imageToDisplay = nil
//                shouldShowImage = false
            }
            return
        }
        Task {
            let croppedImage = await viewModel.croppedImage(for: fillType)

            await MainActor.run {
                withAnimation {
                    self.imageToDisplay = croppedImage
//                    self.shouldShowImage = true
                }
            }
        }
    }

    
    @ViewBuilder
    var fillTypeIcon: some View {
        if viewModel.shouldShowFillButton {
            Image(systemName: fieldValue.fillType.iconSystemImage)
//        Image(systemName: "text.viewfinder")
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
    
    var fieldValue: FieldValue {
        var fieldValue = FieldValue(micronutrient: .calcium, fillType: .userInput)
        fieldValue.microValue.double = 25
        fieldValue.microValue.unit = .g
        return fieldValue
    }
    
    
    public var body: some View {
        NavigationView {
            ScrollView {
                Color.blue
//                FoodForm.NutritionFacts.Cell(fieldValue: .constant(fieldValue))
//                    .environmentObject(viewModel)
//                    .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
        }
     }
    
    public init() { }
}

struct NutritionFacts_Cell_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFacts_CellPreview()
    }
}
