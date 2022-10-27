import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import SwiftUIPager
import ZoomableScrollView
import ActivityIndicatorView
import SwiftUISugar

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var textPickerViewModel: TextPickerViewModel
    
    init(imageViewModels: [ImageViewModel], mode: TextPickerMode) {
        let viewModel = TextPickerViewModel(
            imageViewModels: imageViewModels,
            mode: mode
        )
        _textPickerViewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Views
    
    var body: some View {
        ZStack {
            pagerLayer
//                .edgesIgnoringSafeArea(.all)
            buttonsLayer
        }
        .onAppear(perform: appeared)
        .onChange(of: textPickerViewModel.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .bottomMenu(isPresented: $textPickerViewModel.showingMenu, menu: bottomMenu)
        .bottomMenu(isPresented: $textPickerViewModel.showingAutoFillConfirmation,
                    menu: confirmAutoFillMenu)
    }
    
    //MARK:  Pager Layer
    
    var pagerLayer: some View {
        Pager(
            page: textPickerViewModel.page,
            data: textPickerViewModel.imageViewModels,
            id: \.hashValue,
            content: { imageViewModel in
                zoomableScrollView(for: imageViewModel)
                    .background(.black)
            })
        .sensitivity(.high)
        .pagingPriority(.high)
        .onPageWillChange { index in
            textPickerViewModel.pageWillChange(to: index)
        }
        .onPageChanged { index in
            textPickerViewModel.pageDidChange(to: index)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func zoomableScrollView(for imageViewModel: ImageViewModel) -> some View {
        if let index = textPickerViewModel.imageViewModels.firstIndex(of: imageViewModel),
           index < textPickerViewModel.zoomBoxes.count,
           let image = imageViewModel.image
        {
            ZoomableScrollView(
                id: textPickerViewModel.imageViewModels[index].id,
                zoomBox: $textPickerViewModel.zoomBoxes[index],
                backgroundColor: .black
            ) {
                imageView(image)
                    .overlay(textBoxesLayer(for: imageViewModel))
            }
        }
    }
    
    @ViewBuilder
    func textBoxesLayer(for imageViewModel: ImageViewModel) -> some View {
//        if config.showingBoxes {
            TextBoxesLayer(textBoxes: textPickerViewModel.textBoxes(for: imageViewModel))
                .opacity((textPickerViewModel.hasAppeared && textPickerViewModel.showingBoxes) ? 1 : 0)
                .animation(.default, value: textPickerViewModel.hasAppeared)
                .animation(.default, value: textPickerViewModel.showingBoxes)
//        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.black)
            .opacity(textPickerViewModel.showingBoxes ? 0.7 : 1)
            .animation(.default, value: textPickerViewModel.showingBoxes)
    }
    
    //MARK: ButtonsLayer
    
    var buttonsLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            if textPickerViewModel.shouldShowBottomBar {
                bottomBar
                    .transition(.move(edge: .bottom))
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
                        .transition(.scale)
                }
                Spacer()
            }
            HStack {
                Spacer()
                if textPickerViewModel.shouldShowMenuInTopBar {
                    topMenuButton
                        .transition(.move(edge: .trailing))
                } else {
                    doneButton
                }
            }
        }
        .frame(height: 64)
    }
    
    var bottomBar: some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                if textPickerViewModel.shouldShowSelectedTextsBar {
                    selectedTextsBar
                }
                if textPickerViewModel.shouldShowColumnPickerBar {
                    columnPickerBar
                }
                if textPickerViewModel.showShowImageSelector {
                    actionBar
                }
            }
        }
        .frame(height: bottomBarHeight)
        .background(.ultraThinMaterial)
    }
    
    var bottomBarHeight: CGFloat {
        var height: CGFloat = 0
        if textPickerViewModel.showShowImageSelector {
            height += actionBarHeight
        }
        if textPickerViewModel.shouldShowSelectedTextsBar {
            height += selectedTextsBarHeight
        }
        if textPickerViewModel.shouldShowColumnPickerBar {
            height += columnPickerBarHeight
        }

        return height
    }
    
    var actionBarHeight: CGFloat { 70 }
    var selectedTextsBarHeight: CGFloat { 60 }
    var columnPickerBarHeight: CGFloat { 60 }

    var actionBar: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(textPickerViewModel.imageViewModels.indices, id: \.self) { index in
                    thumbnail(at: index)
                }
            }
            .padding(.leading, 20)
            .padding(.top, 15)
            Spacer()
