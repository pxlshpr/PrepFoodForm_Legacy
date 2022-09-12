import SwiftUI
import NamePicker

extension FoodForm.ServingForm {
    struct SizeForm: View {
        @State var name: String = ""
        
        @State var showingNamePicker = false
    }
}

extension FoodForm.ServingForm.SizeForm {
    
    var body: some View {
        NavigationView {
            form
                .navigationTitle("Add Size")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingNamePicker) {
            NavigationView {
                namePicker
                    .navigationTitle("Size Name")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    var form: some View {
        Form {
            nameSection
//            Section("Name") {
//                HStack {
//                    TextField("Required", text: $name)
//                    Button {
//                        showingNamePicker = true
//                    } label: {
//                        Image(systemName: "square.grid.3x3")
//                    }
//                }
//            }
        }
    }
    
    var nameSection: some View {
        Section("Name") {
//            NavigationLink {
//                namePicker
            Button {
                showingNamePicker = true
            } label: {
                if name.isEmpty {
                    Text("Required")
                        .foregroundColor(.secondary)
                } else {
                    Text(name)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    var namePicker: some View {
        NamePicker(name: $name,
                   presetStrings: ["Bottle", "Box", "Biscuit", "Cookie", "Container", "Pack", "Sleeve"]
        )
    }
}
