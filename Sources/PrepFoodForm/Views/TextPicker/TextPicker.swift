import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
//import ZoomableScrollView
import ActivityIndicatorView

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var config: TextPickerConfiguration
    
    init(config: TextPickerConfiguration) {
        _config = StateObject(wrappedValue: config)
    }
    
    //MARK: - Views
    
    var body: some View {
        ZStack {
            pagerLayer
                .edgesIgnoringSafeArea(.all)
            buttonsLayer
        }
        .onAppear(perform: appeared)
        .onChange(of: config.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
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
        .onPageWillChange { index in
            config.pageWillChange(to: index)
        }
        .onPageChanged { index in
            config.pageDidChange(to: index)
        }
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = config.imageViewModels.firstIndex(of: imageViewModel),
           index < config.focusedBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(focusedBox: $config.focusedBoxes[index], backgroundColor: .black) {
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
        if config.showingBoxes {
            TextBoxesLayer(textBoxes: config.textBoxes(for: imageViewModel))
                .opacity((config.hasAppeared && config.showingBoxes) ? 1 : 0)
                .animation(.default, value: config.hasAppeared)
                .animation(.default, value: config.showingBoxes)
        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.black)
            .opacity(config.showingBoxes ? 0.7 : 1)
            .animation(.default, value: config.showingBoxes)
    }
    
    //MARK: ButtonsLayer
    
    var buttonsLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            if config.shouldShowBottomBar {
                bottomBar
            }
        }
    }
    
    var topBar: some View {
        ZStack {
            HStack {
                dismissButton
                Spacer()
            }
            HStack {
                Spacer()
                if let title {
                    titleView(for: title)
                }
                Spacer()
            }
            HStack {
                Spacer()
                doneButton
            }
        }
    }
    
    var bottomBar: some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                if config.shouldShowSelectedTextsBar {
                    selectedTextsBar
                }
                if config.shouldShowActionBar {
                    actionBar
                }
            }
        }
        .frame(height: bottomBarHeight)
        .background(.ultraThinMaterial)
    }
    
    var bottomBarHeight: CGFloat {
        var height: CGFloat = 0
        if config.shouldShowActionBar {
            height += actionBarHeight
        }
        if config.shouldShowSelectedTextsBar {
            height += selectedTextsBarHeight
        }
        return height
    }
    
    var actionBarHeight: CGFloat {
        70
    }
    
    var selectedTextsBarHeight: CGFloat {
        config.shouldShowActionBar ? 60 : 60
    }
    
    var actionBar: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(config.imageViewModels.indices, id: \.self) { index in
                    thumbnail(at: index)
                }
            }
            .padding(.leading, 20)
            .padding(.top, 15)
            Spacer()
            if config.shouldShowMenu {
                menuButton
                    .padding(.top, 15)
            }
        }
        .frame(height: 70)
    }
    
    var selectedTextsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(config.selectedImageTexts, id: \.self) { imageText in
                    selectedTextButton(for: imageText)
                }
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        //        .background(.green)
    }
    
    func selectedTextButton(for imageText: ImageText) -> some View {
        Button {
            withAnimation {
                config.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color.accentColor)
                HStack(spacing: 5) {
                    Text(imageText.text.string.capitalized)
                        .font(.title3)
                        .bold()
                    //                        .foregroundColor(.primary)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
            }
            .fixedSize(horizontal: true, vertical: true)
            .contentShape(Rectangle())
            .transition(.move(edge: .leading))
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    var doneButton: some View {
        if config.allowsMultipleSelection {
            Button {
                Haptics.successFeedback()
                config.didSelectImageTexts?(config.selectedImageTexts)
                dismiss()
            } label: {
                Text("Done")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.accentColor.opacity(0.8))
                            .background(.ultraThinMaterial)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .disabled(config.selectedImageTexts.isEmpty)
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
    
    var title: String? {
        guard config.didSelectImageTexts != nil else { return nil }
        if config.allowsMultipleSelection {
            return "Select texts"
        } else {
            return "Select a text"
        }
    }
    
    func titleView(for title: String) -> some View {
        Text(title)
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
            if config.allowsTogglingTexts {
                Button {
                    withAnimation {
                        config.showingBoxes.toggle()
                    }
                } label: {
                    Label("\(config.showingBoxes ? "Hide" : "Show") Texts", systemImage: "text.viewfinder")
                }
            }
            //            Divider()
            if config.deleteImageHandler != nil {
                Button(role: .destructive) {
                    config.deleteCurrentImage()
                } label: {
                    Label("Remove Photo", systemImage: "trash")
                }
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
            if let image = config.imageViewModels[index].image {
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
    @State var text_4percent: ImageText
    @State var text_nutritionInformation: ImageText
    @State var text_servingSize: ImageText
    @State var text_servingsPerPackage: ImageText
    @State var text_allNatural: ImageText
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .phillyCheese)
        //        let viewModel = FoodFormViewModel.mockWith5Images
        _viewModel = StateObject(wrappedValue: viewModel)
        
        _text_4percent = State(initialValue: ImageText(
            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "57710D30-C601-4F36-8A10-62C8C2674702")!})!,
            imageId: viewModel.imageViewModels.first!.id)
        )
        
        _text_allNatural = State(initialValue: ImageText(
            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "939BB79B-612E-459E-A6B6-C6AD739F382F")!})!,
            imageId: viewModel.imageViewModels.first!.id)
        )
        
        _text_nutritionInformation = State(initialValue: ImageText(
            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "2D44204B-DD7E-41FC-B807-C10DEB86B8F8")!})!,
            imageId: viewModel.imageViewModels.first!.id)
        )
        
        _text_servingSize = State(initialValue: ImageText(
            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "8229CEAC-9AC4-432B-8D1D-0073A6208E14")!})!,
            imageId: viewModel.imageViewModels.first!.id)
        )
        
        _text_servingsPerPackage = State(initialValue: ImageText(
            text: viewModel.imageViewModels.first!.texts.first(where: { $0.id == UUID(uuidString: "00EECEEC-5D78-4DD4-BFF1-4B259296FE06")!})!,
            imageId: viewModel.imageViewModels.first!.id)
        )
        
    }
    
    public var body: some View {
        NavigationView {
            Text("")
                .fullScreenCover(isPresented: .constant(true)) {
                    TextPicker(config: textPickerConfig)
                }
                .navigationTitle("Text Picker")
        }
    }
    
    var textPickerConfig: TextPickerConfiguration {
        TextPickerConfiguration(
            imageViewModels: viewModel.imageViewModels,
            //            selectedImageTexts: [text_4percent]
            selectedImageTexts: [text_nutritionInformation, text_allNatural, text_servingsPerPackage, text_servingSize],
            allowsMultipleSelection: true,
            allowsTogglingTexts: true,
            deleteImageHandler: { index in
                
            },
            didSelectImageTexts:  { imageTexts in
                
            }
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
    
    let backgroundColor: UIColor?
    private var content: Content
    
    public init(focusedBox: Binding<FocusedBox?>? = nil, backgroundColor: UIColor? = nil, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
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
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            print("🔍 zoomScale is \(scrollView.zoomScale)")
        }
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
        if let backgroundColor {
            hosted.backgroundColor = backgroundColor
        }
        scrollView.addSubview(hosted)
        
        scrollView.setZoomScale(1, animated: true)
        
        scrollView.addTapGestureRecognizer { sender in
            
            //TODO: Rewrite this
            /// - Default should be to have a maximum scale, and
            ///     If we're less than that (and not super-close to it): zoom into it
            ///     Otherwise, if we're close to it, at it, or past it: zoom back out to full scale
            /// - Now also have a handler that can be provided to this, which overrides this default
            ///     It should provide the current zoom scale and
            ///     Get back an enum called ZoomPosition as a result
            ///         This can be either fullScale, maxScale, or rect(let CGRect) where we provide a rect
            ///         The scrollview than either zooms to full, max or the provided rect
            /// - Now have TextPicker use this to
            ///     See if the zoomScale is above or below the selected bound's scale
            ///         This can be determined by dividing the rects dimensions by the image's and returning the larger? amount
            ///     If it's greater than the selectedBoundZoomScale:
            ///         If the selectedBoundZoomScale is less than the constant MaxScale of ZoomScrollView
            ///         (by at least a minimum distance—also set by ZoomedScrollView)
            ///             Then we return MaxScale as the ZoomPosition
            ///         Else we return FullScale as the ZoomPosition (scale = 1)
            ///     Else we return rect(selectedBound) as the ZoomPosition
            
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


import UIKit

extension UIScrollView {
    
    func focus(on focusedBox: FocusedBox, animated: Bool = true) {
        zoomIn(
            boundingBox: focusedBox.boundingBox,
            padded: focusedBox.padded,
            imageSize: focusedBox.imageSize,
            animated: focusedBox.animated
        )
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
        
        let scrollViewSize: CGSize = frame.size
        
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
        
        let scaledImageSize = CGSize(width: width, height: height)
        
        var newBox = boundingBox.rectForSize(scaledImageSize)
        
        print("🔍 scaledImageSize is \(scaledImageSize)")


        if let paddingLeft = paddingLeft {
            newBox.origin.x += paddingLeft
        }
        if let paddingTop = paddingTop {
            newBox.origin.y += paddingTop
        }
        print("🔍 newBox: \(newBox)")
        
        if padded {
            newBox = newBox.padded(within: scrollViewSize)
        }
        
        print("🔍 zoomIn on: \(newBox) within \(frame.size)")
        let zoomScaleX = frame.size.width / newBox.width
        print("🔍 zoomScaleX is \(zoomScaleX)")
        let zoomScaleY = frame.size.height / newBox.height
        print("🔍 zoomScaleY is \(zoomScaleY)")

        print("🔍 🤖 calculated zoomScale is: \(newBox.zoomScale(within: frame.size))")

        zoom(to: newBox, animated: animated)
    }
}


public enum ZoomPaddingType {
    case smallElement
    case largeSection
}

extension CGRect {
    
    func zoomScale(within parentSize: CGSize) -> CGFloat {
        let xScale = parentSize.width / width
        let yScale = parentSize.height / height
        return min(xScale, yScale)
    }
    
    func padded(for type: ZoomPaddingType, within parentSize: CGSize) -> CGRect {
        switch type {
        case .largeSection:
            return paddedForLargeSection(within: parentSize)
        case .smallElement:
            return paddedForSmallElement(within: parentSize)
        }
    }
    
    func paddedForSmallElement(within parentSize: CGSize) -> CGRect {
        var newBox = self
        let minimumPadding: CGFloat = 5
        let paddingRatio: CGFloat = min(parentSize.width / (newBox.size.width * 5), 3.5)
        newBox.padX(withRatio: paddingRatio, withinParentSize: parentSize)
        newBox.padY(withRatio: paddingRatio, withinParentSize: parentSize)
        return newBox
        
        /// If the box is longer than it is tall
        if newBox.size.widthToHeightRatio > 1 {
            /// Add 100% padding to its horizontal side
            let padding = newBox.size.width * paddingRatio
            newBox.origin.x -= (padding / 2.0)
            newBox.size.width += padding
            
            /// Now correct the values in case they're out of bounds
            newBox.origin.x = max(minimumPadding, newBox.origin.x)
            if newBox.maxX > parentSize.width {
                newBox.size.width = parentSize.width - newBox.origin.x - minimumPadding
            }
        } else {
            /// Add 100% padding to its vertical side
            let padding = newBox.size.height * paddingRatio
            newBox.origin.y -= (padding / 2.0)
            newBox.size.height += padding
            
            /// Now correct the values in case they're out of bounds
            newBox.origin.y = max(minimumPadding, newBox.origin.y)
            if newBox.maxY > parentSize.height {
                newBox.size.height = parentSize.height - newBox.origin.y - minimumPadding
            }
        }
        print("newBox (padded): \(newBox)")
        return newBox
    }
    
    func paddedForLargeSection(within parentSize: CGSize) -> CGRect {
        var newBox = self
        let paddingRatio: CGFloat = parentSize.width / (newBox.size.width * 5)
        newBox.padX(withRatio: paddingRatio, withinParentSize: parentSize)
        newBox.padY(withRatio: paddingRatio, withinParentSize: parentSize)
        print("newBox (padded): \(newBox)")
        return newBox
    }
    
    func padded(within parentSize: CGSize) -> CGRect {
        var newBox = self
        let paddingRatio: CGFloat = parentSize.width / (newBox.size.width * 5)
        newBox.padX(withRatio: paddingRatio, withinParentSize: parentSize)
        newBox.padY(withRatio: paddingRatio, withinParentSize: parentSize)
        print("newBox (padded): \(newBox)")
        return newBox
    }

}

extension CGRect {

    mutating func padX(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padX(withRatioOfWidth: paddingRatio)
        origin.x = max(padding, origin.x)
        if maxX > parentSize.width {
            size.width = parentSize.width - origin.x - padding
        }
    }

    mutating func padY(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padY(withRatioOfHeight: paddingRatio)
        origin.y = max(padding, origin.y)
        if maxY > parentSize.height {
            size.height = parentSize.height - origin.y - padding
        }
    }
    
    mutating func padX(withRatioOfWidth ratio: CGFloat) {
        let padding = size.width * ratio
        padX(with: padding)
    }
    
    mutating func padX(with padding: CGFloat) {
        origin.x -= (padding / 2.0)
        size.width += padding
    }
    
    mutating func padY(withRatioOfHeight ratio: CGFloat) {
        let padding = size.height * ratio
        padY(with: padding)
    }
    
    mutating func padY(with padding: CGFloat) {
        origin.y -= (padding / 2.0)
        size.height += padding
    }

}
