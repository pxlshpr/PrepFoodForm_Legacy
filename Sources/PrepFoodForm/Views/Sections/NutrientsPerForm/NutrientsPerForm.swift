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
        .navigationTitle("Serving")
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
            fieldSection
            if viewModel.shouldShowSizesSection {
                sizesSection
            }
            if viewModel.shouldShowDensitiesSection {
                densitySection
            }
        }
    }
   
    var fieldSection: some View {
        
        var footer: some View {
            Text("How much of this food the nutrition facts are for.")
                .foregroundColor(viewModel.amountString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return Section(footer: footer) {
            Field()
                .environmentObject(viewModel)
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
    
    var densitySection: some View {
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
            Group {
                if viewModel.isWeightBased {
                    Text("Enter this to be able to log this food using volume units, like cups.")
                } else if viewModel.isVolumeBased {
                    Text("Enter this to be able to log this food using using its weight.")
                }
            }
            .foregroundColor(!viewModel.hasValidDensity ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        @ViewBuilder
        var label: some View {
            if viewModel.hasValidDensity {
                HStack {
                    HStack(spacing: 2) {
                        Text(viewModel.lhsDensityAmountString)
                            .foregroundColor(Color(.label))
                        Text(viewModel.lhsDensityUnitString)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    Text("=")
                        .foregroundColor(Color(.tertiaryLabel))
                    HStack(spacing: 2) {
                        Text(viewModel.rhsDensityAmountString)
                            .foregroundColor(Color(.label))
                        Text(viewModel.rhsDensityUnitString)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            } else {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
        
        return Section(header: header, footer: footer) {
            NavigationLinkButton {
                viewModel.path.append(.densityForm)
            } label: {
                label
            }
//            NavigationLink(value: FoodForm.Route.densityForm) {
//                label
//            }
        }
    }
    var sizesSection: some View {
        var header: some View {
            Text("Sizes")
        }
        
        @ViewBuilder
        var footer: some View {
            Text("Sizes give you additional named units to log this food in, such as – biscuit, bottle, container, etc.")
                .foregroundColor(viewModel.standardSizes.isEmpty && viewModel.volumePrefixedSizes.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        var addButton: some View {
            Button {
                showingAddSizeForm = true
            } label: {
                Text("Add a size")
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
        }
        
        return Group {
            if viewModel.allSizes.isEmpty {
                Section(header: header, footer: footer) {
                    addButton
                }
            } else {
                Section(header: header) {
                    NavigationLinkButton {
                        viewModel.path.append(.sizesList)
                    } label: {
                        SizesCell()
                    }
                }
                Section(footer: footer) {
                    addButton
                }
            }
        }
    }
}
