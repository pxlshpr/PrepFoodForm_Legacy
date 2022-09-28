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
    func labelImage(_ number: Int) -> UIImage? {
        guard let path = Bundle.module.path(forResource: "label\(number)", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    var labelImage: UIImage? {
        labelImage(1)
    }
    
    var sampleImagesArray: [UIImage] {
        [labelImage, labelImage, labelImage].compactMap { $0 }
    }
    
    func setSampleImages() {
//        for i in 1...5 {
//            let path = Bundle.module.path(forResource: "label\(i)", ofType: "jpg")!
//            let image = UIImage(contentsOfFile: path)!
//            let sourceImageViewModel = ImageViewModel(image: image)
//            imageViewModels.append(sourceImageViewModel)
//        }
    }
    
    func simulateScan() {
    }
}
