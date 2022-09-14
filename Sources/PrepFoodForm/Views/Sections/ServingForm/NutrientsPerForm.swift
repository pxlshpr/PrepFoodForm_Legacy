import SwiftUI

extension FoodForm {
    struct NutrientsPerForm: View {

        @EnvironmentObject var viewModel: ViewModel
        
        @State var servingAmount = ""
        @State var servingUnit: String = "g"
        @State var pickerServingUnit: String = "g"

        @State var servingSizeAmount = ""
        @State var servingSizeUnit: String = "g"

        @State var servingUnits = ["g", "cup", "serving"]
        @State var servingSizeUnits = ["g", "cup"]
        
        @State var showingSizesList = false
        @State var showingVolumesList = false
        @State var showingAddSizeForm = false
        @State var showingAddVolumeForm = false
    }
}

extension FoodForm.NutrientsPerForm {
    var body: some View {
        form
        .toolbar { bottomToolbarContent }
        .navigationTitle("Nutrients per")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSizesList) {
            SizesList()
        }
        .sheet(isPresented: $showingVolumesList) {
            SizesList()
        }
        .sheet(isPresented: $showingAddSizeForm) {
            SizeForm()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingAddVolumeForm) {
            SizesList()
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    var form: some View {
        Form {
            AmountFieldSection()
            if viewModel.amountUnit == .serving {
                ServingSizeFieldSection()
            }
            sizesSection
            if servingUnit != "serving" || !servingSizeAmount.isEmpty {
                densitiesSection
            }
        }
    }
    
    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            scanButton
        }
    }
    
    var scanButton: some View {
        Button {
            
        } label: {
            Image(systemName: "text.viewfinder")
        }
    }
    

    var densitiesSection: some View {
        var header: some View {
            Text("Density")
        }
        
        @ViewBuilder
        var footer: some View {
            if servingUnit == "g" || servingSizeUnit == "g" {
                Text("Specifying a density will also let you log this food using volume units.")
            } else if servingUnit == "cup" || servingSizeUnit == "cup" {
                Text("Specifying a density will also let you log this food using weight units.")
            }
        }
        
        return Section(header: header, footer: footer) {
            NavigationLinkButton {
                viewModel.path.append(.densityForm)
            } label: {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    var sizesSection: some View {
        var header: some View {
            Text("Sizes")
        }
        
        var footer: some View {
            Text("Sizes give you additional named units to log this food in, such as – biscuit, bottle, pack, etc.")
        }
        
        return Section(header: header, footer: footer) {
            if viewModel.allSizes.isEmpty {
                Button {
                    showingAddSizeForm = true
                } label: {
                    SizesCell()
                }
            } else {
                NavigationLinkButton {
                    viewModel.path.append(.sizesList)
                } label: {
                    SizesCell()
                }
            }
        }
    }
}
