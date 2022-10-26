import Foundation

extension String {
    var isUppercase: Bool {
        !contains(where: { !$0.isUppercase })
    }
    
    var capitalizedIfUppercase: String {
        isUppercase ? capitalized : self
    }
}
