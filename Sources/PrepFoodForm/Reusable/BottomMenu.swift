import SwiftUI
import SwiftUISugar
import SwiftHaptics

//MARK: - Array + BottomMenuAction
extension Array where Element == BottomMenuAction {
    var title: BottomMenuAction? {
        guard let first, first.type == .title else {
            return nil
        }
        return first
    }
    
    var withoutTitle: [BottomMenuAction] {
        filter { $0.type != .title }
    }
}

enum ActionType {
    case button, textField, title, link
}

//MARK: - BottomMenuAction

public struct BottomMenuTextInput {
    let handler: ((String) -> ())
    let isValid: ((String) -> Bool)?
    let placeholder: String
    let keyboardType: UIKeyboardType
    let submitString: String
    let autocapitalization: TextInputAutocapitalization

    init(
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        submitString: String = "",
        autocapitalization: TextInputAutocapitalization = .sentences,
        textInputIsValid: ((String) -> Bool)? = nil,
        textInputHandler: @escaping ((String) -> Void)
    ) {
        self.placeholder = placeholder
        self.submitString = submitString
        self.isValid = textInputIsValid
        self.handler = textInputHandler
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }
}

public struct BottomMenuAction: Hashable, Equatable {
    let title: String
    let systemImage: String?
    let role: ButtonRole
    let tapHandler: (() -> ())?
    let textInput: BottomMenuTextInput?
    let linkedActionGroups: [[BottomMenuAction]]?

    init(title: String, systemImage: String? = nil, role: ButtonRole = .cancel, tapHandler: (() -> Void)? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.tapHandler = tapHandler
        self.role = role
        self.textInput = nil
        self.linkedActionGroups = nil
    }

    init(title: String, systemImage: String? = nil, role: ButtonRole = .cancel, linkedActionGroups: [[BottomMenuAction]]) {
        self.title = title
        self.systemImage = systemImage
        self.tapHandler = nil
        self.role = role
        self.textInput = nil
        self.linkedActionGroups = linkedActionGroups
    }

    init(title: String, systemImage: String? = nil, textInput: BottomMenuTextInput) {
        self.title = title
        self.systemImage = systemImage
        self.role = .cancel
        self.textInput = textInput
        
        self.tapHandler = nil
        self.linkedActionGroups = nil
    }
    
