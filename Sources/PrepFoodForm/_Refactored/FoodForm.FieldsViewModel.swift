import SwiftUI

extension FoodForm {
    class FieldsViewModel: ObservableObject {
        @Published var energyViewModel: FieldViewModel
        
        init() {
            self.energyViewModel = .init(fieldValue: .energy())
        }
    }
}
