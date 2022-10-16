import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
//import ZoomableScrollView
import ActivityIndicatorView

extension ImageText {
    var boundingBoxWithAttribute: CGRect {
        guard let attributeText else { return text.boundingBox }
        return attributeText.boundingBox.union(text.boundingBox)
    }
    
    var boundingBox: CGRect {
        text.boundingBox
    }
}

class TextPickerConfiguration: ObservableObject {
    
    @Published var imageViewModels: [ImageViewModel]
    @Published var selectedImageTexts: [ImageText]
    
    @Published var showingBoxes: Bool
    @Published var focusedBoxes: [FocusedBox?]
    @Published var didSendAnimatedFocusMessage: [Bool]
    @Published var currentIndex: Int = 0
    @Published var hasAppeared: Bool = false
    @Published var page: Page
    
    @Published var isPaging: Bool = false
    
    let initialImageIndex: Int
    let allowsMultipleSelection: Bool
    let onlyShowTextsWithValues: Bool
    let didSelectImageTexts: (([ImageText]) -> Void)?
    let customTextFilter: ((RecognizedText) -> Bool)?
    let allowsTogglingTexts: Bool = false
    
    init(imageViewModels: [ImageViewModel],
         selectedImageTexts: [ImageText] = [],
         initialImageIndex: Int? = nil,
         allowsMultipleSelection: Bool = false,
         onlyShowTextsWithValues: Bool = false,
         didSelectImageTexts: (([ImageText]) -> Void)? = nil,
         customTextFilter: ((RecognizedText) -> Bool)? = nil)
    {
        self.imageViewModels = imageViewModels
        self.selectedImageTexts = selectedImageTexts
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onlyShowTextsWithValues = onlyShowTextsWithValues
        self.didSelectImageTexts = didSelectImageTexts
        self.customTextFilter = customTextFilter
        
        showingBoxes = didSelectImageTexts == nil ? false : true
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
    }
    
    func setInitialState() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.hasAppeared = true
            }
