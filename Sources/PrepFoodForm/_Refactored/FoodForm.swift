import SwiftUI
import SwiftUISugar
import Combine

public struct FoodForm: View {
    
    @Environment(\.dismiss) var dismiss
    
    let didSave: (FoodFormData) -> ()
    
    @State var emoji: String = ""
    @State var name: String = ""
    @State var detail: String = ""
    @State var brand: String = ""
    
    @State var showingEmojiPicker = false
    
    public init(didSave: @escaping (FoodFormData) -> ()) {
        self.didSave = didSave
        _emoji = State(initialValue: randomFoodEmoji())
    }
    
    public var body: some View {
        let _ = Self._printChanges()
        return NavigationView {
            content
                .navigationTitle("New Food")
                .toolbar { navigationLeadingContent }
        }
    }
    
    //MARK: Main Content
    
    var content: some View {
        form
            .sheet(isPresented: $showingEmojiPicker) { emojiPicker }
    }
    
    @ViewBuilder
    var form: some View {
        FormStyledScrollView {
            detailsSection
        }
    }
    
    //MARK: Toolbars
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
    }
}
