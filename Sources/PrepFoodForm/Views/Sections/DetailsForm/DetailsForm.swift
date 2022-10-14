import SwiftUI
import SwiftUISugar
import SwiftHaptics
import Camera

extension FoodForm {
    struct DetailsForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @ObservedObject var nameViewModel: FieldViewModel
        @ObservedObject var detailViewModel: FieldViewModel
        @ObservedObject var brandViewModel: FieldViewModel
        @ObservedObject var barcodeViewModel: FieldViewModel
        @ObservedObject var emojiViewModel: FieldViewModel

        @State var showingCodeScanner = false
    }
}

extension FoodForm.DetailsForm {
    var body: some View {
        form
        .toolbar { bottomToolbarContent }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.large)
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
    

    func form(for fieldViewModel: FieldViewModel) -> some View {
        StringFieldValueForm(existingFieldViewModel: fieldViewModel)
            .environmentObject(viewModel)
    }
    
    var nameButton: some View {
        NavigationLink {
            form(for: nameViewModel)
        } label: {
            HStack {
                if nameViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                } else {
                    Text(nameViewModel.fieldValue.stringValue.string)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    var detailButton: some View {
        NavigationLink {
            form(for: detailViewModel)
        } label: {
            HStack {
                if detailViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                } else {
                    Text(detailViewModel.fieldValue.stringValue.string)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
    
    var brandButton: some View {
        NavigationLink {
            form(for: brandViewModel)
        } label: {
            HStack {
                if brandViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                } else {
                    Text(brandViewModel.fieldValue.stringValue.string)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
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
                Text(barcodeViewModel.fieldValue.isEmpty ? "Scan a barcode" : barcodeViewModel.fieldValue.stringValue.string)
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
            if emojiViewModel.fieldValue.isEmpty {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                Text(emojiViewModel.fieldValue.stringValue.string)
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
        FoodForm.DetailsForm(
            nameViewModel: viewModel.nameViewModel,
            detailViewModel: viewModel.detailViewModel,
            brandViewModel: viewModel.brandViewModel,
            barcodeViewModel: viewModel.barcodeViewModel,
            emojiViewModel: viewModel.emojiViewModel
        )
            .environmentObject(viewModel)
    }
}

struct DetailsForm_Previews: PreviewProvider {
    
    static var previews: some View {
        DetailsFormPreview()
    }
}
