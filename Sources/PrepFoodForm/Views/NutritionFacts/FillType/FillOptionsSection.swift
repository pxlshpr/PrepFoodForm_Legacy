import SwiftUI

struct FillOptions: View {
    
    @Binding var showingImage: Bool
    @Binding var showingOptions: Bool

    var body: some View {
        Group {
            if showingOptions {
                FillOptionsGrid()
                    .transition(.opacity )
                if showingImage {
                    Text("Hello")
                }
            }
        }
    }
}

public struct FillOptionsPreview: View {
    
    @State var showingImage = false
    
    @State var showingNameOptions = false
    @FocusState var nameIsFocused: Bool

    @State var showingDetailOptions = false
    @FocusState var detailIsFocused: Bool

    @State var showingBrandOptions = false
    @FocusState var brandIsFocused: Bool

    public init() { }
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("Required", text: .constant(""))
                        .focused($nameIsFocused)
                    FillOptions(showingImage: $showingImage, showingOptions: $showingNameOptions)
                }
                Section("Detail") {
                    TextField("Optional", text: .constant(""))
                        .focused($detailIsFocused)
                    FillOptions(showingImage: $showingImage, showingOptions: $showingDetailOptions)
                }
                Section("Brand") {
                    TextField("Optional", text: .constant(""))
                        .focused($brandIsFocused)
                    FillOptions(showingImage: $showingImage, showingOptions: $showingBrandOptions)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Image") {
                        withAnimation {
                            showingImage.toggle()
                        }
                    }
//                    Button("Options") {
//                        withAnimation {
//                            showingOptions.toggle()
//                        }
//                    }
                }
            }
            .onChange(of: nameIsFocused) { newValue in
                withAnimation {
                    showingNameOptions = newValue
                }
            }
            .onChange(of: detailIsFocused) { newValue in
                withAnimation {
                    showingDetailOptions = newValue
                }
            }
            .onChange(of: brandIsFocused) { newValue in
                withAnimation {
                    showingBrandOptions = newValue
                }
            }
        }
    }
}

struct FillOptions_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionsPreview()
    }
}
