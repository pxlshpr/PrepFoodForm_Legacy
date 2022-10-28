import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension FoodForm.NutrientsList {
    struct MicronutrientsPicker: View {
        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme

        @EnvironmentObject var fields: FoodForm.Fields
        let didAddNutrientTypes: ([NutrientType]) -> ()

        @State private var searchText = ""
        @State var showingSearchLayer: Bool = false
        @FocusState var isFocused: Bool
        @State var hasBecomeFirstResponder: Bool = false
        @State var pickedNutrientTypes: [NutrientType] = []
    }
}

extension FoodForm.NutrientsList.MicronutrientsPicker {
    
    var body: some View {
        NavigationView {
            ZStack {
                form
                searchLayer
            }
            .navigationTitle("Add Micronutrients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { navigationLeadingContent }
            .toolbar { navigationTrailingContent }
            .onAppear {
                showingSearchLayer = true
            }
            .interactiveDismissDisabled(isFocused)
        }
    }
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !pickedNutrientTypes.isEmpty {
                Button("Add \(pickedNutrientTypes.count)") {
                    didAddNutrientTypes(pickedNutrientTypes)
                    Haptics.successFeedback()
                    dismiss()
                }
            }
        }
    }
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(pickedNutrientTypes.isEmpty ? "Done" : "Cancel") {
                Haptics.feedback(style: .soft)
                dismiss()
            }
        }
    }

    var form: some View {
        Form {
            ForEach(fields.micronutrients.indices, id: \.self) {
                group(atIndex: $0)
            }
        }
    }
    
    func group(atIndex index: Int) -> some View {
        let groupTuple = fields.micronutrients[index]
        return Group {
            if fields.hasEmptyFieldValuesInMicronutrientsGroup(at: index, matching: searchText) {
                Section(groupTuple.group.description) {
                    ForEach(groupTuple.fieldViewModels.indices, id: \.self) {
                        micronutrientButton(atIndex: $0, forGroupAtIndex: index)
                    }
                }
            }
        }
    }
    
    func micronutrientButton(atIndex index: Int, forGroupAtIndex groupIndex: Int) -> some View {
        let fieldViewModel = fields.micronutrients[groupIndex].fieldViewModels[index]
        var searchBool: Bool
        if !searchText.isEmpty {
            searchBool = fieldViewModel.value.microValue.matchesSearchString(searchText)
        } else {
            searchBool = true
        }
        return Group {
            if fieldViewModel.value.isEmpty, searchBool, let nutrientType = fieldViewModel.nutrientType {
                nutrientButton(for: nutrientType)
            }
        }
    }
    

    func nutrientButton(for nutrientType: NutrientType) -> some View {
        Button {
//            withAnimation {
                if pickedNutrientTypes.contains(nutrientType) {
                    pickedNutrientTypes.removeAll(where: { $0 == nutrientType })
                } else {
                    pickedNutrientTypes.append(nutrientType)
                }
//            }
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .opacity(pickedNutrientTypes.contains(nutrientType) ? 1 : 0)
                    .animation(.default, value: pickedNutrientTypes)
                Text(nutrientType.description)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
    
    //MARK: - Search
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
}
