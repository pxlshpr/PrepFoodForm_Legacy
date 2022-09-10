import SwiftUI

extension FoodForm {
    
    class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var emoji = ""
        @Published var detail = ""
        @Published var brand = ""
        @Published var barcode = ""

    }
    
}
