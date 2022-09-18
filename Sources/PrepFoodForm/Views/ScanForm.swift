import SwiftUI

struct ScanForm: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    var body: some View {
        NavigationStack {
            Button("Simulate Scan") {
                simulateScan()
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func simulateScan() {
        viewModel.simulateScan()
        dismiss()
    }
}

extension FoodFormViewModel {
    func simulateScan() {
        isScanning = true
        scanningImages = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.numberOfScannedImages = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.numberOfScannedImages = 2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.numberOfScannedImages = 3
            }
        }
    }
}
