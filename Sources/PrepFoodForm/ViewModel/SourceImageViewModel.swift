import SwiftUI

class SourceImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var status: SourceImageStatus
    
    init(image: UIImage? = nil) {
        self.image = image
        if image == nil {
            self.status = .loading
        } else {
            self.status = .notProcessed
        }
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
