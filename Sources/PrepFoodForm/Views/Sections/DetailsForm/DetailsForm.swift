import SwiftUI
import SwiftUISugar
import SwiftHaptics
import Camera

extension FoodForm {
    struct DetailsForm: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @State var showingCodeScanner = false
    }
}

extension FoodForm.DetailsForm {
    var body: some View {
        basicForm
//        formWithTextPickers
//        .toolbar { bottomToolbarContent }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.large)
        .scrollDismissesKeyboard(.interactively)
        .interactiveDismissDisabled()
    }
    
    //MARK: - Basic Form
    var basicForm: some View {
        Form {
            Section("Name") {
                TextField("Required", text: $viewModel.nameViewModel.fieldValue.string)
            }
            Section("Detail") {
                TextField("Optional", text: $viewModel.detailViewModel.fieldValue.string)
            }
            Section("Brand") {
                TextField("Optional", text: $viewModel.brandViewModel.fieldValue.string)
            }
        }
    }
    
    //MARK: - Form with TextPickers
    var formWithTextPickers: some View {
        FormStyledScrollView {
            FormStyledSection(header: Text("Name")) {
                nameButton
            }
            FormStyledSection(header: Text("Detail")) {
                detailButton
            }
            FormStyledSection(header: Text("Brand")) {
                brandButton
            }
        }
    }
    
    func form(for fieldViewModel: FieldViewModel) -> some View {
        StringFieldValueForm(existingFieldViewModel: fieldViewModel)
            .environmentObject(viewModel)
    }
    
    var nameButton: some View {
        NavigationLink {
            StringFieldValueForm(existingFieldViewModel: viewModel.nameViewModel)
                .environmentObject(viewModel)
//            form(for: nameViewModel)
        } label: {
            HStack {
                if viewModel.nameViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                } else {
                    Text(viewModel.nameViewModel.fieldValue.stringValue.string)
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
            form(for: viewModel.detailViewModel)
        } label: {
            HStack {
                if viewModel.detailViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                } else {
                    Text(viewModel.detailViewModel.fieldValue.stringValue.string)
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
            form(for: viewModel.brandViewModel)
        } label: {
            HStack {
                if viewModel.brandViewModel.fieldValue.stringValue.string.isEmpty {
                    Text("Optional")
                        .foregroundColor(Color(.quaternaryLabel))
                } else {
                    Text(viewModel.brandViewModel.fieldValue.stringValue.string)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .contentShape(Rectangle())
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
        FoodForm.DetailsForm()
        .environmentObject(viewModel)
    }
}

struct DetailsForm_Previews: PreviewProvider {
    
    static var previews: some View {
        DetailsFormPreview()
    }
}
