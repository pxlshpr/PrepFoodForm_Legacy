import SwiftUI

extension FoodForm {
    struct NutrientsPerForm: View {

        @EnvironmentObject var viewModel: ViewModel
        
        @State var showingSizesList = false
        @State var showingVolumesList = false
        @State var showingAddSizeForm = false
        @State var showingAddVolumeForm = false
    }
}

extension FoodForm.NutrientsPerForm {
    var body: some View {
        form
        .onChange(of: viewModel.standardSizes) { newValue in
            viewModel.updateSummary()
        }
        .onChange(of: viewModel.volumePrefixedSizes) { newValue in
            viewModel.updateSummary()
        }
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
        .interactiveDismissDisabled()
    }
    
    var form: some View {
        Form {
            AmountFieldSection()
            if viewModel.amountUnit == .serving {
                ServingSizeFieldSection()
            }
            sizesSection
//            if viewModel.shouldShowDensitiesSection {
                densitiesSection
                    .opacity(viewModel.shouldShowDensitiesSection ? 1 : 0)
//            }
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
        @ViewBuilder
        var header: some View {
            if viewModel.isWeightBased {
                Text("Weight-to-Volume Ratio")
            } else if viewModel.isVolumeBased {
                Text("Volume-to-Weight Ratio")
            }
        }
        
        @ViewBuilder
        var footer: some View {
            if viewModel.isWeightBased {
                Text("Setting this will also let you log this food using volume units.")
            } else if viewModel.isVolumeBased {
                Text("Setting this will also let you log this food using weight units.")
            }
        }
        
        return Section(header: header, footer: footer) {
            NavigationLink(value: FoodForm.Route.densityForm) {
                if let densityDescription = viewModel.densityDescription {
                    Text(densityDescription)
                        .foregroundColor(.primary)
                } else {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                }
            }
//            NavigationLinkButton {
//                viewModel.path.append(.densityForm)
//            } label: {
//                Text("Optional")
//                    .foregroundColor(Color(.quaternaryLabel))
//            }
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