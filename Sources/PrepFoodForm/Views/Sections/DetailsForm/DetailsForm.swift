import SwiftUI
import SwiftUISugar
import SwiftHaptics
import Camera

extension FoodForm {
    struct DetailsForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingCodeScanner = false
        @State var showingSheet = false
        
        @State var nameString: String = ""
    }
}

extension FoodForm.DetailsForm {
    var body: some View {
//        NavigationView {
            form
            .toolbar { bottomToolbarContent }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
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
        //TODO: In addition to shouldShowFillButton, if it's empty—only show it if we have a value (particulkarly for detail)
        if viewModel.shouldShowFillButton {
            Button {
                Haptics.feedback(style: .soft)
                showingSheet = true
            } label: {
                Image(systemName: stringValue.fillType.buttonSystemImage)
                    .imageScale(.large)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var form: some View {
        Form {
            Section("Name") {
                NavigationLink {
                    NameForm()
                        .environmentObject(viewModel)
                } label: {
                    if viewModel.nameViewModel.fieldValue.stringValue.string.isEmpty {
                        Text("Required")
                            .foregroundColor(Color(.tertiaryLabel))
                    } else {
                        Text(viewModel.nameViewModel.fieldValue.stringValue.string)
                    }
                }
//                HStack {
//                    TextField("Required", text: $viewModel.name.stringValue.string)
//                    fillButton(stringValue: viewModel.name.stringValue)
//                }
            }
            Section("Detail") {
                NavigationLink {
                    DetailForm()
                        .environmentObject(viewModel)
                } label: {
                    if viewModel.detailViewModel.fieldValue.stringValue.string.isEmpty {
                        Text("Optional")
                            .foregroundColor(Color(.quaternaryLabel))
                    } else {
                        Text(viewModel.detailViewModel.fieldValue.stringValue.string)
                    }
                }
//                HStack {
//                    TextField("", text: $viewModel.detail.stringValue.string)
//                        .placeholder(when: viewModel.detail.isEmpty) {
//                            Text("Optional").foregroundColor(Color(.quaternaryLabel))
//                        }
//                    fillButton(stringValue: viewModel.detail.stringValue)
//                }
            }
            Section("Brand") {
                NavigationLink {
                    BrandForm()
                        .environmentObject(viewModel)
                } label: {
                    if viewModel.brandViewModel.fieldValue.stringValue.string.isEmpty {
                        Text("Optional")
                            .foregroundColor(Color(.quaternaryLabel))
                    } else {
                        Text(viewModel.brandViewModel.fieldValue.stringValue.string)
                    }
                }
//                HStack {
//                    TextField("", text: $viewModel.brand.stringValue.string)
//                        .placeholder(when: viewModel.brand.isEmpty) {
//                            Text("Optional").foregroundColor(Color(.quaternaryLabel))
//                        }
//                    fillButton(stringValue: viewModel.brand.stringValue)
//                }
            }
            Section("Barcode") {
                Button {
                    showingCodeScanner = true
                } label: {
                    Text(viewModel.barcodeViewModel.fieldValue.isEmpty ? "Scan a barcode" : viewModel.barcodeViewModel.fieldValue.stringValue.string)
                }
//                TextField("", text: $brand)
//                    .keyboardType(.alphabet)
//                    .autocorrectionDisabled()
//                    .autocapitalization(.allCharacters)
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

struct NameForm: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    @FocusState var isFocused: Bool

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Required", text: $viewModel.nameViewModel.fieldValue.stringValue.string)
                        .focused($isFocused)
                        .onSubmit {
                            dismiss()
                        }
                }
            }
        }
        .navigationBarTitle("Name")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
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
        FoodForm.DetailsForm()
            .environmentObject(viewModel)
    }
}

struct DetailsForm_Previews: PreviewProvider {
    
    static var previews: some View {
        DetailsFormPreview()
    }
}
