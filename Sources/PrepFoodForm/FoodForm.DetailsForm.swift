import SwiftUI
import SwiftUISugar
import CodeScanner

extension FoodForm {
    struct DetailsForm: View {
        @State var isPresentingEmojiPicker = false
        @State var isPresentingBarcodeScanner = false
        @State var name = ""
        @State var emoji = ""
        @State var detail = ""
        @State var brand = ""
        @State var barcode = ""
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
        .sheet(isPresented: $isPresentingEmojiPicker) {
            FoodForm.DetailsForm.EmojiPicker(emoji: $emoji)
        }
        .sheet(isPresented: $isPresentingBarcodeScanner) {
            CodeScanner(handleScan: self.handleScan)
        }
    }
    
    var form: some View {
        Form {
            Section("Name") {
                TextField("Required", text: $name)
            }
            Section("Emoji") {
                Button {
                    isPresentingEmojiPicker = true
                } label: {
                    emojiCell
                }
            }
            Section("Detail") {
                TextField("", text: $detail)
            }
            Section("Brand") {
                TextField("", text: $brand)
            }
            Section("Barcode") {
                Button {
                    isPresentingBarcodeScanner = true
                } label: {
                    Text(barcode.isEmpty ? "Scan a barcode" : barcode)
                }
//                TextField("", text: $brand)
//                    .keyboardType(.alphabet)
//                    .autocorrectionDisabled()
//                    .autocapitalization(.allCharacters)
            }
        }
    }
    
    var emojiCell: some View {
        Text(emoji.isEmpty ? "Choose an emoji (required)" : emoji)
            .if(!emoji.isEmpty) { text in
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
        isPresentingBarcodeScanner = false
        
        switch result {
        case .success(let code):
            barcode = code
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }
}
