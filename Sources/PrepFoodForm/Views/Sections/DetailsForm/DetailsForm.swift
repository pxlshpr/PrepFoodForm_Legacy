import SwiftUI
import SwiftUISugar
import CodeScanner

extension FoodForm {
    
    struct DetailsForm: View {
        
        @ObservedObject var viewModel: ViewModel
        
        @State var showingEmojiPicker = false
        @State var showingCodeScanner = false
    }
}

extension FoodForm.DetailsForm {
    var body: some View {
        NavigationView {
            form
            .toolbar { bottomToolbarContent }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingEmojiPicker) {
            FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji)
        }
        .sheet(isPresented: $showingCodeScanner) {
            CodeScanner(handleScan: self.handleScan)
        }
    }
    
    var form: some View {
        Form {
            Section("Name") {
                TextField("Required", text: $viewModel.name)
            }
            Section("Emoji") {
                Button {
                    showingEmojiPicker = true
                } label: {
                    emojiCell
                }
            }
            Section("Detail") {
                TextField("", text: $viewModel.detail)
            }
            Section("Brand") {
                TextField("", text: $viewModel.brand)
            }
            Section("Barcode") {
                Button {
                    showingCodeScanner = true
                } label: {
                    Text(viewModel.barcode.isEmpty ? "Scan a barcode" : viewModel.barcode)
                }
//                TextField("", text: $brand)
//                    .keyboardType(.alphabet)
//                    .autocorrectionDisabled()
//                    .autocapitalization(.allCharacters)
            }
        }
    }
    
    var emojiCell: some View {
        Text(viewModel.emoji.isEmpty ? "Choose an emoji (required)" : viewModel.emoji)
            .if(!viewModel.emoji.isEmpty) { text in
                text.font(Font.system(size: 50.0))
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
            Image(systemName: "barcode.viewfinder")
        }
    }
    
    func handleScan(result: Result<String, CodeScanner.ScanError>) {
        showingCodeScanner = false
        
        switch result {
        case .success(let code):
            viewModel.barcode = code
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }
}
