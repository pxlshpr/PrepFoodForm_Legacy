//import SwiftUI
//import SwiftUISugar
//
//public struct AmountPerForm: View {
//
//    @EnvironmentObject var viewModel: FoodFormViewModel
//    
//    @State var showingAddSizeForm = false
//    @State var showingDensityForm = false
//    
//    @State var sizeToEdit: Field?
//
//    @State var refreshBool: Bool = false
//
//    public var body: some View {
//        form
//        .navigationTitle("Amount Per")
//        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: $viewModel.showingNutrientsPerServingForm) { servingForm }
//        .sheet(isPresented: $viewModel.showingNutrientsPerAmountForm) { amountForm }
//        .sheet(item: $sizeToEdit) { sizeForm(for: $0) }
//    }
//    
//    var form: some View {
//        FormStyledScrollView {
//            fieldSection
//            if viewModel.shouldShowSizesSection {
//                sizesSection
//            }
//            if viewModel.shouldShowDensitiesSection {
//                densitySection
//            }
//        }
//    }
//    
//    var servingForm: some View {
//        ServingForm(existingFieldViewModel: viewModel.servingViewModel)
//            .environmentObject(viewModel)
//            .onDisappear {
//                refreshBool.toggle()
//            }
//    }
//    
//    func sizeForm(for sizeViewModel: Field) -> some View {
//        SizeForm(fieldViewModel: sizeViewModel) { sizeViewModel in
//            
//        }
//        .environmentObject(viewModel)
//    }
//    
//    var amountForm: some View {
//        AmountForm(existingFieldViewModel: viewModel.amountViewModel)
//            .environmentObject(viewModel)
//            .onDisappear {
//                refreshBool.toggle()
//            }
//    }
//   
//    var fieldSection: some View {
//        
//        var footer: some View {
//            Text("How much of this food the nutrition facts are for.")
//                .foregroundColor(viewModel.amountViewModel.value.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
//        }
//        
////        return Section(footer: footer) {
//        return FormStyledSection(footer: footer) {
//            amountField
//                .environmentObject(viewModel)
//                .id(refreshBool)
//        }
//    }
//    
//    var bottomToolbarContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .bottomBar) {
//            Spacer()
//            scanButton
//        }
//    }
//    
//    var scanButton: some View {
//        Button {
//            
//        } label: {
//            Image(systemName: "text.viewfinder")
//        }
//    }
//    
//    var densitySection: some View {
//        
//        var header: some View {
//            Text("Unit Conversion")
//        }
//        
//        return FormStyledSection(header: header, footer: densityFooter) {
//            NavigationLink {
//                densityForm
//            } label: {
//                HStack {
//                    Image(systemName: "arrow.triangle.swap")
//                        .foregroundColor(Color(.tertiaryLabel))
//                    if viewModel.hasValidDensity, let description = viewModel.densityDescription {
//                        Text(description)
//                            .foregroundColor(Color(.secondaryLabel))
//                    } else {
//                        Text("Optional")
//                            .foregroundColor(Color(.quaternaryLabel))
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    var densityFooter: some View {
//        Group {
//            if viewModel.isWeightBased {
//                Text("Enter this to be able to log this food using volume units, like cups.")
//            } else if viewModel.isVolumeBased {
//                Text("Enter this to be able to log this food using using its weight.")
//            }
//        }
//        .foregroundColor(!viewModel.hasValidDensity ? FormFooterEmptyColor : FormFooterFilledColor)
//    }
//    
//    var densityForm: some View {
//        DensityForm(
//            densityViewModel: viewModel.densityViewModel,
//            orderWeightFirst: viewModel.isWeightBased
//        )
//        .environmentObject(viewModel)
//    }
//    
//    var sizesSection: some View {
//        var header: some View {
//            Text("Sizes")
//        }
//        
//        @ViewBuilder
//        var footer: some View {
//            Text("Sizes give you additional named units to log this food in, such as – biscuit, bottle, container, etc.")
//                .foregroundColor(viewModel.standardSizeViewModels.isEmpty && viewModel.volumePrefixedSizeViewModels.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
//        }
//        
//        var addButton: some View {
//            Button {
//                showingAddSizeForm = true
//            } label: {
//                Text("Add a size")
//                    .foregroundColor(.accentColor)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .contentShape(Rectangle())
//            }
//            .buttonStyle(.borderless)
//            .sheet(isPresented: $showingAddSizeForm) {
//                SizeForm()
//                    .environmentObject(viewModel)
//            }
//        }
//        
//        return Group {
//            if viewModel.standardSizeViewModels.isEmpty, viewModel.volumePrefixedSizeViewModels.isEmpty {
//                FormStyledSection(header: header, footer: footer) {
//                    addButton
//                }
////            } else if viewModel.allSizeViewModels.count == 1 {
////                FormStyledSection(header: header) {
////                    Button {
////                        if !viewModel.standardSizeViewModels.isEmpty {
////                            sizeToEdit = viewModel.standardSizeViewModels[0]
////                        } else {
////                            sizeToEdit = viewModel.volumePrefixedSizeViewModels[0]
////                        }
////                    } label: {
////                        SizesCell(viewModel: viewModel)
////                    }
////                }
////                FormStyledSection(footer: footer) {
////                    addButton
////                }
//            } else {
//                FormStyledSection(header: header) {
//                    NavigationLink {
//                        SizesList()
//                            .environmentObject(viewModel)
//                    } label: {
//                        SizesCell()
//                            .environmentObject(viewModel)
//                    }
//                }
////                FormStyledSection(footer: footer) {
////                    addButton
////                }
//            }
//        }
//    }
//    
//    //MARK: - Amount Field
//    var amountField: some View {
//        HStack {
//            Spacer()
//            amountButton
//            if viewModel.shouldShowServingInField {
//                Spacer()
//                Text("of")
//                    .font(.title3)
//                    .foregroundColor(Color(.tertiaryLabel))
//                Spacer()
//                servingButton
//                Spacer()
//            }
//        }
//    }
//    
//    var amountButton: some View {
//        NavigationLink {
//            amountForm
//        } label: {
//            label(viewModel.amountViewModel.doubleValueDescription, placeholder: "Required")
//        }
//    }
//    
//    var servingButton: some View {
//        NavigationLink {
//            servingForm
//        } label: {
//            label(viewModel.servingViewModel.doubleValueDescription, placeholder: "serving size")
//        }
//        .buttonStyle(.borderless)
//    }
//    
//    func label(_ string: String, placeholder: String) -> some View {
//        Group {
//            if string.isEmpty {
//                HStack(spacing: 5) {
//                    Text(placeholder)
//                        .foregroundColor(Color(.quaternaryLabel))
//                }
//            } else {
//                Text(string)
//            }
//        }
//        .foregroundColor(.accentColor)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .contentShape(Rectangle())
//    }
//}
//
//struct AmountPerFormPreview: View {
//    @StateObject var viewModel = FoodFormViewModel()
//    
//    public init() {
//        let viewModel = FoodFormViewModel.mock(for: .spinach)
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//
//    var body: some View {
//        NavigationView {
//            AmountPerForm()
//            .environmentObject(viewModel)
//        }
//    }
//}
//struct AmountPerForm_Previews: PreviewProvider {
//    static var previews: some View {
//        AmountPerFormPreview()
//    }
//}
