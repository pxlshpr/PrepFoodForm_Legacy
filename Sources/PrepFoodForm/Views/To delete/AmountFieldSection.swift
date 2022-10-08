//import SwiftUI
//import PrepUnits
//import SwiftHaptics
//
//extension FoodForm.NutrientsPerForm {
//    struct AmountFieldSection: View {
//        @EnvironmentObject var viewModel: FoodFormViewModel
//        @State var showingAmountUnits = false
//        @State var showingSizeForm = false
//    }
//}
//
//extension FoodForm.NutrientsPerForm.AmountFieldSection {
//    
//    var body: some View {
//        Section(header: header, footer: footer) {
//            HStack(spacing: 0) {
//                textField
//                unitButton
//            }
//        }
//        .sheet(isPresented: $showingAmountUnits) {
//            UnitPicker(
//                sizes: viewModel.allSizes,
//                pickedUnit: viewModel.amountUnit
//            ) {
//                showingSizeForm = true
//            } didPickUnit: { unit in
//                withAnimation {
//                    viewModel.amountUnit = unit
//                }
//            }
//            .sheet(isPresented: $showingSizeForm) {
//                SizeForm(includeServing: false, allowAddSize: false) { size in
//                    withAnimation {
//                        viewModel.amountUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            Haptics.feedback(style: .rigid)
//                            showingAmountUnits = false
//                        }
//                    }
//                }
//                .environmentObject(viewModel)
//                .presentationDetents([.medium, .large])
//                .presentationDragIndicator(.hidden)
//            }
//        }
//    }
//    
//    var textField: some View {
//        TextField("Required", text: $viewModel.amountString)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//    }
//    
//    var unitButton: some View {
//        Button {
//            showingAmountUnits = true
////            viewModel.path.append(.amountUnitSelector)
//        } label: {
//            HStack(spacing: 5) {
//                Text(viewModel.amountUnitShortString)
//                Image(systemName: "chevron.up.chevron.down")
//                    .imageScale(.small)
//            }
//        }
//        .buttonStyle(.borderless)
//    }
//
//    var header: some View {
//        Text("Amount")
//    }
//    
//    @ViewBuilder
//    var footer: some View {
//        Text("This is how much of this food the nutritional values are for. You'll be able to log this food using the unit you choose.")
//            .foregroundColor(viewModel.amountString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
//    }
//}
