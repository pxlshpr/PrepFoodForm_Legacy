import SwiftUI

extension FoodForm {
    struct NutrientsPerForm: View {
        
        @State var servingAmount = ""
        @State var servingUnit: String = "serving"

        @State var servingSizeAmount = ""
        @State var servingSizeUnit: String = "g"

        @State var servingUnits = ["g", "cup", "serving"]
        @State var servingSizeUnits = ["g", "cup"]
        
        @StateObject var controller = Controller()
        
        @State var showingSizesList = false
        @State var showingVolumesList = false
        @State var showingAddSizeForm = false
        @State var showingAddVolumeForm = false
    }
}

extension FoodForm.NutrientsPerForm {
    class Controller: ObservableObject {
    }
}

extension FoodForm.NutrientsPerForm.Controller {
    
}

extension FoodForm.NutrientsPerForm {
    var body: some View {
        NavigationView {
            form
                .toolbar { bottomToolbarContent }
                .navigationTitle("Nutrients Per")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingSizesList) {
            SizesList()
        }
        .sheet(isPresented: $showingVolumesList) {
            SizesList()
        }
        .sheet(isPresented: $showingAddSizeForm) {
            SizeForm()
        }
        .sheet(isPresented: $showingAddVolumeForm) {
            SizesList()
        }
    }
    
    var form: some View {
        Form {
            amountSection
            if servingUnit == "serving" {
                servingSizeSection
                    .animation(.default, value: servingUnit)
//                    .transition(.opacity)
                
            }
            sizesSection
            volumesSection
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
            Image(systemName: "text.viewfinder")
        }
    }
    
    var sizesSection: some View {
        Section("Sizes") {
            Button {
                showingAddSizeForm = true
            } label: {
                Text("Add a size")
            }
//            NavigationLink {
//                FoodForm.NutrientsPerForm.SizesList()
//            } label: {
//                Text("Sizes")
//                    .foregroundColor(.accentColor)
//            }
        }
    }

    var volumesSection: some View {
        Section("Volumes") {
            Button {
                
            } label: {
                Text("Add a volume-based size")
            }
//            NavigationLink {
//                FoodForm.NutrientsPerForm.SizesList()
//            } label: {
//                Text("Volumes")
//            }
        }
    }

    var amountSection: some View {
        Section {
            HStack {
                TextField("Amount", text: $servingAmount)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                Picker("", selection: $servingUnit) {
                    ForEach(servingUnits, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
    }
    
    var servingSizeSection: some View {
        Section("Serving") {
            HStack {
                TextField("Amount", text: $servingSizeAmount)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                Picker("", selection: $servingSizeUnit) {
                    ForEach(servingSizeUnits, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
    }
}
