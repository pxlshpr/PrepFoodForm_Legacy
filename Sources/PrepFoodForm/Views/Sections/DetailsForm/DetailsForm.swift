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
            FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji)
        }
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                Form {
                    Section {
                        Text("This value was pre-filled from the following third-party food.")
                    }
                    Section {
                        Button {
                            
                        } label: {
                            HStack {
                                HStack {
                                    Image(systemName: "link")
                                    Text("Website")
                                }
                                .foregroundColor(.secondary)
                                Spacer()
                                Text("MyFitnessPal")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                .navigationTitle("Pre-filled")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.height(300), .medium])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingCodeScanner) {
            CodeScanner(handleScan: self.handleScan)
        }
        .scrollDismissesKeyboard(.interactively)
        .interactiveDismissDisabled()
    }
    
    var form: some View {
        Form {
            Section("Name") {
                HStack {
                    TextField("Required", text: $viewModel.name.string)
                    Button {
                        Haptics.feedback(style: .soft)
                        showingSheet = true
                    } label: {
                        Image(systemName: "link.circle.fill")
//                        Image(systemName: "photo.circle.fill")
//                        Image(systemName: "viewfinder.circle.fill")
                            .imageScale(.large)
                    }
                    .buttonStyle(.borderless)
                }
            }
            Section("Emoji") {
                NavigationLink {
                    FoodForm.DetailsForm.EmojiPicker(emoji: $viewModel.emoji)
                } label: {
                    emojiCell
                }
            }
            Section("Detail") {
                HStack {
                    TextField("", text: $viewModel.detail.string)
                        .placeholder(when: viewModel.detail.isEmpty) {
                            Text("Optional").foregroundColor(Color(.quaternaryLabel))
                        }
                    Button {
                        Haptics.feedback(style: .soft)
                        showingSheet = true
                    } label: {
//                        Image(systemName: "link.circle.fill")
//                        Image(systemName: "photo.circle.fill")
                        Image(systemName: "viewfinder.circle.fill")
                            .imageScale(.large)
                    }
                    .buttonStyle(.borderless)
                }
            }
            Section("Brand") {
                TextField("", text: $viewModel.brand)
                    .placeholder(when: viewModel.brand.isEmpty) {
                        Text("Optional").foregroundColor(Color(.quaternaryLabel))
                    }
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
        Group {
            if viewModel.emoji.isEmpty {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                Text(viewModel.emoji)
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
            viewModel.barcode = code
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
