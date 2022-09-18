import SwiftUI

class SourceImageViewModel: ObservableObject {
    
    let image: UIImage
    @Published var status: SourceImageStatus = .notProcessed
    
    init(image: UIImage) {
        self.image = image
    }
    
    func process(completion: (() -> ())? = nil) {
        Task {
            
            await MainActor.run {
                status = .processing
            }
            
            try await Task.sleep(
                until: .now + .seconds(2),
                tolerance: .seconds(2),
                clock: .suspending
            )

            await MainActor.run {
                self.status = .processed
            }
            completion?()
        }
    }
}

extension SourceImageViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(status)
    }
}

extension SourceImageViewModel: Equatable {
    static func ==(lhs: SourceImageViewModel, rhs: SourceImageViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
