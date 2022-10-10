import SwiftUI

extension FoodForm {
    public struct NutrientsPerForm: View {

        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @ObservedObject var densityViewModel: FieldViewModel
        
        @State var showingAddSizeForm = false
        @State var showingDensityForm = false
        
        @State var sizeToEdit: FieldViewModel?

        @State var refreshBool: Bool = false        
    }
}

extension FoodForm.NutrientsPerForm {
    public var body: some View {
        NavigationView {
            form
            .navigationTitle("Amount Per")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $viewModel.showingNutrientsPerServingForm) {
            ServingForm(existingFieldViewModel: viewModel.servingViewModel)
                .environmentObject(viewModel)
                .onDisappear {
                    refreshBool.toggle()
                }
        }
        .sheet(isPresented: $viewModel.showingNutrientsPerAmountForm) {
            AmountForm(existingFieldViewModel: viewModel.amountViewModel)
                .environmentObject(viewModel)
                .onDisappear {
                    refreshBool.toggle()
                }
        }
        .sheet(item: $sizeToEdit) { sizeViewModel in
            SizeForm(fieldViewModel: sizeViewModel) { sizeViewModel in
                
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
                .foregroundColor(viewModel.amountViewModel.fieldValue.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
        }
        
        return Section(footer: footer) {
            AmountField()
                .environmentObject(viewModel)
                .id(refreshBool)
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
        
        var header: some View {
            Text("Unit Conversion")
        }
        
        return Section(header: header, footer: densityFooter) {
            Button {
                showingDensityForm = true
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.swap")
                        .foregroundColor(Color(.tertiaryLabel))
                    if viewModel.hasValidDensity, let description = viewModel.densityDescription {
                        Text(description)
                            .foregroundColor(Color(.secondaryLabel))
                    } else {
                        Text("Optional")
                            .foregroundColor(Color(.quaternaryLabel))
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $showingDensityForm) {
                densityForm
            }

        }
    }
    
    @ViewBuilder
    var densityFooter: some View {
        Group {
            if viewModel.isWeightBased {
                Text("Enter this to be able to log this food using volume units, like cups.")
            } else if viewModel.isVolumeBased {
                Text("Enter this to be able to log this food using using its weight.")
            }
        }
        .foregroundColor(!viewModel.hasValidDensity ? FormFooterEmptyColor : FormFooterFilledColor)
    }

    var densitySection_legacy: some View {
        @ViewBuilder
        var header: some View {
            if viewModel.isWeightBased {
                Text("Weight-to-Volume Conversion")
            } else if viewModel.isVolumeBased {
                Text("Volume-to-Weight Conversion")
            }
        }
        
        @ViewBuilder
        var label: some View {
            if viewModel.hasValidDensity, let description = viewModel.densityDescription {
                Text(description)
                    .foregroundColor(.primary)
            } else {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
        
        return Section(header: header, footer: densityFooter) {
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
            DensityForm(
                densityViewModel: viewModel.densityViewModel,
                orderWeightFirst: viewModel.isWeightBased
            )
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
                .foregroundColor(viewModel.standardSizeViewModels.isEmpty && viewModel.volumePrefixedSizeViewModels.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
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
            }
        }
        
        return Group {
            if viewModel.standardSizeViewModels.isEmpty, viewModel.volumePrefixedSizeViewModels.isEmpty {
                Section(header: header, footer: footer) {
                    addButton
                }
            } else if viewModel.allSizeViewModels.count == 1 {
                Section(header: header) {
                    Button {
                        if !viewModel.standardSizeViewModels.isEmpty {
                            sizeToEdit = viewModel.standardSizeViewModels[0]
                        } else {
                            sizeToEdit = viewModel.volumePrefixedSizeViewModels[0]
                        }
                    } label: {
                        SizesCell()
                    }
                }
                Section(footer: footer) {
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
