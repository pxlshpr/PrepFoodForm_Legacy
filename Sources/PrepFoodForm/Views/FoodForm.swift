import SwiftUI

public struct FoodForm: View {
   
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    
    @State public var isPresentingDetails = false
    @State public var isPresentingNutrientsPer = false
    @State public var isPresentingNutrients = false
    @State public var isPresentingSource = false

    public init() {
        
    }
    
    public var body: some View {
        contents
        .navigationBarTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var contents: some View {
        VStack(spacing: 0) {
            form
            VStack {
                savePublicallyButton
                    .padding(.top)
                savePrivatelyButton
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    var savePublicallyButton: some View {
        FormPrimaryButton(title: "Save") {
            dismiss()
        }
    }

    var savePrivatelyButton: some View {
        FormSecondaryButton(title: "Save Privately") {
            dismiss()
        }
    }

    var form: some View {
        Form {
            detailsSection
            servingSection
            foodLabelSection
            sourceSection
        }
    }
    
    //MARK: - Sections
    
    var detailsSection: some View {
        Section("Details") {
            NavigationLinkButton {
                viewModel.path.append(.detailsForm)
            } label: {
                DetailsCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var servingSection: some View {
        Section("Amount Per") {
            NavigationLink {
                Color.red
            } label: {
                NutrientsPerCell()
                    .environmentObject(viewModel)
            }
//            NavigationLinkButton {
//                viewModel.path.append(.nutrientsPerForm)
//                if !viewModel.hasNutrientsPerContent {
//                    /// If it's empty, prefill it before going to the screen
//                    viewModel.amountString = "1"
//                }
//            } label: {
//                NutrientsPerCell()
//                    .environmentObject(viewModel)
//            }
        }

    }
    
    var foodLabelSection: some View {
        @ViewBuilder
        var header: some View {
            if !viewModel.hasNutritionFacts {
                Text("Nutrition Facts")
            }
        }
        
        return Section(header: header) {
            NavigationLinkButton {
                viewModel.path.append(.nutritionFacts)
            } label: {
                NutritionFactsCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var sourceSection: some View {
        SourceSection()
            .environmentObject(viewModel)
    }
    
    var servingCell: some View {
        Text("Set serving")
    }
    
    var nutrientsCell: some View {
        FoodForm.NutrientsCell()
    }
    
    var foodLabelScanCell: some View {
//        Label("Scan food label", systemImage: "text.viewfinder")
        HStack {
            Text("Scan food label")
            Spacer()
            Image(systemName: "text.viewfinder")
        }
    }
    
    var sourceCell: some View {
        Text("Add source")
    }
}
