import SwiftUI

extension FoodForm {
    struct ServingForm: View {

        @ObservedObject var viewModel: ViewModel
        
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

extension FoodForm.ServingForm {
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingAddVolumeForm) {
            SizesList()
        }
    }
    
    var form: some View {
        Form {
            AmountFieldSection(viewModel: viewModel)
            if viewModel.amountUnit == .serving {
                ServingSizeFieldSection(viewModel: viewModel)
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
            NavigationLink {
                Text("huh")
//                DensitiesForm()
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
            Button {
                showingAddSizeForm = true
            } label: {
                Text("Add a size")
            }
//            NavigationLink {
//                FoodForm.ServingForm.SizesList()
//            } label: {
//                Text("Sizes")
//                    .foregroundColor(.accentColor)
//            }
        }
    }
}
