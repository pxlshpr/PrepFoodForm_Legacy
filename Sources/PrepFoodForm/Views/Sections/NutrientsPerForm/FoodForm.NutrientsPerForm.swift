import SwiftUI

extension FoodForm {
    struct NutrientsPerForm: View {
        
        @State var servingAmount = ""
        @State var servingUnit: String = "serving"

        @State var servingSizeAmount = ""
        @State var servingSizeUnit: String = "g"

        @State var servingUnits = ["g", "cup", "serving"]
        @State var servingSizeUnits = ["g", "cup"]
    }
}

extension FoodForm.NutrientsPerForm {
    var body: some View {
        NavigationView {
            form
                .toolbar { bottomToolbarContent }
                .navigationTitle("Nutrients Per")
                .navigationBarTitleDisplayMode(.inline)
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
            sizesLink
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
    
    var sizesLink: some View {
        Section {
            NavigationLink {
                FoodForm.NutrientsPerForm.SizesList()
            } label: {
                Text("Sizes and Volumes")
            }
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
