import SwiftUI
import PrepUnits
import ActivityIndicatorView

struct NutritionFactCell: View {
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var fieldViewModel: FieldViewModel
    
    @Binding var showImage: Bool
    
    var body: some View {
        ZStack {
            content
            if showImage {
                imageLayer
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(cellBackgroundColor)
        .cornerRadius(10)
        .padding(.bottom, 10)
//        .onAppear {
//            getCroppedImage(for: fieldValue.fill)
//        }
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
            fillTypeIcon
            disclosureArrow
        }
        .foregroundColor(fieldValue.labelColor(for: colorScheme))
    }
    
    var bottomRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(fieldValue.amountString)
                .foregroundColor(fieldValue.amountColor)
                .font(.system(size: fieldValue.isEmpty ? 20 : 28, weight: .medium, design: .rounded))
            if !isEmpty {
                Text(fieldValue.unitString)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .bold()
                    .foregroundColor(Color(.secondaryLabel))
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var fillTypeIcon: some View {
        if viewModel.hasNonUserInputFills, !isEmpty {
            Image(systemName: fieldValue.fill.iconSystemImage)
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
    
    //MARK: - Image
    
    var imageLayer: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                Spacer()
                VStack {
                    Spacer()
                    
                    croppedImage
                    .frame(maxWidth: 200, alignment: .trailing)
                    .grayscale(1.0)
                }
                .frame(height: 40)
                .padding(.trailing, 16)
                .padding(.bottom, 6)
            }
        }
    }
    
    var croppedImage: some View {
        
        var activityIndicator: some View {
            ZStack {
                ActivityIndicatorView(isVisible: .constant(true), type: .scalingDots())
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        return Group {
            if let image = fieldViewModel.imageToDisplay {
                ZStack {
                    if fieldViewModel.isCroppingNextImage {
                        activityIndicator
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                            )
                            .shadow(radius: 3, x: 0, y: 3)
                    }
                }
            } else if fieldValue.fill.usesImage {
                activityIndicator
            }
        }
    }
    
    //MARK: Helpers
    var fieldValue: FieldValue {
        fieldViewModel.fieldValue
    }
    
    var isEmpty: Bool {
        fieldValue.double == nil
    }
}


//MARK: - Preview

public struct NutritionFacts_CellPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    var fieldValue: FieldValue {
        var fieldValue = FieldValue(micronutrient: .calcium, fill: .userInput)
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
