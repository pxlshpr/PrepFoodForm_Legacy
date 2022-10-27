import SwiftUI
import SwiftUISugar

extension FoodForm {
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                Details(name: $name, detail: $detail, brand: $brand)
            } label: {
                FoodDetailsView(emoji: $emoji, name: $name, detail: $detail, brand: $brand, didTapEmoji: {
                    showingEmojiPicker = true
                })
            }
        }
    }
    
    var sourcesSection: some View {
        SourcesView(sourcesViewModel: sourcesViewModel,
                    didTapAddSource: tappedAddSource,
                    handleSourcesAction: handleSourcesAction)
    }    
}
