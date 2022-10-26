import SwiftUI
import SwiftUISugar

extension FoodForm {
    var sourcesMenuContents: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Scan a Food Label", systemImage: "text.viewfinder", tapHandler: {
                    showingFoodLabelCamera = true
                }),
                BottomMenuAction(title: "Take Photos", systemImage: "camera", tapHandler: {
                    showingCamera = true
                }),
                BottomMenuAction(title: "Choose Photos", systemImage: "photo.on.rectangle", tapHandler: {
                    showingPhotosPicker = true
                }),
            ],
            [addLinkMenuAction]
        ]
    }
    
    var addLinkMenuAction: BottomMenuAction {
        BottomMenuAction(
            title: "Add a Link",
            systemImage: "link",
            textInput: BottomMenuTextInput(
                placeholder: "https://fastfood.com/nutrition-facts.pdf",
                keyboardType: .URL,
                submitString: "Add Link",
                autocapitalization: .never,
                textInputIsValid: textInputIsValidHandler,
                textInputHandler:
                    { string in
                        sourcesViewModel.linkInfo = LinkInfo(string)
                    }
            )
        )
    }
    
    func textInputIsValidHandler(_ string: String) -> Bool {
        string.isValidUrl
    }
}
