//import SwiftUI
//import PrepUnits
//import SwiftHaptics
//
//extension FoodForm.NutrientsPerForm {
//    struct ServingSizeFieldSection: View {
//        @EnvironmentObject var viewModel: FoodFormViewModel
//        @State var showingServingUnits = false
//        @State var showingSizeForm = false
//    }
//}
//
//extension FoodForm.NutrientsPerForm.ServingSizeFieldSection {
//
//    var body: some View {
//        Section(header: header, footer: footer) {
//            HStack(spacing: 0) {
//                textField
//                unitButton
//            }
//        }
//        .sheet(isPresented: $showingServingUnits) {
//            UnitPicker(
//                sizes: viewModel.allSizes,
//                pickedUnit: viewModel.servingUnit,
//                includeServing: false)
//            {
//                showingSizeForm = true
//            } didPickUnit: { unit in
//                withAnimation {
//                    if unit.isServingBased {
//                        viewModel.modifyServingAmount(for: unit)
//                    }
//                    viewModel.servingUnit = unit
//                }
//            }
//            .sheet(isPresented: $showingSizeForm) {
//                SizeForm(includeServing: true, allowAddSize: false) { size in
//                    withAnimation {
//                        viewModel.servingUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            Haptics.feedback(style: .rigid)
//                            showingServingUnits = false
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
//        TextField("", text: $viewModel.servingString)
//            .multilineTextAlignment(.leading)
//            .keyboardType(.decimalPad)
//            .placeholder(when: viewModel.servingString.isEmpty) {
//                Text("Optional").foregroundColor(Color(.quaternaryLabel))
//            }
//    }
//
//    var unitButton: some View {
//        Button {
//            showingServingUnits = true
////            viewModel.path.append(.servingUnitSelector)
//        } label: {
//            HStack(spacing: 5) {
//                Text(viewModel.servingUnitShortString)
//                Image(systemName: "chevron.up.chevron.down")
//                    .imageScale(.small)
//            }
//        }
//        .buttonStyle(.borderless)
//    }
//
//    var header: some View {
//        Text(viewModel.servingSizeHeaderString)
//    }
//
//    @ViewBuilder
//    var footer: some View {
//        Text(viewModel.servingSizeFooterString)
//            .foregroundColor(viewModel.servingString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
//    }
//}
