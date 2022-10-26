import SwiftUI
import SwiftUISugar
import Introspect
import SwiftHaptics

extension FoodForm {
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                DetailsForm(name: $name, detail: $detail, brand: $brand)
//                DetailsForm()
//                    .environmentObject(viewModel)
            } label: {
                DetailsView(emoji: $emoji, name: $name, detail: $detail, brand: $brand)
//                DetailsCell()
//                    .environmentObject(viewModel)
//                    .buttonStyle(.borderless)
            }
        }
    }
}

//TODO: Move this to PrepViews

struct DetailsView: View {
    
    @Binding var emoji: String
    @Binding var name: String
    @Binding var detail: String
    @Binding var brand: String

    var body: some View {
        Group {
            if isEmpty {
                Text("Required")
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                HStack {
                    emojiButton
                    VStack(alignment: .leading) {
                        nameText
                        detailText
                            .foregroundColor(.secondary)
                        brandText
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    Spacer()
                }
                .foregroundColor(.primary)
            }
        }
    }
    
    var emojiButton: some View {
        Button {
//            viewModel.showingEmojiPicker = true
        } label: {
            Text(emoji)
                .font(.system(size: 50))
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var nameText: some View {
        if !name.isEmpty {
            Text(name)
                .bold()
                .multilineTextAlignment(.leading)
        } else {
            Text("Required")
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    @ViewBuilder
    var detailText: some View {
        if !detail.isEmpty {
            Text(detail)
                .multilineTextAlignment(.leading)
        }
    }

    @ViewBuilder
    var brandText: some View {
        if !brand.isEmpty {
            Text(brand)
                .multilineTextAlignment(.leading)
        }
    }
    
    var isEmpty: Bool {
        name.isEmpty && emoji.isEmpty && detail.isEmpty && brand.isEmpty
    }
}


struct DetailsForm: View {

    enum FocusedField {
        case name, detail, brand
    }
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusedField?

    @Binding var name: String
    @Binding var detail: String
    @Binding var brand: String
    
    @State var fieldFocus: [Bool] = [false, false, false]
    @State var hasBecomeFirstResponder: Bool = false
    @State var returnedOnLastField: Bool = false
    
    var body: some View {
        form
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.large)
            .scrollDismissesKeyboard(.interactively)
            .interactiveDismissDisabled()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    fieldFocus[0] = true
                }
            }
            .onChange(of: returnedOnLastField) { newValue in
                if newValue {
                    dismiss()
                }
            }
    }
    
    var form: some View {
        Form {
            Section("Name") {
                field(textField: nameTextField, text: $name, fieldIndex: 0)
            }
            Section("Detail") {
                field(textField: detailTextField, text: $detail, fieldIndex: 1)
            }
            Section("Brand") {
                field(textField: brandTextField, text: $brand, fieldIndex: 2)
            }
        }
    }
    
    func field(textField: some View, text: Binding<String>, fieldIndex: Int) -> some View {
        HStack {
            textField
            clearButton(text: text, fieldIndex: fieldIndex)
        }
    }
    
    func clearButton(text: Binding<String>, fieldIndex: Int) -> some View {
        Button {
            Haptics.feedback(style: .rigid)
            text.wrappedValue = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.quaternaryLabel))
        }
        .opacity((fieldFocus[fieldIndex] && !text.wrappedValue.isEmpty) ? 1 : 0)
        .animation(.default, value: text.wrappedValue)
    }

    var nameTextField: some View {
        FormTextField (
            placeholder: "Required",
            text: $name,
            focusable: $fieldFocus,
            returnedOnLastField: $returnedOnLastField,
            returnKeyType: .next,
            autocapitalizationType: .words,
            keyboardType: .default,
            tag: 0
        )
    }
    
    var detailTextField: some View {
        FormTextField (
            placeholder: "Optional",
            text: $detail,
            focusable: $fieldFocus,
            returnedOnLastField: $returnedOnLastField,
            returnKeyType: .next,
            autocapitalizationType: .words,
            keyboardType: .default,
            tag: 1
        )
    }
    
    var brandTextField: some View {
        FormTextField (
            placeholder: "Optional",
            text: $brand,
            focusable: $fieldFocus,
            returnedOnLastField: $returnedOnLastField,
            returnKeyType: .done,
            autocapitalizationType: .words,
            keyboardType: .default,
            tag: 2
        )
    }
}