//        }
        setInitialFocusBox()
    }
    
    var singleSelectedImageText: ImageText? {
        guard selectedImageTexts.count == 1 else {
            return nil
        }
        return selectedImageTexts.first
    }
    
    var selectedBoundingBox: CGRect? {
        guard let singleSelectedImageText else {
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
    
    func setInitialFocusBox() {
        /// Make sure we're not already focused on an area of this image
        let index = initialImageIndex
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
            let padded: Bool
            if let selectedBoundingBox = self.selectedBoundingBox {
                boundingBox = selectedBoundingBox
                padded = true
            } else {
                boundingBox = self.texts(at: index).boundingBox
                padded = false
            }
            
            self.focusedBoxes[index] = FocusedBox(
                boundingBox: boundingBox,
                animated: animated,
                padded: padded,
                imageSize: imageSize
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? 0.5 : 0.1)) {
                self.focusedBoxes[index] = nil
            }
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
    
    func didTapThumbnail(at index: Int) {
        Haptics.feedback(style: .rigid)
        pageToImage(at: index)
        
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
    
    func pageToImage(at index: Int) {
//        withAnimation {
//            isPaging = true
//        }
        
        let increment = index - currentIndex
        withAnimation {
            page.update(.move(increment: increment))
        }
        currentIndex = index
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            withAnimation {
//                self.isPaging = false
//            }
//        }
        
        /// Reset the focusedAreas of the other images (after waiting for half a second for the paging animation to complete)
    }
    
    func tapHandler(for text: RecognizedText) -> (() -> ())? {
        nil
//        if text == selectedText {
//            return {
//
//            }
//        } else {
//            return nil
//        }
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
            return Color.green
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
}

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var config: TextPickerConfiguration
    
    init(config: TextPickerConfiguration) {
        _config = StateObject(wrappedValue: config)
    }
    
    //MARK: - Views
    
    var body: some View {
        //        NavigationView {
        ZStack {
            pagerLayer
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            buttonsLayer
                .zIndex(5)
         }
        //                .navigationTitle(title)
        //                .navigationBarTitleDisplayMode(.inline)
        //                .toolbar { bottomToolbar }
        //                .toolbar(.visible, for: .bottomBar)
        //                .toolbarBackground(.visible, for: .bottomBar)
        //                .toolbar { navigationLeadingContents }
        //                .toolbar { navigationTrailingContents }
        //        }
        .onAppear(perform: appeared)
    }
    
    //MARK:  Pager Layer
    
    var pagerLayer: some View {
        Pager(
            page: config.page,
            data: config.imageViewModels,
            id: \.hashValue,
            content: { imageViewModel in
            zoomableScrollView(for: imageViewModel)
                    .background(.black)
        })
        .sensitivity(.high)
        .pagingPriority(.high)
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = config.imageViewModels.firstIndex(of: imageViewModel),
           index < config.focusedBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(focusedBox: $config.focusedBoxes[index]) {
                ZStack {
                    imageView(image)
                        .overlay(textBoxesLayer(for: imageViewModel))
//                    textBoxesLayer(for: imageViewModel)
                }
            }
        }
    }
    
    @ViewBuilder
    func textBoxesLayer(for imageViewModel: ImageViewModel) -> some View {
//        if config.hasAppeared {
            TextBoxesLayer(textBoxes: config.textBoxes(for: imageViewModel))
                .opacity(config.hasAppeared ? 1 : 0)
                .animation(.default, value: config.hasAppeared)
//        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.black)
            .opacity(0.7)
    }
    
    //MARK: ButtonsLayer
    
    var buttonsLayer: some View {
        VStack {
            ZStack {
                HStack {
                    dismissButton
                    Spacer()
                }
                HStack {
                    Spacer()
                    titleView
                    Spacer()
                }
            }
            Spacer()
            ZStack {
                Color.clear
                HStack {
                    HStack(spacing: 5) {
                        ForEach(config.imageViewModels.indices, id: \.self) { index in
                            thumbnail(at: index)
                        }
                    }
                    .padding(.leading, 40)
                    .padding(.top, 15)
                    Spacer()
                    menuButton
                        .padding(.top, 15)
                }
            }
            .frame(height: 70)
            .background(.ultraThinMaterial)
        }
    }

    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .padding(15)
                .foregroundColor(.primary)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                )
                .clipShape(Circle())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
    }
    
    var titleView: some View {
        Text("Select a text")
            .font(.title3)
            .bold()
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
    }
    
    var menuButton: some View {
        Menu {
            Button {
                
            } label: {
                Label("Show Texts", systemImage: "text.viewfinder")
            }
            Divider()
            Button(role: .destructive) {
                
            } label: {
                Label("Remove Photo", systemImage: "trash")
            }
            Button(role: .destructive) {
                
            } label: {
                Label("Remove All Photos", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.primary)
                .imageScale(.large)
                .padding(40)
                .frame(height: 55)
            //                .background(.green)
                .contentShape(Rectangle())
        }
    }
    
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            config.currentIndex == index
        }
        
        return Group {
            if let image = config.imageViewModels[index].smallThumbnail {
                Button {
                    config.didTapThumbnail(at: index)
                } label: {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.accentColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                        .foregroundColor(.primary)
                                        .padding(-0.5)
                                )
                                .opacity(isSelected ? 1.0 : 0.0)
                        )
                }
            }
        }
    }
    
    //MARK: - Actions
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            config.setInitialState()
        }
    }
    
    //MARK: - User Actions
    func toggleSelection(of imageText: ImageText) {
        if config.selectedImageTexts.contains(imageText) {
            Haptics.feedback(style: .light)
            withAnimation {
                config.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } else {
            Haptics.transientHaptic()
            withAnimation {
                config.selectedImageTexts.append(imageText)
            }
        }
    }
    
    //MARK: - Events
    func pageWillChange(to pageIndex: Int) {
        print("pageWillChange to \(pageIndex)")
        //        withAnimation {
        //            selectedViewModelIndex = pageIndex
        //        }
        //        zoomIfApplicable()
    }
    
    func pageChanged(to pageIndex: Int) {
        print("pageChanged to \(pageIndex)")
        //        withAnimation {
        //            selectedViewModelIndex = pageIndex
        //        }
        //        zoomIfApplicable()
    }
    
    
    //MARK: - Helpers
    
    let texts = [
        "Here", "are", "some test", "strings to work on"
    ]
}