//            if config.shouldShowMenu {
//                menuButton
//                    .padding(.top, 15)
//            }
        }
        .frame(height: 70)
    }
    
    var selectedTextsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(textPickerViewModel.selectedImageTexts, id: \.self) { imageText in
                    selectedTextButton(for: imageText)
                }
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        //        .background(.green)
    }

    @State var pickedColumn: Int = 1
    
    @ViewBuilder
    var columnPickerBar: some View {
        if let columns = textPickerViewModel.columns {
            Picker("", selection: $textPickerViewModel.selectedColumn) {
                ForEach(columns.indices, id: \.self) { i in
//                    selectedTextButton(for: columns[i])
                    Text(columns[i].name)
                        .tag(i+1)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .onChange(of: textPickerViewModel.selectedColumn) { newValue in
                Haptics.feedback(style: .soft)
                textPickerViewModel.pickedColumn(newValue)
            }
        }
    }

    func selectedTextButton(for column: TextColumn) -> some View {
        Button {
            withAnimation {
                textPickerViewModel.pickedColumn(column.column)
            }
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color.accentColor)
                HStack(spacing: 5) {
                    Text(column.name)
                        .font(.title3)
                        .bold()
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
    
    func selectedTextButton(for imageText: ImageText) -> some View {
        Button {
            withAnimation {
                textPickerViewModel.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color.accentColor)
                HStack(spacing: 5) {
                    Text(imageText.text.string.capitalizedIfUppercase)
                        .font(.title3)
                        .bold()
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
        if textPickerViewModel.shouldShowDoneButton {
            Button {
                if textPickerViewModel.shouldDismissAfterTappingDone() {
                    Haptics.successFeedback()
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            } label: {
                Text("Done")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.accentColor.opacity(0.8))
                            .background(.ultraThinMaterial)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15)
                    )
                    .shadow(radius: 3, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .disabled(textPickerViewModel.selectedImageTexts.isEmpty)
            .transition(.scale)
            .buttonStyle(.borderless)
        }
    }
    var dismissButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            textPickerViewModel.tappedDismiss()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                )
                .clipShape(Circle())
                .shadow(radius: 3, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
    }
    
    var title: String? {
        textPickerViewModel.mode.prompt
    }
    
    func titleView(for title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
//            .padding(12)
            .padding(.horizontal, 12)
            .frame(height: 45)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .shadow(radius: 3, x: 0, y: 3)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
    }
    
    var topMenuButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            textPickerViewModel.showingMenu = true
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 40, height: 40)
                .foregroundColor(.primary)
                .background(
                    Circle()
                        .foregroundColor(.clear)
                        .background(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                )
                .clipShape(Circle())
                .shadow(radius: 3, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())

        }
    }
    
    var confirmAutoFillMenu: BottomMenu {
        let group = BottomMenuActionGroup(actions: [
            BottomMenuAction(
                title: "This will replace any existing data."
            ),
            BottomMenuAction(
                title: "AutoFill",
                tapHandler: {
                    textPickerViewModel.tappedConfirmAutoFill()
                }
            )
        ])
        return BottomMenu(group: group)
    }
    
    var autoFillLinkAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            linkedMenu: confirmAutoFillMenu
        )
    }
    
    var autoFillButtonAction: BottomMenuAction {
        BottomMenuAction(
            title: "AutoFill",
            systemImage: "text.viewfinder",
            tapHandler: {
                textPickerViewModel.tappedAutoFill()
            }
        )
    }
    
    var autoFillAction: BottomMenuAction? {
        switch textPickerViewModel.columnCountForCurrentImage {
        case 2: return autoFillButtonAction
        case 1: return autoFillLinkAction
        default: return nil
        }
    }
    
    var showHideAction: BottomMenuAction {
        BottomMenuAction(
            title: "\(textPickerViewModel.showingBoxes ? "Hide" : "Show") Texts",
            systemImage: "eye\(textPickerViewModel.showingBoxes ? ".slash" : "")",
            tapHandler: {
                withAnimation {
                    textPickerViewModel.showingBoxes.toggle()
                }
            })
    }
    
    var firstMenuGroup: BottomMenuActionGroup {
        let actions: [BottomMenuAction]
        if let autoFillAction {
            actions = [autoFillAction, showHideAction]
        } else {
            actions = [showHideAction]
        }
        return BottomMenuActionGroup(actions: actions)
    }
    
    var confirmDeleteMenu: BottomMenu {
        let title = BottomMenuAction(
            title: "This photo will be deleted while the data you filled from it will remain."
        )
        let deleteAction = BottomMenuAction(
            title: "Delete Photo",
            role: .destructive,
            tapHandler: {
                textPickerViewModel.deleteCurrentImage()
            })
        return BottomMenu(actions: [title, deleteAction])
    }
    
    var deletePhotoAction: BottomMenuAction {
        BottomMenuAction(
            title: "Delete Photo",
            systemImage: "trash",
            role: .destructive,
            linkedMenu: confirmDeleteMenu
        )
    }
    
    var bottomMenu: BottomMenu {
        BottomMenu(groups: [
            firstMenuGroup,
            BottomMenuActionGroup(action: deletePhotoAction)]
        )
    }
    
    func thumbnail(at index: Int) -> some View {
        var isSelected: Bool {
            textPickerViewModel.currentIndex == index
        }
        
        return Group {
            if let image = textPickerViewModel.imageViewModels[index].image {
                Button {
                    textPickerViewModel.didTapThumbnail(at: index)
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
//                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                                        .foregroundColor(.accentColor)
//                                        .padding(-0.5)
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
            textPickerViewModel.setInitialState()
        }
    }
    
    //MARK: - User Actions
    func toggleSelection(of imageText: ImageText) {
        if textPickerViewModel.selectedImageTexts.contains(imageText) {
            Haptics.feedback(style: .light)
            withAnimation {
                textPickerViewModel.selectedImageTexts.removeAll(where: { $0 == imageText })
            }
        } else {
            Haptics.feedback(style: .soft)
            withAnimation {
                textPickerViewModel.selectedImageTexts.append(imageText)
            }
        }
    }    
}
