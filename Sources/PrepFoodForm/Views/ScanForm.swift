import SwiftUI
import SwiftHaptics

struct ScanForm: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FoodFormViewModel
    
    var body: some View {
        NavigationView {
            Button("Simulate Scan") {
                simulateScan()
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func simulateScan() {
//        viewModel.setSampleImages()
//        viewModel.simulateScan()
        withAnimation {
            dismiss()
        }
    }
}

extension FoodFormViewModel {
    var labelImage: UIImage? {
        nil
//        guard let path = Bundle.module.path(forResource: "label1", ofType: "jpg") else {
//            return nil
//        }
//        return UIImage(contentsOfFile: path)
    }
    
    var sampleImagesArray: [UIImage] {
        [labelImage, labelImage, labelImage].compactMap { $0 }
    }
    
    func setSampleImages() {
//        for i in 1...5 {
//            let path = Bundle.module.path(forResource: "label\(i)", ofType: "jpg")!
//            let image = UIImage(contentsOfFile: path)!
//            let sourceImageViewModel = SourceImageViewModel(image: image)
//            sourceImageViewModels.append(sourceImageViewModel)
//        }
    }
    
    func simulateScan() {
        
        /// Cancel the previous scan task
        scanTask?.cancel()
        
        /// Now reassign it
        scanTask = Task {
            
            await MainActor.run {
                isScanning = true
            }
            
            try await Task.sleep(
                until: .now + .seconds(5),
                tolerance: .seconds(5),
                clock: .suspending
            )
            
            try Task.checkCancellation()
            
            self.sourceImageViewModels[0].process {
                
                Haptics.transientHaptic()
                
                self.sourceImageViewModels[1].process {

                    Haptics.transientHaptic()
                    
                    self.sourceImageViewModels[2].process {
                        
                        Haptics.transientHaptic()
                        
                        self.sourceImageViewModels[3].process {
                            
                            Haptics.transientHaptic()
                            
                            self.sourceImageViewModels[4].process {
                                
                                Haptics.feedback(style: .rigid)
                                
                                Task {
                                    await MainActor.run {
                                        self.isScanning = false
                                        self.numberOfScannedImages = 5
                                        self.numberOfScannedDataPoints = 17
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Task {
            guard let scanTask = scanTask else { return }
            let _ = try await scanTask.value
        }
    }
}
