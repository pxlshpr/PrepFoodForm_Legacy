import SwiftUI
import SwiftHaptics

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
        viewModel.setSampleImages()
        viewModel.simulateScan()
        dismiss()
    }
}

extension FoodFormViewModel {
    var labelImage: UIImage? {
        guard let path = Bundle.module.path(forResource: "label1", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    var sampleImagesArray: [UIImage] {
        [labelImage, labelImage, labelImage].compactMap { $0 }
    }
    
    func setSampleImages() {
        for i in 1...5 {
            let path = Bundle.module.path(forResource: "label\(i)", ofType: "jpg")!
            let image = UIImage(contentsOfFile: path)!
            let sourceImageViewModel = SourceImageViewModel(image: image)
            sourceImageViewModels.append(sourceImageViewModel)
        }
    }
    
    func simulateScan() {
        
        isScanning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
