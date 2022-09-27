import SwiftUI
import SwiftUISugar
import CodeScanner
import SwiftHaptics

extension FoodForm {
    struct DetailsForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingEmojiPicker = false
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
        .sheet(isPresented: $showingEmojiPicker) {
            FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji.stringValue.string)
        }
        .sheet(isPresented: $showingSheet) {
            FillForm()
        }
        .sheet(isPresented: $showingCodeScanner) {
            CodeScanner(handleScan: self.handleScan)
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
                HStack {
                    TextField("Required", text: $viewModel.name.stringValue.string)
                    fillButton(stringValue: viewModel.name.stringValue)
                }
            }
            Section("Emoji") {
                NavigationLink {
                    FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji.stringValue.string)
                } label: {
                    emojiCell
                }
            }
            Section("Detail") {
                HStack {
                    TextField("", text: $viewModel.detail.stringValue.string)
                        .placeholder(when: viewModel.detail.isEmpty) {
                            Text("Optional").foregroundColor(Color(.quaternaryLabel))
                        }
                    fillButton(stringValue: viewModel.detail.stringValue)
                }
            }
            Section("Brand") {
                HStack {
                    TextField("", text: $viewModel.brand.stringValue.string)
                        .placeholder(when: viewModel.brand.isEmpty) {
                            Text("Optional").foregroundColor(Color(.quaternaryLabel))
                        }
                    fillButton(stringValue: viewModel.brand.stringValue)
                }
            }
            Section("Barcode") {
                Button {
                    showingCodeScanner = true
                } label: {
                    Text(viewModel.barcode.isEmpty ? "Scan a barcode" : viewModel.barcode.stringValue.string)
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
            if viewModel.emoji.isEmpty {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                Text(viewModel.emoji.stringValue.string)
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
    
    func handleScan(result: Result<String, CodeScanner.ScanError>) {
        showingCodeScanner = false
        
        switch result {
        case .success(let code):
            viewModel.barcode.stringValue.string = code
        case .failure(let error):
            print("Scanning failed: \(error)")
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
