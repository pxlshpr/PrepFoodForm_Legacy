import SwiftUI

struct MFPInfoSheet: View {
    
    var body: some View {
        NavigationStack {
            form
                .navigationTitle("MyFitnessPal Foods")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var form: some View {
        Form {
            Section {
                Text("We are *not* affiliated with MyFtinessPal and do *not* claim to own any of the data they make **publically available**.")
            }
            Section {
                Text("We simply provide an interface for searching their **publically viewable** foods using their website.")
            }
            Section {
                Text("Thus we can not guarantee the *accuracy* of the information or the *speed* at which it is retrieved.")
            }
            Section {
                Text("These foods will most likely be ineligible for the public database unless you provide images of the food label or a link to the food's nutritional info (outside of MyFitnessPal).")
            }
        }
    }
}
