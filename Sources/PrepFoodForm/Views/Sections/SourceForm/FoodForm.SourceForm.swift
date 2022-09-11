import SwiftUI

extension FoodForm {
    struct SourceForm: View {
    }
}

extension FoodForm.SourceForm {
    var body: some View {
//        NavigationView {
            list
                .navigationTitle("Source")
                .navigationBarTitleDisplayMode(.inline)
//        }
    }
    
    var list: some View {
        List {
            Text("Source info goes here")
        }
        .listStyle(.insetGrouped)
    }
}
