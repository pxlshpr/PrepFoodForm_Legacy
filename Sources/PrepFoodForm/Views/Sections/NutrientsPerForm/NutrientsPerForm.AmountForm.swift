import SwiftUI
import SwiftHaptics

extension FoodForm.NutrientsPerForm {
    struct AmountForm: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var viewModel: FoodFormViewModel
        @State var showingUnitPicker = false
        @State var showingSizeForm = false
        @FocusState var isFocused
        
        @State var showingSheet = false
        @State var fieldSourceType = "viewfinder.circle.fill"
    }
}

extension FoodForm.NutrientsPerForm.AmountForm {
    
    var body: some View {
        form
        .navigationTitle("Amount Per")
        .onAppear {
            isFocused = true
        }
        .toolbar { keyboardToolbarContents }
    }
    
    var keyboardToolbarContents: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("Units") {
                showingUnitPicker = true
            }
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
    }
    var fieldSourceTypeButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingSheet = true
        } label: {
//            Image(systemName: "link.circle.fill")
//            Image(systemName: "photo.circle.fill")
            Image(systemName: fieldSourceType)
                .imageScale(.large)
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                Form {
                    Section {
                        Text("This value was manually filled in by you.")
                    }
                    Section("Fill-in from source images") {
                        Button {
                            
                        } label: {
                            Label("Auto-fill", systemImage: "text.viewfinder")
                        }
                        Button {
                            
                        } label: {
                            Label("Pick a text", systemImage: "photo")
                        }
                    }
                    Section("Fill-in from third-party food") {
                        Button {
                            
                        } label: {
                            Label("Auto-fill", systemImage: "link")
                        }
                    }
                }
                .navigationTitle("Manually filled")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.height(300), .medium])
            .presentationDragIndicator(.hidden)
        }
    }
    
    var form: some View {
        Form {
            Section(header: header, footer: footer) {
                HStack {
                    textField
                    unitButton
                    fieldSourceTypeButton
                }
            }
        }
        .onChange(of: viewModel.amountString) { newValue in
            fieldSourceType = "pencil.circle.fill"
        }
        .sheet(isPresented: $showingUnitPicker) {
            UnitPicker(
                sizes: viewModel.allSizes,
                pickedUnit: viewModel.amountUnit
            ) {
                showingSizeForm = true
            } didPickUnit: { unit in
                withAnimation {
                    viewModel.amountUnit = unit
                }
            }
            .sheet(isPresented: $showingSizeForm) {
                SizeForm(includeServing: false, allowAddSize: false) { size in
                    withAnimation {
                        viewModel.amountUnit = .size(size, size.volumePrefixUnit?.defaultVolumeUnit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            Haptics.feedback(style: .rigid)
                            showingUnitPicker = false
                        }
                    }
                }
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
        }
    }
    
    var textField: some View {
        TextField("Required", text: $viewModel.amountString)
            .multilineTextAlignment(.leading)
            .keyboardType(.decimalPad)
            .focused($isFocused)
    }
    
    var unitButton: some View {
//        Text(viewModel.amountUnitShortString)
//            .foregroundColor(.secondary)
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.amountUnitShortString)
//                Image(systemName: "chevron.up.chevron.down")
//                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var header: some View {
        Text(viewModel.amountFormHeaderString)
    }
    
    @ViewBuilder
    var footer: some View {
        Text("This is how much of this food the nutrition facts are for. You'll be able to log this food using the unit you choose.")
            .foregroundColor(viewModel.amountString.isEmpty ? FormFooterEmptyColor : FormFooterFilledColor)
    }
}

struct AmountFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    var body: some View {
        FoodForm.NutrientsPerForm.AmountForm()
            .environmentObject(viewModel)
    }
}

struct AmountForm_Previews: PreviewProvider {
    
    static var previews: some View {
        AmountFormPreview()
    }
}