    var type: ActionType {
        if linkedActionGroups != nil {
            return .link
        }
        
        if textInput == nil {
            if tapHandler == nil {
                return .title
            } else {
                return .button
            }
        } else {
            return .textField
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(systemImage)
    }
    
    public static func ==(lhs: BottomMenuAction, rhs: BottomMenuAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension Array where Element == [BottomMenuAction] {
    var singleTextInputAction: BottomMenuAction? {
        guard count == 1,
              self[0].count == 1,
              let action = first?.first,
              action.type == .textField
        else {
            return nil
        }
        return action
    }
}

//MARK: - BottomMenuModifier

public struct BottomMenuModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    @State var animatedIsPresented: Bool = false
    @FocusState var isFocused: Bool
    @State var inputText: String = ""

    @Binding var isPresented: Bool
    let actionGroups: [[BottomMenuAction]]
    @State var actionToReceiveTextInputFor: BottomMenuAction?
    @State var linkedActions: [[BottomMenuAction]]?

    @State var menuTransition: AnyTransition = .move(edge: .bottom)
    
    init(isPresented: Binding<Bool>, actionGroups: [[BottomMenuAction]]) {
        _isPresented = isPresented
        self.actionGroups = actionGroups
        
        /// If we only have one action group that takes a text input—set it straight away so the user can input the text
        if let singleTextInputAction = actionGroups.singleTextInputAction {
            _actionToReceiveTextInputFor = State(initialValue: singleTextInputAction)
        } else {
            _actionToReceiveTextInputFor = State(initialValue: nil)
        }
    }
    
    public func body(content: Content) -> some View {
        content
//            .blur(radius: animatedIsPresented ? 5 : 0)
            .overlay(menuOverlay)
            .onChange(of: isPresented) { newValue in
                if newValue {
                    resetForNextPresentation()
                }

                withAnimation(.interactiveSpring()) {
                    Haptics.feedback(style: .rigid)
                    animatedIsPresented = newValue
                }
            }
            .onAppear {
                if actionToReceiveTextInputFor != nil && !isFocused {
                    isFocused = true
                }
            }
    }
    
    var menuOverlay: some View {
        ZStack {
            if animatedIsPresented {
                backgroundLayer
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
            if animatedIsPresented {
                buttonsLayer
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    //MARK: - Layers

    var backgroundLayer: some View {
        Color(.black)
            .opacity(colorScheme == .dark ? 0.6 : 0.4)
//        Color(.quaternarySystemFill)
//            .background (.ultraThinMaterial)
            .onTapGesture {
                dismiss()
            }
    }
    
    var actionGroupTransition: AnyTransition {
        if linkedActions != nil {
            return .move(edge: .leading)
        } else {
            return .move(edge: .bottom)
        }
    }
    var buttonsLayer: some View {
        VStack(spacing: 10) {
            Spacer()
            if let textInput = actionToReceiveTextInputFor?.textInput {
                inputSections(for: textInput)
                    .transition(.move(edge: .trailing))
            } else if let linkedActions {
                linkedActionGroupSections(for: linkedActions)
                    .transition(.move(edge: .trailing))
            } else {
                actionGroupSections
//                    .transition(actionGroupTransition)
                    .transition(menuTransition)
            }
            VStack(spacing: 0) {
                if let actionToReceiveTextInputFor {
                    Group {
                        submitTextButton(for: actionToReceiveTextInputFor)
                        Divider()
                    }
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                }
                cancelButton
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(Color(.secondarySystemGroupedBackground))
            )
            .padding(.bottom)
            .padding(.horizontal)
        }
    }
    
    //MARK: - Sections
    
    func inputSections(for textInput: BottomMenuTextInput) -> some View {
        VStack(spacing: 0) {
            TextField(
                text: $inputText,
                prompt: Text(verbatim: textInput.placeholder),
                axis: .vertical
            ) { }
                .focused($isFocused)
                .padding()
                .keyboardType(textInput.keyboardType)
                .textInputAutocapitalization(textInput.autocapitalization)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.5))
                        .background (
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .foregroundColor(Color(.systemBackground))
                        )
                )
                .frame(maxWidth: .infinity)
                .padding(7)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.2))
                        .background (
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color(.systemGroupedBackground))
                        )
                )
                .padding(.horizontal)
        }
    }
    
    var actionGroupSections: some View {
        ForEach(actionGroups, id: \.self) {
            actionGroup(for: $0)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                )
                .padding(.horizontal)
        }
    }

    func linkedActionGroupSections(for actionGroups: [[BottomMenuAction]]) -> some View {
        ForEach(actionGroups, id: \.self) {
            actionGroup(for: $0)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                )
                .padding(.horizontal)
        }
    }

    func actionGroup(for actions: [BottomMenuAction]) -> some View {
        VStack(spacing: 0) {
            if let title = actions.title {
                titleButton(for: title)
            }
            ForEach(actions.withoutTitle.indices, id: \.self) { index in
                if index != 0 {
                    Divider()
                        .padding(.leading, 75)
                }
                actionButton(for: actions.withoutTitle[index])
            }
        }
    }
    
    //MARK: - Buttons
    
    func submitTextButton(for action: BottomMenuAction) -> some View {
        Button {
            if let textInputHandler = action.textInput?.handler {
                textInputHandler(inputText)
            }
            dismiss()
        } label: {
            Text(action.textInput?.submitString ?? "Submit")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .disabled(shouldDisableSubmitButton)
    }
    
    func titleButton(for action: BottomMenuAction) -> some View {
        VStack(spacing: 0) {
            Text(action.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            Divider()
        }
    }
    
    func actionButton(for action: BottomMenuAction) -> some View {
        Button {
            /// If this action has a tap handler, handle it and dismiss
            if let tapHandler = action.tapHandler {
                tapHandler()
                dismiss()
            } else if action.type == .textField {
                /// If this has a text input handler—change the UI to be able to recieve text input
                Haptics.transientHaptic()
                withAnimation {
                    actionToReceiveTextInputFor = action
                }
                isFocused = true
            } else if action.type == .link, let linkedActions = action.linkedActionGroups {
                Haptics.transientHaptic()
                menuTransition = .move(edge: .leading)
                withAnimation {
                    self.linkedActions = linkedActions
                }
            }
        } label: {
            HStack {
                if let systemImage = action.systemImage {
                    Image(systemName: systemImage)
                        .imageScale(.large)
                        .frame(width: 50)
                        .fontWeight(.medium)
                        .foregroundColor(action.role == .destructive ? .red : .accentColor)
                }
                Text(action.title)
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundColor(action.role == .destructive ? .red : .accentColor)
                if action.systemImage != nil {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
    
    var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    //MARK: - Actions
    
    func resetForNextPresentation() {
        if let singleTextInputAction = actionGroups.singleTextInputAction {
            actionToReceiveTextInputFor = singleTextInputAction
        } else {
            actionToReceiveTextInputFor = nil
        }
        if actionToReceiveTextInputFor != nil && !isFocused {
            isFocused = true
        }
    }
    
    func dismiss() {
//        Haptics.feedback(style: .soft)
        isFocused = false
        /// Reset `actionToReceiveTextInputFor` to nil only if the action groups has other actions besides the one expecting input
        if actionGroups.singleTextInputAction != nil {
            actionToReceiveTextInputFor = nil
        }
        /// Do this after a delay so that setting it to nil doesn't make the the initial menu pop up during the dismissal animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            linkedActions = nil
            menuTransition = .move(edge: .bottom)
        }
        inputText = ""
        isPresented = false
    }
    
    //MARK: - Helpers
    
    var shouldDisableSubmitButton: Bool {
        guard let textInputIsValid = actionToReceiveTextInputFor?.textInput?.isValid else {
            return false
        }
        return !textInputIsValid(inputText)
    }
}

//MARK: - View+Modifier

public extension View {
    func bottomMenu(isPresented: Binding<Bool>, actionGroups: [[BottomMenuAction]]) -> some View {
        self.modifier(BottomMenuModifier(isPresented: isPresented, actionGroups: actionGroups))
    }
}

//MARK: - Preview

public struct BottomMenuPreview: View {
    @State var showingMenu: Bool = true
    @Environment(\.colorScheme) var colorScheme
    @State var image: UIImage?
    public init() {
        _image = State(initialValue: sampleImage(imageFilename: "screenshot-light", type: "png"))
    }
    
    public var body: some View {
        Group {
//            Color.green
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .bottomMenu(isPresented: .constant(true), actionGroups: linkedActionGroup)
    }

    var menuActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(
                    title: "Add a Link",
                    systemImage: "link",
                    textInput: BottomMenuTextInput(
                        placeholder: "https://fastfood.com/nutrition",
                        submitString: "Add Link",
                        textInputHandler: { string in
                            print("Got back: \(string)")
                        }
                    )
                )
            ]
        ]
    }

    var linkedActionGroup: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "AutoFill",
                systemImage: "text.viewfinder",
                linkedActionGroups: confirmActionGroup
            )
        ]]
    }
    
    var confirmActionGroup: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "This will replace any existing data."
            ),
            BottomMenuAction(
                title: "AutoFill",
                tapHandler: {
                }
            )
        ]]
    }

    var removeAllImagesActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "Remove All Photos",
//                systemImage: "trash",
                role: .destructive,
                tapHandler: {
                }
            )
        ]]
    }

    var menuActionGroups2: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Choose Photos", systemImage: "photo.on.rectangle", tapHandler: {
                    
                }),
                BottomMenuAction(title: "Take Photo", systemImage: "camera", tapHandler: {
                    
                })
            ],
            [
                BottomMenuAction(
                    title: "Add a Link",
                    systemImage: "link",
                    textInput: BottomMenuTextInput(
                        placeholder: "https://fastfood.com/nutrition",
                        submitString: "Add Link",
                        textInputHandler: { string in
                            print("Got back: \(string)")
                        }
                    )
                )
            ]
        ]
    }
}

struct BottomMenu_Previews: PreviewProvider {
    static var previews: some View {
        BottomMenuPreview()
    }
}
