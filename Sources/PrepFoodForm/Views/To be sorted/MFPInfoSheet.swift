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
Search over 11 million foods in the [MyFitnessPal](https://www.myfitnesspal.com) database. Pre-fill this form with its data to speed up the creation process.
""")
                Text("""
This food will still be ineligible for submission to the public database until you provide a verifiable source (such as a photo of the food label).
""")
                .foregroundColor(.secondary)
            }
            Section {
                Text("""
As we rely on their servers for this information—its accuracy and the speed at which it is retrieved cannot be guaranteed. The availability of this feature might also be intermittently unavilabile.
""")
                Text("""
A better option would be to search for the food using their app or website, and use screenshots to import their data instead.
""")
                .bold()
                Text("""
Keep in mind that these photos would not be considered verifable sources—[as they do not guarantee the information to be accurate](https://support.myfitnesspal.com/hc/en-us/articles/360032273292-What-does-the-check-mark-mean-).
""")
                .foregroundColor(.secondary)
            }
            Section("Disclaimer") {
                Text("""
We are in no way affiliated with MyFitnessPal, and do not claim ownership over any of the data they provide.
""")
                .italic()
                .bold()
                Text("""
We are using their publically facing website's search functionality as an alternative to using screenshots or entering the data yourself.
""")
                .foregroundColor(.secondary)
            }
        }
    }
}
