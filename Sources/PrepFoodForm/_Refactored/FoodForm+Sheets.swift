import SwiftUI
import EmojiPicker
import SwiftHaptics

extension FoodForm {
    var emojiPicker: some View {
        EmojiPicker(
            categories: [.foodAndDrink, .animalsAndNature],
            focusOnAppear: true
        ) { emoji in
            Haptics.successFeedback()
            self.emoji = emoji
            showingEmojiPicker = false
        }
    }
}
