import SwiftUI

struct MFPInfoSheet: View {
    
    var body: some View {
        NavigationView {
            form
                .navigationTitle("Third Party Foods")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var form: some View {
        Form {
            Section {
                Text("""
Search multiple **public websites** such as [MyFitnessPal](https://www.myfitnesspal.com), [CalorieKing](https://www.calorieking.com) and [Nutritionix](https://www.nutritionix.com).

Import their data to create your new food with.
""")
            }
            Section("Disclaimer") {
                Text("""
We can not guarantee the *accuracy* of the information or the *speed* at which it is retrieved.

These foods will most likely be ineligible for the public database unless you provide images of the food label or a link to the food's nutritional info.
""")
            }
        }
    }
}
