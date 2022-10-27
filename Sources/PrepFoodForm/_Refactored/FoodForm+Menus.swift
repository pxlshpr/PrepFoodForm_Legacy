import SwiftUI
import SwiftUISugar

extension FoodForm {
    
    
    //MARK: - Sources
    var sourcesMenu: BottomMenu {
        let addLinkGroup = BottomMenuActionGroup(action: addLinkMenuAction)
        return BottomMenu(groups: [photosMenuGroup, addLinkGroup])
    }
    
    //MARK: - Photos

    var photosMenu: BottomMenu {
        BottomMenu(groups: [photosMenuGroup])
    }
    
    var photosMenuGroup: BottomMenuActionGroup {
        BottomMenuActionGroup(actions: [
            BottomMenuAction(title: "Scan a Food Label",
                             systemImage: "text.viewfinder",
                             tapHandler: { showingFoodLabelCamera = true }),
            BottomMenuAction(title: "Take Photo\(sources.pluralS)",
                             systemImage: "camera",
                             tapHandler: { showingCamera = true }),
            BottomMenuAction(title: "Choose Photo\(sources.pluralS)",
                             systemImage: "photo.on.rectangle",
                             tapHandler: { showingPhotosPicker = true }),
        ])
    }
    
    //MARK: - Link
    var addLinkMenu: BottomMenu {
        BottomMenu(action: addLinkMenuAction)
    }

    var confirmRemoveLinkMenu: BottomMenu {
        BottomMenu(action: BottomMenuAction(
            title: "Remove Link",
            role: .destructive,
            tapHandler: {
                withAnimation {
                    sources.removeLink()
                }
            }
        ))
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
                        sources.linkInfo = LinkInfo(string)
                    }
            )
        )
    }
    
    //MARK: - Helpers
    
    func textInputIsValidHandler(_ string: String) -> Bool {
        string.isValidUrl
    }
}
