import SwiftUI
import ISEmojiView
import SwiftHaptics

extension FoodForm.DetailsForm {
    struct EmojiPicker: View {
        @Environment(\.dismiss) var dismiss
        @Binding var emoji: String
    }
}


extension FoodForm.DetailsForm.EmojiPicker {
    
    var body: some View {
//        NavigationView {
            content
                .navigationTitle("Pick an Emoji")
                .navigationBarTitleDisplayMode(.inline)
//        }
    }
    
    var content: some View {
        EmojiView_SwiftUI(didSelect: { emoji in
            self.emoji = emoji
            Haptics.feedback(style: .rigid)
            dismiss()
        })
    }
}
