import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct SizeForm: View {
        @State var name: String = ""
        
        @State var showingNamePicker = false
    }
}

extension FoodForm.NutrientsPerForm.SizeForm {
    
    var body: some View {
        NavigationView {
            form
                .navigationTitle("Add Size")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingNamePicker) {
            Text("Name Picker")
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
            NavigationLink {
                Text("Name Picker here")
//                DiaryView.AddMeal.Name(name: $name)
//                    .environmentObject(diaryController)
            } label: {
                if name.isEmpty {
                    Text("Required")
                        .foregroundColor(.secondary)
                } else {
                    Text(name)
                }
            }
        }
    }
}
