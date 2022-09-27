import SwiftUI

struct FillForm: View {
    
    var body: some View {
        NavigationView {
            form
            .navigationTitle("Pre-filled")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(300), .medium])
        .presentationDragIndicator(.hidden)
    }
    
    var form: some View {
        Form {
            Section {
                Text("This value was pre-filled from the following third-party food.")
            }
            Section {
                Button {
                    
                } label: {
                    HStack {
                        HStack {
                            Image(systemName: "link")
                            Text("Website")
                        }
                        .foregroundColor(.secondary)
                        Spacer()
                        Text("MyFitnessPal")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}
