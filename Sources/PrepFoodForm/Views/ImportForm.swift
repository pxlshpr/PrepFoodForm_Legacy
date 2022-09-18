import SwiftUI

struct ImportForm: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel

    var body: some View {
        NavigationStack {
            Button("Simulate Import") {
                simulateImport()
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func simulateImport() {
        viewModel.isImporting = true
        dismiss()
    }
}
