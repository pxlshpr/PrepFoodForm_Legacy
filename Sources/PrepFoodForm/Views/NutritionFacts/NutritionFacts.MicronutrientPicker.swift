import SwiftUI
import PrepUnits
import SwiftHaptics
import Introspect

extension FoodForm.NutritionFacts {
    public struct MicronutrientPicker: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme
        
        @State var showingMicroFieldViewModel: FieldViewModel?
        
        @State private var searchText = ""
        @State var showingSearchLayer: Bool = false
        @FocusState var isFocused: Bool
        @State var hasBecomeFirstResponder: Bool = false
    }
}

extension FoodForm.NutritionFacts.MicronutrientPicker {
    public var body: some View {
        NavigationView {
            ZStack {
                form
//                if showingSearchLayer {
                    ZStack {
                        searchLayer
                    }
//                }
            }
            .navigationTitle("Micronutrients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { navigationLeadingContent }
            .sheet(item: $showingMicroFieldViewModel) { fieldViewModel in
                MicroForm(existingFieldViewModel: fieldViewModel)
                    .environmentObject(viewModel)
            }
            .onAppear {
                showingSearchLayer = true
//                isFocused = true
            }
            .introspectTextField(customize: introspectTextField)
//            .toolbar {
//                ToolbarItemGroup(placement: .bottomBar) {
//                    Spacer()
//                    Button {
//                        withAnimation {
//                            showingSearchLayer = true
//                        }
//                        isFocused = true
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                    }
//                }
//            }
        }
    }
    
    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
    func introspectTextField(_ uiTextField: UITextField) {
        guard !hasBecomeFirstResponder else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
        }
    }
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Done") {
                dismiss()
            }
        }
    }

    
    func micronutrientButton(atIndex index: Int, forGroupAtIndex groupIndex: Int) -> some View {
        let fieldViewModel = viewModel.micronutrients[groupIndex].fieldViewModels[index]
        var searchBool: Bool
        if !searchText.isEmpty {
            searchBool = fieldViewModel.fieldValue.microValue.matchesSearchString(searchText)
        } else {
            searchBool = true
        }
        return Group {
            if fieldViewModel.fieldValue.isEmpty, searchBool {
                nutrientButton(for: fieldViewModel)
            }
        }
    }
    
    func group(atIndex index: Int) -> some View {
        let groupTuple = viewModel.micronutrients[index]
        return Group {
            if viewModel.hasEmptyFieldValuesInMicronutrientsGroup(at: index, matching: searchText) {
                Section(groupTuple.group.description) {
                    ForEach(groupTuple.fieldViewModels.indices, id: \.self) {
                        micronutrientButton(atIndex: $0, forGroupAtIndex: index)
                    }
                }
            }
        }
    }
    
    var searchLayer: some View {
        var keyboardColor: Color {
            colorScheme == .light ? Color(hex: colorHexKeyboardLight) : Color(hex: colorHexKeyboardDark)
        }

        var textFieldColor: Color {
            colorScheme == .light ? Color(hex: colorHexSearchTextFieldLight) : Color(hex: colorHexSearchTextFieldDark)
        }

        
        var searchBar: some View {
            var background: some View {
                keyboardColor
                    .frame(height: 65)
            }
            
            var textField: some View {
                TextField("Search or enter website link", text: $searchText)
                    .focused($isFocused)
                    .font(.system(size: 18))
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .onSubmit {
//                        guard !searchViewModel.searchText.isEmpty else {
//                            dismiss()
//                            return
//                        }
                        resignFocusOfSearchTextField()
//                        startSearching()
                    }
            }
            
            var textFieldBackground: some View {
                RoundedRectangle(cornerRadius: 15, style: .circular)
                    .foregroundColor(textFieldColor)
                    .frame(height: 48)
            }
            
            var searchIcon: some View {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
            }
            
            var clearButton: some View {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.secondaryLabel))
                }
                .opacity(searchText.isEmpty ? 0 : 1)
            }
            
            return ZStack {
                background
                ZStack {
                    textFieldBackground
                    HStack(spacing: 5) {
                        searchIcon
                        textField
                        Spacer()
                        clearButton
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal, 7)
            }
        }
        
        return ZStack {
            VStack {
                Spacer()
                searchBar
                    .background(
                        keyboardColor
                            .edgesIgnoringSafeArea(.bottom)
                    )
            }
        }
    }
    
    func resignFocusOfSearchTextField() {
        withAnimation {
            showingSearchLayer = false
        }
        isFocused = false
    }

    var form: some View {
        Form {
            ForEach(viewModel.micronutrients.indices, id: \.self) {
                group(atIndex: $0)
            }
        }
    }
    
    func nutrientButton(for fieldViewModel: FieldViewModel) -> some View {
        Button {
            showingMicroFieldViewModel = fieldViewModel
        } label: {
            Text(fieldViewModel.fieldValue.description)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}

extension FieldValue.MicroValue {
    func matchesSearchString(_ string: String) -> Bool {
        nutrientType.description.lowercased().contains(string.lowercased())
    }
}
extension NutrientTypeGroup {
    var nutrients: [NutrientType] {
        NutrientType.allCases.filter({ $0.group == self })
    }
}

extension FoodFormViewModel {
    
    func hasNutrientsLeftToAdd(in group: NutrientTypeGroup) -> Bool {
        group.nutrients.contains { nutrientType in
            !hasAddedNutrient(nutrientType)
        }
    }
    
    func hasAddedNutrient(_ type: NutrientType) -> Bool {
        //TODO: Micronutrients
        false
//        micronutrients.contains(where: { $0.identifier.nutrientType == type })
    }
    
    func hasEmptyFieldValuesInMicronutrientsGroup(at index: Int, matching searchString: String = "") -> Bool {
        micronutrients[index].fieldViewModels.contains(where: {
            if !searchString.isEmpty {
                return $0.fieldValue.isEmpty && $0.fieldValue.microValue.matchesSearchString(searchString)
            } else {
                return $0.fieldValue.isEmpty
            }
        })
    }
    
    func hasNonEmptyFieldValuesInMicronutrientsGroup(at index: Int) -> Bool {
        micronutrients[index].fieldViewModels.contains(where: { !$0.fieldValue.isEmpty })
    }
}


struct MicronutrientPickerPreview: View {
    var body: some View {
        FoodForm.NutritionFacts.MicronutrientPicker()
    }
}

struct MicronutrientPicker_Previews: PreviewProvider {
    static var previews: some View {
        MicronutrientPickerPreview()
    }
}
