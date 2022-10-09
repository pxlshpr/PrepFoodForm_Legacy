import SwiftUI
import SwiftUISugar
import SwiftHaptics
import Camera

extension FoodForm {
    struct DetailsForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @ObservedObject var nameViewModel: FieldViewModel
        

        @State var showingCodeScanner = false
        @State var showingSheet = false
        
        @State var nameString: String = ""
        
        @State var showingNameForm = false
    }
}

extension FoodForm.DetailsForm {
    var body: some View {
//        NavigationView {
            form
            .toolbar { bottomToolbarContent }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingNameForm) {
                NameForm(existingFieldViewModel: nameViewModel)
                    .environmentObject(viewModel)
            }

//        }
        .sheet(isPresented: $showingSheet) {
            FillForm()
        }
        .sheet(isPresented: $showingCodeScanner) {
            CodeScanner { result in
                showingCodeScanner = false
                
                switch result {
                case .success(let code):
                    viewModel.barcodeViewModel.fieldValue.stringValue.string = code
                case .failure(let error):
                    print("Scanning failed: \(error)")
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    func fillButton(stringValue: FieldValue.StringValue) -> some View {
        //TODO: In addition to hasNonUserInputFills, if it's empty—only show it if we have a value (particulkarly for detail)
        if viewModel.hasNonUserInputFills {
            Button {
                Haptics.feedback(style: .soft)
                showingSheet = true
            } label: {
                Image(systemName: stringValue.fill.buttonSystemImage)
                    .imageScale(.large)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var nameButton: some View {
        Button {
            showingNameForm = true
        } label: {
            HStack {
                if nameViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                } else {
                    Text(nameViewModel.fieldValue.stringValue.string)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    var detailButton: some View {
        NavigationLink {
            DetailForm()
                .environmentObject(viewModel)
        } label: {
            HStack {
                if viewModel.detailViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                } else {
                    Text(viewModel.detailViewModel.fieldValue.stringValue.string)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    var brandButton: some View {
        NavigationLink {
            BrandForm()
                .environmentObject(viewModel)
        } label: {
            HStack {
                if viewModel.brandViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                } else {
                    Text(viewModel.brandViewModel.fieldValue.stringValue.string)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    var barcodeButton: some View {
        Button {
            showingCodeScanner = true
        } label: {
            HStack {
                Text(viewModel.barcodeViewModel.fieldValue.isEmpty ? "Scan a barcode" : viewModel.barcodeViewModel.fieldValue.stringValue.string)
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    var form: some View {
//        Form {
        FormStyledScrollView {
//            Section("Name") {
            FormStyledSection(header: Text("Name")) {
                nameButton
            }
//            Section("Detail") {
            FormStyledSection(header: Text("Detail")) {
                detailButton
            }
//            Section("Brand") {
            FormStyledSection(header: Text("Brand")) {
                brandButton
            }
//            Section("Barcode") {
            FormStyledSection(header: Text("Barcode")) {
                barcodeButton
            }
        }
    }
    
    var emojiCell: some View {
        Group {
            if viewModel.emojiViewModel.fieldValue.isEmpty {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                Text(viewModel.emojiViewModel.fieldValue.stringValue.string)
                    .font(Font.system(size: 50.0))
            }
        }
//        Text(viewModel.emoji.isEmpty ? "Choose an emoji (required)" : viewModel.emoji)
//            .if(!viewModel.emoji.isEmpty) { text in
//                text.font(Font.system(size: 50.0))
//            }
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
            Image(systemName: "barcode.viewfinder")
        }
    }
}

struct DetailForm: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Optional", text: $viewModel.detailViewModel.fieldValue.stringValue.string)
                        .focused($isFocused)
                        .onSubmit {
                            dismiss()
                        }
                }
            }
        }
        .navigationBarTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
}

struct BrandForm: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    @FocusState var isFocused: Bool

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Optional", text: $viewModel.brandViewModel.fieldValue.stringValue.string)
                        .focused($isFocused)
                        .onSubmit {
                            dismiss()
                        }
                }
            }
        }
        .navigationBarTitle("Brand")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
}

struct DetailsFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    var body: some View {
        FoodForm.DetailsForm(nameViewModel: viewModel.nameViewModel)
            .environmentObject(viewModel)
    }
}

struct DetailsForm_Previews: PreviewProvider {
    
    static var previews: some View {
        DetailsFormPreview()
    }
}
