import SwiftUI

extension FoodForm {
    public struct NutrientsPerForm: View {

        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingAddSizeForm = false
        @State var showingDensityForm = false
        
        public init() { }
    }
}

extension FoodForm.NutrientsPerForm {
    public var body: some View {
        form
//        .onChange(of: viewModel.standardSizes) { newValue in
//            viewModel.updateSummary()
//        }
//        .onChange(of: viewModel.volumePrefixedSizes) { newValue in
//            viewModel.updateSummary()
//        }
        .toolbar { bottomToolbarContent }
        .navigationTitle("Amount Per")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .interactiveDismissDisabled()
        .sheet(isPresented: $viewModel.showingNutrientsPerAmountForm) {
            FoodForm.NutrientsPerForm.AmountForm()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $viewModel.showingNutrientsPerServingForm) {
            NavigationView {
                FoodForm.NutrientsPerForm.ServingForm()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            /// If it's present the amount form as the empty form is redundant to display
            if !viewModel.hasNutrientsPerContent {
                viewModel.showingNutrientsPerAmountForm = true
            }
        }
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
                .foregroundColor(viewModel.amount.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
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
                Text("Weight-to-Volume Conversion")
            } else if viewModel.isVolumeBased {
                Text("Volume-to-Weight Conversion")
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
            Button {
                showingDensityForm = true
            } label: {
                label
            }
            .sheet(isPresented: $showingDensityForm) {
                densityForm
            }
        }
    }
    
    var densityForm: some View {
        NavigationView {
            FoodForm.NutrientsPerForm.DensityForm(orderWeightFirst: viewModel.isWeightBased)
                .environmentObject(viewModel)
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
            .sheet(isPresented: $showingAddSizeForm) {
                SizeForm()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        return Group {
            if viewModel.standardSizes.isEmpty, viewModel.volumePrefixedSizes.isEmpty {
                Section(header: header, footer: footer) {
                    addButton
                }
            } else {
                Section(header: header) {
                    NavigationLink {
                        SizesList()
                            .environmentObject(viewModel)
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
