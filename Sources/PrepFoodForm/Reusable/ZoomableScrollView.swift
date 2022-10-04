//import SwiftUI
//import CoreMedia
//import VisionSugar
//
//extension Notification.Name {
//    static var resetZoomableScrollViewScale: Notification.Name { return .init("resetZoomableScrollViewScale") }
//    static var scrollZoomableScrollViewToRect: Notification.Name { return .init("scrollZoomableScrollViewToRect") }
//}
//
//extension Notification {
//    struct Keys {
//        static let rect = "rect"
//        static let boundingBox = "boundingBox"
//        static let imageSize = "imageSize"
//    }
//}
//
//public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
//    private var content: Content
//    
//    public init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    public func makeUIView(context: Context) -> UIScrollView {
//        // set up the UIScrollView
//        let scrollView = UIScrollView()
//        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
//        scrollView.maximumZoomScale = 20
//        scrollView.minimumZoomScale = 1
//        scrollView.bouncesZoom = true
//        
//        // create a UIHostingController to hold our SwiftUI content
//        let hostedView = context.coordinator.hostingController.view!
//        hostedView.translatesAutoresizingMaskIntoConstraints = true
//        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        hostedView.frame = scrollView.bounds
////        hostedView.backgroundColor = UIColor.systemGroupedBackground
//        scrollView.addSubview(hostedView)
//
//        scrollView.setZoomScale(1, animated: true)
//
//        NotificationCenter.default.addObserver(forName: .resetZoomableScrollViewScale, object: nil, queue: .main) { notification in
//            scrollView.setZoomScale(1, animated: true)
//        }
//        
//        NotificationCenter.default.addObserver(forName: .scrollZoomableScrollViewToRect, object: nil, queue: .main) { notification in
//            guard let boundingBox = notification.userInfo?[Notification.Keys.boundingBox] as? CGRect,
//                  let imageSize = notification.userInfo?[Notification.Keys.imageSize] as? CGSize
//            else {
//                return
//            }
//
//            /// Now determine the box we want to zoom into, given the image's dimensions
//            /// Now if the image's width/height ratio is less than the scrollView's
//            ///     we'll have padding on the x-axis, so determine what this would be based on the scrollView's frame's ratio and the current zoom scale
//            ///     Add this to the box's x-axis to determine its true rect within the scrollview
//            /// Or if the image's width/height ratio is greater than the scrollView's
//            ///     we'll have y-axis padding, determine this
//            ///     Add this to box's y-axis to determine its true rect
//            /// Now zoom to this rect
//
//            /// We have a `boundingBox` (y-value to bottom), and the original `imageSize`
//            
//            /// First determine the current size and x or y-padding of the image given the current contentSize of the `scrollView`
//            let paddingLeft: CGFloat?
//            let paddingTop: CGFloat?
//            let width: CGFloat
//            let height: CGFloat
//            
////            let scrollViewSize: CGSize = CGSize(width: 428, height: 376)
//            let scrollViewSize: CGSize = scrollView.frame.size
////            let scrollViewSize: CGSize
////            if let view = scrollView.delegate?.viewForZooming?(in: scrollView) {
////                scrollViewSize = view.frame.size
////            } else {
////                scrollViewSize = scrollView.contentSize
////            }
//            
//            if imageSize.widthToHeightRatio < scrollView.frame.size.widthToHeightRatio {
//                /// height would be the same as `scrollView.frame.size.height`
//                height = scrollViewSize.height
//                width = (imageSize.width * height) / imageSize.height
//                paddingLeft = (scrollViewSize.width - width) / 2.0
//                paddingTop = nil
//            } else {
//                /// width would be the same as `scrollView.frame.size.width`
//                width = scrollViewSize.width
//                height = (imageSize.height * width) / imageSize.width
//                paddingLeft = nil
//                paddingTop = (scrollViewSize.height - height) / 2.0
//            }
//
//            let newImageSize = CGSize(width: width, height: height)
//
//            if let paddingLeft = paddingLeft {
//                print("paddingLeft: \(paddingLeft)")
//            } else {
//                print("paddingLeft: nil")
//            }
//            if let paddingTop = paddingTop {
//                print("paddingTop: \(paddingTop)")
//            } else {
//                print("paddingTop: nil")
//            }
//            print("newImageSize: \(newImageSize)")
//            
//            var newBox = boundingBox.rectForSize(newImageSize)
//            if let paddingLeft = paddingLeft {
//                newBox.origin.x += paddingLeft
//            }
//            if let paddingTop = paddingTop {
//                newBox.origin.y += paddingTop
//            }
//            print("newBox: \(newBox)")
//            
//            let minimumPadding: CGFloat = 5
//            let zoomOutPaddingRatio: CGFloat = min(newImageSize.width / (newBox.size.width * 5), 3.5)
//            print("zoomOutPaddingRatio: \(zoomOutPaddingRatio)")
//
//            /// If the box is longer than it is tall
//            if newBox.size.widthToHeightRatio > 1 {
//                /// Add 100% padding to its horizontal side
//                let padding = newBox.size.width * zoomOutPaddingRatio
//                newBox.origin.x -= (padding / 2.0)
//                newBox.size.width += padding
//                
//                /// Now correct the values in case they're out of bounds
//                newBox.origin.x = max(minimumPadding, newBox.origin.x)
//                if newBox.maxX > newImageSize.width {
//                    newBox.size.width = newImageSize.width - newBox.origin.x - minimumPadding
//                }
//            } else {
//                /// Add 100% padding to its vertical side
//                let padding = newBox.size.height * zoomOutPaddingRatio
//                newBox.origin.y -= (padding / 2.0)
//                newBox.size.height += padding
//                
//                /// Now correct the values in case they're out of bounds
//                newBox.origin.y = max(minimumPadding, newBox.origin.y)
//                if newBox.maxY > newImageSize.height {
//                    newBox.size.height = newImageSize.height - newBox.origin.y - minimumPadding
//                }
//            }
//            print("newBox (padded): \(newBox)")
//            
//            scrollView.zoom(to: newBox, animated: true)
//        }
//
//        return scrollView
//    }
//    
////    func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
////        if (zoomScale > minimumZoomScale) {
////            setZoomScale(minimumZoomScale, animated: true)
////        }
////        else {
////            //(I divide by 3.0 since I don't wan't to zoom to the max upon the double tap)
////            let zoomRect = zoomRectForScale(scale: maximumZoomScale / 3.0, center: recognizer.location(in: recognizer.view))
////            zoom(to: zoomRect, animated: true)
////        }
////    }
////
////    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
////        var zoomRect = CGRect.zero
////        if let imageV = self.viewForZooming {
////            zoomRect.size.height = imageV.frame.size.height / scale;
////            zoomRect.size.width  = imageV.frame.size.width  / scale;
////            let newCenter = imageV.convert(center, from: self)
////            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
////            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
////        }
////        return zoomRect;
////    }
//    
//    public func makeCoordinator() -> Coordinator {
//        return Coordinator(hostingController: UIHostingController(rootView: self.content))
//    }
//    
//    public func updateUIView(_ uiView: UIScrollView, context: Context) {
//        // update the hosting controller's SwiftUI content
//        context.coordinator.hostingController.rootView = self.content
//        assert(context.coordinator.hostingController.view.superview == uiView)
//    }
//    
//    // MARK: - Coordinator
//    public class Coordinator: NSObject, UIScrollViewDelegate {
//        var hostingController: UIHostingController<Content>
//        
//        init(hostingController: UIHostingController<Content>) {
//            self.hostingController = hostingController
//        }
//        
//        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            return hostingController.view
//        }
//    }
//}
