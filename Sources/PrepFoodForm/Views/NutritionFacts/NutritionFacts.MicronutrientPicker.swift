import SwiftUI
import PrepUnits
import SwiftHaptics
import Introspect

extension FoodForm.NutritionFacts {
    public struct MicronutrientPicker: View {
        @EnvironmentObject var viewModel: FoodFormViewModel
        @Environment(\.dismiss) var dismiss
        @Environment(\.colorScheme) var colorScheme
        @State var showingMicroFieldValueViewModel: FieldValueViewModel?
        @State private var searchText = ""
        @State var showingSearchLayer: Bool = false
        @FocusState var isFocused: Bool
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
            .sheet(item: $showingMicroFieldValueViewModel) { fieldValueViewModel in
                MicronutrientForm(fieldValueViewModel: fieldValueViewModel)
                    .environmentObject(viewModel)
            }
            .onAppear {
                showingSearchLayer = true
                isFocused = true
            }
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
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Done") {
                dismiss()
            }
        }
    }

    
    func micronutrientButton(atIndex index: Int, forGroupAtIndex groupIndex: Int) -> some View {
        let fieldValueViewModel = viewModel.micronutrients[groupIndex].fieldValueViewModels[index]
        var searchBool: Bool
        if !searchText.isEmpty {
            searchBool = fieldValueViewModel.fieldValue.microValue.matchesSearchString(searchText)
        } else {
            searchBool = true
        }
        return Group {
            if fieldValueViewModel.fieldValue.isEmpty, searchBool {
                nutrientButton(for: fieldValueViewModel)
            }
        }
    }
    
    func group(atIndex index: Int) -> some View {
        let groupTuple = viewModel.micronutrients[index]
        return Group {
            if viewModel.hasEmptyFieldValuesInMicronutrientsGroup(at: index, matching: searchText) {
                Section(groupTuple.group.description) {
                    ForEach(groupTuple.fieldValueViewModels.indices, id: \.self) {
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
    
    func nutrientButton(for fieldValueViewModel: FieldValueViewModel) -> some View {
        Button {
            showingMicroFieldValueViewModel = fieldValueViewModel
        } label: {
            Text(fieldValueViewModel.fieldValue.description)
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
        micronutrients[index].fieldValueViewModels.contains(where: {
            if !searchString.isEmpty {
                return $0.fieldValue.isEmpty && $0.fieldValue.microValue.matchesSearchString(searchString)
            } else {
                return $0.fieldValue.isEmpty
            }
        })
    }
    
    func hasNonEmptyFieldValuesInMicronutrientsGroup(at index: Int) -> Bool {
        micronutrients[index].fieldValueViewModels.contains(where: { !$0.fieldValue.isEmpty })
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
