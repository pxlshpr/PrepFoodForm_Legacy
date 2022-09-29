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
        PrepFoodForm.sampleImage(1)
    }
    
    var sampleImagesArray: [UIImage] {
        [labelImage, labelImage, labelImage].compactMap { $0 }
    }
    
    func setSampleImages() {
//        for i in 1...5 {
//            let image = PrepFoodForm.sampleImage(i)!
//            let sourceImageViewModel = ImageViewModel(image: image)
//            imageViewModels.append(sourceImageViewModel)
//        }
    }
    
    func simulateScan() {
    }
}