//MARK: - TextBox
struct TextBox {
    var boundingBox: CGRect
    var color: Color
    var tapHandler: (() -> ())?
}

//MARK: - TextBoxLayer

struct TextBoxesLayer: View {
    
    let textBoxes: [TextBox]
    
    var body: some View {
        boxesLayer
    }
    
    var boxesLayer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(textBoxes.indices, id: \.self) { i in
                    TextBoxView(textBox: textBoxes[i],
                                size: geometry.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

//MARK: - TextBoxView

struct TextBoxView: View {
    
    let textBox: TextBox
    let size: CGSize
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let tapHandler = textBox.tapHandler {
                    button(tapHandler)
                } else {
                    box
                }
                Spacer()
            }
            Spacer()
        }
        .offset(x: rect.minX, y: rect.minY)
    }
    
    var rect: CGRect {
        textBox.boundingBox.rectForSize(size)
    }
    
    func button(_ didTap: @escaping () -> ()) -> some View {
        Button {
            Haptics.feedback(style: .rigid)
            didTap()
        } label: {
            box
        }
    }
    
    var box: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(textBox.color)
            .opacity(0.3)
            .frame(width: rect.width,
                   height: rect.height)
        
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(textBox.color, lineWidth: 1)
                    .opacity(0.8)
            )
            .shadow(radius: 3, x: 0, y: 2)
//            .opacity(isPaging ? 0 : 1)
//            .animation(.default, value: isPaging)
    }
}

//MARK: - Preview

public struct TextPickerPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    //    @State var fieldValue: FieldValue
    @State var selectedImageText: ImageText
    
    public init() {
        //        let viewModel = FoodFormViewModel.mock(for: .phillyCheese)
        let viewModel = FoodFormViewModel.mockWith5Images
        _viewModel = StateObject(wrappedValue: viewModel)
        
        //        let fieldValue = FieldValue.energy()
        //        _fieldValue = State(initialValue: fieldValue)
        //
        let text = viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "57710D30-C601-4F36-8A10-62C8C2674702")!})!
        _selectedImageText = State(initialValue: ImageText(
            text: text,
            imageId: viewModel.imageViewModels.first!.id)
        )
    }
    
    public var body: some View {
        NavigationView {
            Text("")
                .sheet(isPresented: .constant(true)) {
                    TextPicker(config: textPickerConfig)
                }
                .navigationTitle("Text Picker")
        }
    }
    
    var textPickerConfig: TextPickerConfiguration {
        TextPickerConfiguration(
            imageViewModels: viewModel.imageViewModels,
            selectedImageTexts: [selectedImageText]
        )
    }
    
}

struct TextPicker_Previews: PreviewProvider {
    static var previews: some View {
        TextPickerPreview()
    }
}




import SwiftUI
import VisionSugar
import SwiftUISugar

/// This identifies an area of the ZoomableScrollView to focus on
public struct FocusedBox {
    
