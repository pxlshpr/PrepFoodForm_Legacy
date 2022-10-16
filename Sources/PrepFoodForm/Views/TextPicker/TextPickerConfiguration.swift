import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView

class TextPickerConfiguration: ObservableObject {
    
    @Published var imageViewModels: [ImageViewModel]
    @Published var selectedImageTexts: [ImageText]
    
    @Published var showingBoxes: Bool
    @Published var focusedBoxes: [FocusedBox?]
    @Published var didSendAnimatedFocusMessage: [Bool]
    @Published var currentIndex: Int = 0
    @Published var hasAppeared: Bool = false
    @Published var page: Page
    
    @Published var shouldDismiss: Bool = false

    let initialImageIndex: Int
    let allowsMultipleSelection: Bool
    let onlyShowTextsWithValues: Bool
    let customTextFilter: ((RecognizedText) -> Bool)?
    let allowsTogglingTexts: Bool
    let didSelectImageTexts: (([ImageText]) -> Void)?
    let deleteImageHandler: ((Int) -> ())?
    
    init(imageViewModels: [ImageViewModel],
         selectedImageTexts: [ImageText] = [],
         initialImageIndex: Int? = nil,
         allowsMultipleSelection: Bool = false,
         onlyShowTextsWithValues: Bool = false,
         allowsTogglingTexts: Bool = false,
         deleteImageHandler: ((Int) -> ())? = nil,
         customTextFilter: ((RecognizedText) -> Bool)? = nil,
         didSelectImageTexts: (([ImageText]) -> Void)? = nil
    ){
        self.imageViewModels = imageViewModels
        self.selectedImageTexts = selectedImageTexts
        self.allowsMultipleSelection = allowsMultipleSelection
        self.allowsTogglingTexts = allowsTogglingTexts
        self.deleteImageHandler = deleteImageHandler
        self.onlyShowTextsWithValues = onlyShowTextsWithValues
        self.didSelectImageTexts = didSelectImageTexts
        self.customTextFilter = customTextFilter
        
        showingBoxes = !allowsTogglingTexts
        focusedBoxes = Array(repeating: nil, count: imageViewModels.count)
        didSendAnimatedFocusMessage = Array(repeating: false, count: imageViewModels.count)
        
        if let initialImageIndex {
            self.initialImageIndex = initialImageIndex
        } else if let imageText = selectedImageTexts.first {
            self.initialImageIndex = imageViewModels.firstIndex(where: { $0.id == imageText.imageId }) ?? 0
        } else {
            self.initialImageIndex = 0
        }
        
        page = .withIndex(self.initialImageIndex)
        currentIndex = self.initialImageIndex
    }
    
    func setInitialState() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.hasAppeared = true
            }
