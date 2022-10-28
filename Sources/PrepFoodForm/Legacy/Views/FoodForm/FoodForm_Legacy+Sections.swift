import SwiftUI
import SwiftHaptics
import PrepDataTypes
import PhotosUI
import Camera
import EmojiPicker
import SwiftUISugar
import FoodLabelCamera
import RSBarcodes_Swift

extension FoodForm_Legacy {
    
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                DetailsForm()
                    .environmentObject(viewModel)
                    .onDisappear {
                        print("Do it here")
                    }
            } label: {
                DetailsCell()
                    .environmentObject(viewModel)
                    .buttonStyle(.borderless)
            }
        }
    }
    
    var servingSection: some View {
        FormStyledSection(header: Text("Amount Per")) {
            NavigationLink {
                AmountPerForm()
                    .environmentObject(viewModel)
            } label: {
                NutrientsPerCell()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var foodLabelSection: some View {
        @ViewBuilder
        var header: some View {
            if !viewModel.hasNutritionFacts {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
                NutritionFactsList()
                    .environmentObject(viewModel)
            } label: {
                NutritionFactsCell()
                    .environmentObject(viewModel)
                    .buttonStyle(.borderless)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var sourceSection: some View {
        SourceSection_Legacy()
            .environmentObject(viewModel)
    }

    var barcodesSection: some View {
        BarcodesSection()
            .environmentObject(viewModel)
    }

    @ViewBuilder
    var prefillSection: some View {
        if let url = viewModel.prefilledFood?.sourceUrl {
            FormStyledSection(header: Text("Prefilled Food")) {
                NavigationLink {
                    WebView(urlString: url)
                } label: {
                    LinkCell(LinkInfo("https://myfitnesspal.com")!, title: "MyFitnessPal")
                }
            }
        }
    }
    
    var servingCell: some View {
        Text("Set serving")
    }
    
    var nutrientsCell: some View {
        FoodForm_Legacy.NutrientsCell()
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
