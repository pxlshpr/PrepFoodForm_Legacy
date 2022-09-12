import SwiftUI

extension FoodForm.ServingForm {
    struct SizesList: View {
        @State var listType: ListType = .standard
        @State var isPresentingAddSize: Bool = false
        @State var isPresentingDensityForm: Bool = true
    }
}

extension FoodForm.ServingForm.SizesList {

    var body: some View {
        Text("Sizes List")
//            .navigationTitle("Sizes")
            .toolbar { navigationToolbarContent }
            .toolbar { bottomToolbarContent }
            .sheet(isPresented: $isPresentingAddSize) {
                Text("Add Size sheet")
            }
    }
    
    //MARK: - Components

    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            addButton
            Spacer()
            densityButton
        }
    }
    
    var navigationToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            listTypePicker
        }
    }
    
    var listTypePicker: some View {
        Picker("", selection: $listType) {
            Text("Sizes")
                .tag(ListType.standard)
            Text("Volumes")
                .tag(ListType.customDensities)
        }
        .pickerStyle(.segmented)
    }
    
    var addButton: some View {
        Button {
            presentAddSheet()
        } label: {
            Image(systemName: "plus")
        }
    }
    
    var densityButton: some View {
        Button {
            presentDensityForm()
        } label: {
            Image(systemName: "arrow.left.arrow.right.square")
        }
    }
    
    //MARK: - Actions
    func presentAddSheet() {
        isPresentingAddSize = true
    }
    
    func presentDensityForm() {
        isPresentingDensityForm = true
    }

    //MARK: - Helpers
    enum ListType {
        case standard
        case customDensities
    }
}
