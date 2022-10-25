import SwiftUI
import SwiftHaptics
import PrepDataTypes
import PhotosUI
import Camera
import EmojiPicker
import SwiftUISugar
import FoodLabelCamera
import RSBarcodes_Swift

extension FoodForm {

    var addBarcodeActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Scan a Barcode", systemImage: "barcode.viewfinder", tapHandler: {
                    viewModel.showingBarcodeScanner = true
                }),
                enterBarcodeManuallyLink
//                BottomMenuAction(title: "Choose Photo", systemImage: "photo.on.rectangle", tapHandler: {
//
//                }),
            ]
//            ,
//            [enterBarcodeManuallyLink]
        ]
    }
    
    var enterBarcodeManuallyLink: BottomMenuAction {
       BottomMenuAction(
           title: "Enter Manually",
           systemImage: "123.rectangle",
           textInput: BottomMenuTextInput(
               placeholder: "012345678912",
               keyboardType: .decimalPad,
               submitString: "Add Barcode",
               autocapitalization: .never,
               textInputIsValid: isValidBarcode,
               textInputHandler: {
                   let barcodeValue = FieldValue.BarcodeValue(
                       payloadString: $0,
                       symbology: .ean13,
                       fill: .userInput)
                   let fieldViewModel = FieldViewModel(fieldValue: .barcode(barcodeValue))
                   let _ = viewModel.add(barcodeViewModel: fieldViewModel)
                   Haptics.successFeedback()
               }
           )
       )
    }
    
    var photosActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(title: "Scan a Food Label", systemImage: "text.viewfinder", tapHandler: {
                viewModel.showingFoodLabelCamera = true
            }),
            BottomMenuAction(title: "Take Photo\(viewModel.availableImagesCount == 1 ? "" : "s")", systemImage: "camera", tapHandler: {
                viewModel.showingCamera = true
            }),
            BottomMenuAction(title: "Choose Photo\(viewModel.availableImagesCount == 1 ? "" : "s")", systemImage: SourceType.images.systemImage, tapHandler: {
                showingPhotosPicker = true
            }),
        ]]
    }

    var autofillActionGroups: [[BottomMenuAction]] {
        //TODO: If we have two columns, ask the user which column they want to choose first—then drill down to the confirmation saying they will lose any data in fields that are being autofilled.
        [[
            BottomMenuAction(title: #""Per Serving" Column"#, systemImage: "circle.grid.2x1.left.filled", tapHandler: {
                viewModel.showingFoodLabelCamera = true
            }),
            BottomMenuAction(title: #""Per 100 g" Column"#, systemImage: "circle.grid.2x1.right.filled", tapHandler: {
                viewModel.showingCamera = true
            }),
        ]]
    }

    var addLinkActionGroups: [[BottomMenuAction]] {
        [[addLinkMenuAction]]
    }

    var removeAllImagesActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "Remove All Photos",
                role: .destructive,
                tapHandler: {
                    withAnimation {
                        viewModel.removeAllImages()
                    }
                }
            )
        ]]
    }

    var removeLinkActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "Remove Link",
                role: .destructive,
                tapHandler: {
                    withAnimation {
                        viewModel.removeSourceLink()
                    }
                }
            )
        ]]
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
                        viewModel.submittedSourceLink(string)
                    }
            )
        )
    }

    var sourceMenuActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Scan a Food Label", systemImage: "text.viewfinder", tapHandler: {
                    viewModel.showingFoodLabelCamera = true
                }),
                BottomMenuAction(title: "Take Photos", systemImage: "camera", tapHandler: {
                    viewModel.showingCamera = true
                }),
                BottomMenuAction(title: "Choose Photos", systemImage: "photo.on.rectangle", tapHandler: {
                    showingPhotosPicker = true
                }),
            ],
            [addLinkMenuAction]
        ]
    }

}
