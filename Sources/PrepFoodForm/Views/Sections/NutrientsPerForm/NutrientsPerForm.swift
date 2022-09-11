import SwiftUI

extension FoodForm {
    struct NutrientsPerForm: View {
        
        @State var servingAmount = ""
        @State var servingUnit: String = "g"
        @State var pickerServingUnit: String = "g"

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
        form
        .toolbar { bottomToolbarContent }
        .navigationTitle("Serving")
        .navigationBarTitleDisplayMode(.inline)
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
            }
            sizesSection
            densitiesSection
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
    

    var densitiesSection: some View {
        var header: some View {
            Text("Density")
        }
        
        @ViewBuilder
        var footer: some View {
            if servingUnit == "g" || servingSizeUnit == "g" {
                Text("Specifying a density will also let you log this food using volume-measurements – such as cups, tablespoons, etc.")
            } else if servingUnit == "cup" || servingSizeUnit == "cup" {
                Text("Specifying a density will also let you log this food using weight-measurements – such as grams, ounces, etc.")
            }
        }
        
        return Section(header: header, footer: footer) {
            NavigationLink {
                DensitiesForm()
            } label: {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }
    var sizesSection: some View {
        var header: some View {
            Text("Sizes")
        }
        
        var footer: some View {
            Text("Sizes let you give names to preset measurements of this food – like biscuit, bottle, pack, etc.")
        }
        
        return Section(header: header, footer: footer) {
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
    
    var amountSection: some View {
        var header: some View {
            Text("Amount")
        }
        
        var footer: some View {
            Text("This is how much of this food you'll be specifying the nutritional values for.")
        }
        return Section(header: header, footer: footer) {
            HStack {
                TextField("Required", text: $servingAmount)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.decimalPad)
                Picker("", selection: $pickerServingUnit) {
                    ForEach(servingUnits, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: pickerServingUnit) { newValue in
                    withAnimation {
                        servingUnit = pickerServingUnit
                    }
                }
            }
        }
    }
    
    var servingSizeSection: some View {
        Section("Serving Size") {
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