    /// This is the boundingBox (in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision)
    let boundingBox: CGRect
    let padded: Bool
    let animated: Bool
    let imageSize: CGSize
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
    }
    
    public static let none = Self.init(boundingBox: .zero, imageSize: .zero)
}

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    var focusedBox: Binding<FocusedBox?>?
    @State var lastFocusedArea: FocusedBox? = nil
    @State var firstTime: Bool = true
    
    private var content: Content
    
    public init(focusedBox: Binding<FocusedBox?>? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.focusedBox = focusedBox
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        scrollView(context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
        
        if let focusedBox = focusedBox?.wrappedValue {
            
            /// If we've set it to `.zero` we're indicating that we want it to reset the zoom
            if focusedBox.boundingBox == .zero {
                uiView.setZoomScale(1, animated: true)
            } else {
                uiView.focus(on: focusedBox)
            }
//            self.focusedBox?.wrappedValue = nil
        }
    }
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        @objc func doubleTapped(recognizer:  UITapGestureRecognizer) {
            
        }
    }
}


import UIKit

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = ((UITapGestureRecognizer) -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: ((UITapGestureRecognizer) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            let location = sender.location(in: self)
            action?(sender)
        } else {
            print("no action")
        }
    }
    
}


import UIKit

extension UIScrollView {

    func focus(on message: FocusedBox, animated: Bool = true) {
        zoomIn(boundingBox: message.boundingBox, padded: message.padded, imageSize: message.imageSize, animated: message.animated)
    }
    
    func zoomIn(boundingBox: CGRect, padded: Bool, imageSize: CGSize, animated: Bool = true) {

        /// Now determine the box we want to zoom into, given the image's dimensions
        /// Now if the image's width/height ratio is less than the scrollView's
        ///     we'll have padding on the x-axis, so determine what this would be based on the scrollView's frame's ratio and the current zoom scale
        ///     Add this to the box's x-axis to determine its true rect within the scrollview
        /// Or if the image's width/height ratio is greater than the scrollView's
        ///     we'll have y-axis padding, determine this
        ///     Add this to box's y-axis to determine its true rect
        /// Now zoom to this rect

        /// We have a `boundingBox` (y-value to bottom), and the original `imageSize`

        /// First determine the current size and x or y-padding of the image given the current contentSize of the `scrollView`
        let paddingLeft: CGFloat?
        let paddingTop: CGFloat?
        let width: CGFloat
        let height: CGFloat

//            let scrollViewSize: CGSize = CGSize(width: 428, height: 376)
        let scrollViewSize: CGSize = frame.size
//            let scrollViewSize: CGSize
//            if let view = scrollView.delegate?.viewForZooming?(in: scrollView) {
//                scrollViewSize = view.frame.size
//            } else {
//                scrollViewSize = scrollView.contentSize
//            }

        if imageSize.widthToHeightRatio < frame.size.widthToHeightRatio {
            /// height would be the same as `scrollView.frame.size.height`
            height = scrollViewSize.height
            width = (imageSize.width * height) / imageSize.height
            paddingLeft = (scrollViewSize.width - width) / 2.0
            paddingTop = nil
        } else {
            /// width would be the same as `scrollView.frame.size.width`
            width = scrollViewSize.width
            height = (imageSize.height * width) / imageSize.width
            paddingLeft = nil
            paddingTop = (scrollViewSize.height - height) / 2.0
        }

        let newImageSize = CGSize(width: width, height: height)

        if let paddingLeft = paddingLeft {
            print("paddingLeft: \(paddingLeft)")
        } else {
            print("paddingLeft: nil")
        }
        if let paddingTop = paddingTop {
            print("paddingTop: \(paddingTop)")
        } else {
            print("paddingTop: nil")
        }
        print("newImageSize: \(newImageSize)")

        var newBox = boundingBox.rectForSize(newImageSize)
        if let paddingLeft = paddingLeft {
            newBox.origin.x += paddingLeft
        }
        if let paddingTop = paddingTop {
            newBox.origin.y += paddingTop
        }
        print("newBox: \(newBox)")

        if padded {
            let minimumPadding: CGFloat = 5
            let zoomOutPaddingRatio: CGFloat = min(newImageSize.width / (newBox.size.width * 5), 3.5)
            print("zoomOutPaddingRatio: \(zoomOutPaddingRatio)")

            /// If the box is longer than it is tall
            if newBox.size.widthToHeightRatio > 1 {
                /// Add 100% padding to its horizontal side
                let padding = newBox.size.width * zoomOutPaddingRatio
                newBox.origin.x -= (padding / 2.0)
                newBox.size.width += padding

                /// Now correct the values in case they're out of bounds
                newBox.origin.x = max(minimumPadding, newBox.origin.x)
                if newBox.maxX > newImageSize.width {
                    newBox.size.width = newImageSize.width - newBox.origin.x - minimumPadding
                }
            } else {
                /// Add 100% padding to its vertical side
                let padding = newBox.size.height * zoomOutPaddingRatio
                newBox.origin.y -= (padding / 2.0)
                newBox.size.height += padding

                /// Now correct the values in case they're out of bounds
                newBox.origin.y = max(minimumPadding, newBox.origin.y)
                if newBox.maxY > newImageSize.height {
                    newBox.size.height = newImageSize.height - newBox.origin.y - minimumPadding
                }
            }
            print("newBox (padded): \(newBox)")
        }

        zoom(to: newBox, animated: animated)
    }
}


