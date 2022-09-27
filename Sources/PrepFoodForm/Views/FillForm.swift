import SwiftUI

struct FillForm: View {
    
    var body: some View {
        NavigationView {
            form
            .navigationTitle("Fill in a value")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(400), .large])
        .presentationDragIndicator(.hidden)
    }
    
    var form: some View {
        Form {
            Section {
                Text("This value was typed out by you")
                    .foregroundColor(.secondary)
            }
            thirdPartyFoodSection
            imageSection
        }
    }
    
    var thirdPartyFoodSection: some View {
        var header: some View {
            Button {
                
            } label: {
                Text("From Third-party food")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
        
        return Section(header: header) {
            Button {
                
            } label: {
                HStack {
                    HStack {
                        Image(systemName: "link")
                        Text("Extracted value")
                    }
                    .foregroundColor(Color(.label))
                    Spacer()
                    Text("132 kcal")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var imageSection: some View {
        var header: some View {
            Button {
                
            } label: {
                Text("From a Scanned Image")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
        
        return Section(header: header) {
            Button {
                
            } label: {
                HStack {
                    HStack {
                        Image(systemName: "text.viewfinder")
                        Text("Detected value")
                    }
                    .foregroundColor(Color(.label))
                    Spacer()
                    Text("130 kcal")
                        .foregroundColor(.secondary)
                }
            }
            Button {
                
            } label: {
                HStack {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Select a value")
                    }
                    .foregroundColor(.primary)
                    Spacer()
//                    Text("130 kcal")
//                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct FillFormPreview: View {
    var body: some View {
        NavigationView {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    FillForm()
//                        .presentationDetents([.medium])
                }
        }
    }
}

struct FillForm_Previews: PreviewProvider {
    static var previews: some View {
        FillFormPreview()
    }
}