//        }
        for i in imageViewModels.indices {
            setInitialFocusBox(forImageAt: i)
        }
        removeFocusedBoxAfterDelay(forImageAt: initialImageIndex)
    }
    
    var shouldShowMenu: Bool {
        allowsTogglingTexts || deleteImageHandler != nil
    }
    
    func deleteCurrentImage() {
        guard let deleteImageHandler else {
            return
        }
        withAnimation {
            let _ = imageViewModels.remove(at: currentIndex)
            deleteImageHandler(currentIndex)
            if currentIndex != 0 {
                currentIndex -= 1
            }
        }
    }
    
    func removeFocusedBoxAfterDelay(forImageAt index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.1)) {
            self.focusedBoxes[index] = nil
        }
    }
    
    var singleSelectedImageText: ImageText? {
        guard selectedImageTexts.count == 1 else {
            return nil
        }
        return selectedImageTexts.first
    }
    
    func selectedBoundingBox(forImageAt index: Int) -> CGRect? {
        guard let singleSelectedImageText, singleSelectedImageText.imageId == currentScanResultId else {
            return nil
        }
        
        let texts = textsForCurrentImage
        
        /// Only show the union of the attribute and selected texts if the union of them both does not entirely cover any other texts we will be displaying.
        if !texts.contains(where: { singleSelectedImageText.boundingBoxWithAttribute.contains($0.boundingBox)}) {
            return singleSelectedImageText.boundingBoxWithAttribute
        } else {
            return singleSelectedImageText.boundingBox
        }
    }
    
    func pageWillChange(to index: Int) {
        withAnimation {
            currentIndex = index
        }
    }
    
    func pageDidChange(to index: Int) {
        /// Do this so that the focused box doesn't keep resetting
        removeFocusedBoxAfterDelay(forImageAt: index)
        
        /// Now reset the focus box for all the other images
        for i in imageViewModels.indices {
            guard i != index else { continue }
            setInitialFocusBox(forImageAt: i)
        }
    }
    
    func setInitialFocusBox(forImageAt index: Int) {
        /// Make sure we're not already focused on an area of this image
//        let index = initialImageIndex
        let animated = false
        
        guard let imageSize = imageSize(at: index), focusedBoxes[index] == nil else {
            return
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.0)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            if animated {
                self.didSendAnimatedFocusMessage[index] = true
            }
            
            let boundingBox: CGRect
            let paddingType: ZoomPaddingType
            if let selectedBoundingBox = self.selectedBoundingBox(forImageAt: index) {
                boundingBox = selectedBoundingBox
                paddingType = .smallElement
            } else {
                boundingBox = self.imageViewModels[index].relevantBoundingBox
                paddingType = .largeSection
            }
            
            self.focusedBoxes[index] = FocusedBox(
                boundingBox: boundingBox,
                animated: animated,
                paddingType: paddingType,
                imageSize: imageSize
            )
            
        }
    }
    
    func textBoxes(for imageViewModel: ImageViewModel) -> [TextBox] {
        let texts = texts(for: imageViewModel)
        return texts.map {
            TextBox(
                boundingBox: $0.boundingBox,
                color: color(for: $0),
                tapHandler: tapHandler(for: $0)
            )
        }
    }
    
    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        guard let didSelectImageTexts, let currentScanResultId else {
            return nil
        }
        
        let imageText = ImageText(text: text, imageId: currentScanResultId)

        if allowsMultipleSelection {
            return {
                self.toggleSelection(of: imageText)
            }
        } else {
            return {
                didSelectImageTexts([imageText])
                self.shouldDismiss = true
            }
        }
    }
    
    func toggleSelection(of imageText: ImageText) {
        if selectedImageTexts.contains(imageText) {
            Haptics.feedback(style: .light)
            withAnimation {
                selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } else {
            Haptics.transientHaptic()
            withAnimation {
                selectedImageTexts.append(imageText)
            }
        }
    }

    func didTapThumbnail(at index: Int) {
        Haptics.feedback(style: .rigid)
        page(toImageAt: index)
        
        /// wait till the page animation completes
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//
//            /// send the focus message to this page if we haven't sent the animated one yet
//            if !self.didSendAnimatedFocusMessage[index] {
//                self.setFocusBoxForImage(at: index, animated: true)
//            }
//
//            /// send a (non-animated) focus message to all *other* pages that have already received an animated focus message
//            for i in 0..<self.imageViewModels.count {
//                guard i != index,
//                      self.didSendAnimatedFocusMessage[index]
//                else {
//                    continue
//                }
//
//                self.setFocusBoxForImage(at: i, animated: false)
//            }
//        }
    }
    
    func page(toImageAt index: Int) {
        let increment = index - currentIndex
        withAnimation {
            page.update(.move(increment: increment))
            currentIndex = index
        }
        /// Call this manually as it won't be called on our end
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageDidChange(to: index)
        }
    }
    
    func texts(for imageViewModel: ImageViewModel) -> [RecognizedText] {
        if let customTextFilter {
            return imageViewModel.texts.filter(customTextFilter)
        } else {
            return onlyShowTextsWithValues ? imageViewModel.textsWithValues : imageViewModel.texts
        }
    }
    
    func color(for text: RecognizedText) -> Color {
        if selectedImageTexts.contains(where: { $0.text == text }) {
            return Color.accentColor
        } else {
            return Color.yellow
        }
    }
    
    func texts(at index: Int) -> [RecognizedText] {
        texts(for: imageViewModels[index])
    }
    
    var textsForCurrentImage: [RecognizedText] {
        return texts(for: imageViewModels[currentIndex])
        //        if onlyShowTextsWithValues {
        //            return imageViewModels[currentIndex].textsWithValues
        //        } else {
        //            return imageViewModels[currentIndex].texts
        //        }
    }
    
    var currentScanResultId: UUID? {
        imageViewModels[currentIndex].scanResult?.id
    }
    
    func imageSize(at index: Int) -> CGSize? {
        imageViewModels[index].image?.size
    }
    
    var currentImage: UIImage? {
        imageViewModels[currentIndex].image
    }
    var currentImageSize: CGSize? {
        currentImage?.size
    }
    
    var shouldShowActionBar: Bool {
        allowsTogglingTexts
        || deleteImageHandler != nil
        || imageViewModels.count > 1
    }
    
    var shouldShowSelectedTextsBar: Bool {
        allowsMultipleSelection
    }
    
    var shouldShowBottomBar: Bool {
        shouldShowActionBar || shouldShowSelectedTextsBar
    }
}

extension ImageText {
    var boundingBoxWithAttribute: CGRect {
        guard let attributeText else { return text.boundingBox }
        return attributeText.boundingBox.union(text.boundingBox)
    }
    
    var boundingBox: CGRect {
        text.boundingBox
    }
}
