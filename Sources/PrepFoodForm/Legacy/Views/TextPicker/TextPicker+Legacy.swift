//import SwiftUI
//import SwiftHaptics
//import FoodLabelScanner
//import VisionSugar
//import SwiftUIPager
//import ZoomableScrollView
//import ActivityIndicatorView
//
//extension TextPicker {
//    //MARK: - Legacy UI
//    var navigationLeadingContents: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarLeading) {
//            Button("Done") {
//                if let didSelectImageTexts {
//                    didSelectImageTexts(selectedImageTexts)
//                    Haptics.successFeedback()
//                }
//                dismiss()
//            }
////            if mode == .viewing {
//                Button {
//                    withAnimation {
//                        showingBoxes.toggle()
//                    }
//                } label: {
//                    Image(systemName: "text.viewfinder")
//                        .foregroundColor(showingBoxes ? .accentColor : .secondary)
//                }
////            }
//        }
//    }
//    
//    var title: String {
////        switch mode {
////        case .picking:
////            return allowsMultipleSelection ? "Select texts" : "Select a text"
////        case .viewing:
//            return "Source Images"
////        }
//    }
//    
//    var navigationTrailingContents: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
////            if mode == .viewing {
////            if hasAppeared {
//                Button {
//                    //TODO: Use callback here
////                    viewModel.removeImage(at: currentIndex)
////                    currentIndex -= 1
////                    Haptics.successFeedback()
////                    if viewModel.imageViewModels.isEmpty {
////                        dismiss()
////                    }
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                        .transition(.opacity)
//                }
//                .opacity(hasAppeared ? 1 : 0)
////            }
//        }
//    }
//    
//    var bottomToolbar: some ToolbarContent {
//        ToolbarItemGroup(placement: .bottomBar) {
//            Spacer()
//            HStack {
//                ForEach(imageViewModels.indices, id: \.self) { index in
//                    thumbnail(at: index)
//                }
//            }
////            .frame(width: .infinity)
//            Spacer()
//        }
//    }
//    
//    var selectedTextsLayer: some View {
//        VStack {
//            Spacer()
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(selectedImageTexts, id: \.self) { imageText in
//                        selectedTextButton(for: imageText)
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 50)
//            .background(
//                .thickMaterial
//            )
////            .cornerRadius(15)
////            .padding(.horizontal)
////            .padding(.bottom)
//        }
//    }
//
//    @ViewBuilder
//    func boxesLayer(for imageViewModel: ImageViewModel) -> some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .topLeading) {
//                boxLayerForSelectedText(inSize: geometry.size, for: imageViewModel)
//                ForEach(texts(for: imageViewModel).indices, id: \.self) { i in
//                    let text = texts(for: imageViewModel)[i]
//                    if selectedText?.id != text.id {
//                        boxLayer(for: text, inSize: geometry.size)
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//    }
//    
//    @ViewBuilder
//    func boxLayerForSelectedText(inSize size: CGSize, for imageViewModel: ImageViewModel) -> some View {
//        if let selectedBoundingBox,
//           let imageViewIndex = imageViewModels.firstIndex(of: imageViewModel),
//           let selectedImageIndex,
//           selectedImageIndex == imageViewIndex
//        {
//            boxLayer(boundingBox: selectedBoundingBox, inSize: size, color: .accentColor) {
//                dismiss()
//            }
//        }
//    }
//    
//    func boxLayer(for text: RecognizedText, inSize size: CGSize) -> some View {
//        boxLayer(boundingBox: text.boundingBox, inSize: size, color: color(for: text)) {
//            guard let currentScanResultId else {
//                return
//            }
//            let imageText = ImageText(text: text, imageId: currentScanResultId)
//            
//            if allowsMultipleSelection {
//                toggleSelection(of: imageText)
//            } else {
//                if let didSelectImageTexts {
//                    didSelectImageTexts([imageText])
//                }
//                dismiss()
//            }
//        }
//    }
//    
//    func boxLayer(boundingBox: CGRect, inSize size: CGSize, color: Color, didTap: @escaping () -> ()) -> some View {
//        var box: some View {
//            RoundedRectangle(cornerRadius: 3)
//                .foregroundColor(Color(.systemFill))
////                .foregroundStyle(
////                    color.gradient.shadow(
////                        .inner(color: .black, radius: 3)
////                    )
////                )
////                .opacity(0.3)
//                .frame(width: boundingBox.rectForSize(size).width,
//                       height: boundingBox.rectForSize(size).height)
//
//                .overlay(
//                    RoundedRectangle(cornerRadius: 3)
//                        .stroke(color, lineWidth: 1)
//                        .opacity(0.8)
//                )
//                .shadow(radius: 3, x: 0, y: 2)
//                .opacity(hasAppeared ? 1 : 0)
//                .animation(.default, value: hasAppeared)
//        }
//        
//        var button: some View {
//            Button {
//                Haptics.feedback(style: .rigid)
//                didTap()
//            } label: {
//                box
//            }
//        }
//        
//        return HStack {
//            VStack(alignment: .leading) {
////                if mode == .picking {
////                    button
////                } else {
//                    box
////                }
//                Spacer()
//            }
//            Spacer()
//        }
//        .offset(x: boundingBox.rectForSize(size).minX,
//                y: boundingBox.rectForSize(size).minY)
//    }
//    
//    func selectedTextButton(for imageText: ImageText) -> some View {
//        Button {
//            withAnimation {
//                selectedImageTexts.removeAll(where: { $0 == imageText })
//            }
//        } label: {
//            ZStack {
//                Capsule(style: .continuous)
//                    .foregroundColor(Color(.secondarySystemFill))
//                HStack(spacing: 5) {
//                    Text(imageText.text.string)
//                        .foregroundColor(.primary)
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 5)
//            }
//            .fixedSize(horizontal: true, vertical: true)
//            .contentShape(Rectangle())
//            .transition(.move(edge: .leading))
//        }
//    }
//}
