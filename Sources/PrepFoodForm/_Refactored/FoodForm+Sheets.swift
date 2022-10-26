import SwiftUI
import EmojiPicker
import SwiftHaptics
import FoodLabelCamera

extension FoodForm {
    var emojiPicker: some View {
        EmojiPicker(
            categories: [.foodAndDrink, .animalsAndNature],
            focusOnAppear: true,
            includeCancelButton: true
        ) { emoji in
            Haptics.successFeedback()
            self.emoji = emoji
            showingEmojiPicker = false
        }
    }
    
    var foodLabelCamera: some View {
        FoodLabelCamera(foodLabelScanHandler: sourcesViewModel.receivedScanResult)
    }    
}