import SwiftUI
import VisionSugar
import SwiftUISugar

extension ZoomableScrollView {

    func hostedView(context: Context) -> UIView {
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return hostedView
    }
    
    func scrollView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true

        let hosted = hostedView(context: context)
        hosted.frame = scrollView.bounds
        hosted.backgroundColor = .black
        scrollView.addSubview(hosted)

        scrollView.setZoomScale(1, animated: true)
        
        scrollView.addTapGestureRecognizer { sender in
            
            let hostedView = hostedView(context: context)
            let point = sender.location(in: hostedView)
            let sizeToBaseRectOn = scrollView.frame.size
//            let sizeToBaseRectOn = hostedView.frame.size
            
            let size = CGSize(width: sizeToBaseRectOn.width / 2,
                              height: sizeToBaseRectOn.height / 2)
            let zoomSize = CGSize(width: size.width / scrollView.zoomScale,
                                  height: size.height / scrollView.zoomScale)

            print("""
Got a tap at: \(point), when:
    hostedView.size: \(hostedView.frame.size)
    scrollView.size: \(scrollView.frame.size)
    scrollView.contentSize: \(scrollView.contentSize)
    scrollView.zoomScale: \(scrollView.zoomScale)
    size: \(size)
    🔍 zoomSize: \(zoomSize)
""")

            let origin = CGPoint(x: point.x - zoomSize.width / 2,
                                 y: point.y - zoomSize.height / 2)
            scrollView.zoom(to:CGRect(origin: origin, size: zoomSize), animated: true)
        }

        return scrollView
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint, scrollView: UIScrollView, context: Context) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = hostedView(context: context).frame.size.height / scale
        zoomRect.size.width  = hostedView(context: context).frame.size.width  / scale
        let newCenter = scrollView.convert(center, from: hostedView(context: context))
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
        //    func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
        //        if (zoomScale > minimumZoomScale) {
        //            setZoomScale(minimumZoomScale, animated: true)
        //        }
        //        else {
        //            //(I divide by 3.0 since I don't wan't to zoom to the max upon the double tap)
        //            let zoomRect = zoomRectForScale(scale: maximumZoomScale / 3.0, center: recognizer.location(in: recognizer.view))
        //            zoom(to: zoomRect, animated: true)
        //        }
        //    }
        //
        //    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        //        var zoomRect = CGRect.zero
        //        if let imageV = self.viewForZooming {
        //            zoomRect.size.height = imageV.frame.size.height / scale;
        //            zoomRect.size.width  = imageV.frame.size.width  / scale;
        //            let newCenter = imageV.convert(center, from: self)
        //            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
        //            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        //        }
        //        return zoomRect;
        //    }
}
