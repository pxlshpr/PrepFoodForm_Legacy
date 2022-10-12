import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct BottomMenuAction: Hashable, Equatable {
    let title: String
    let systemImage: String?
    let role: ButtonRole
    let tapHandler: (() -> ())?
    
    let textInputHandler: ((String) -> ())?
    let textInputIsValid: ((String) -> Bool)?
    let textInputSubmitString: String
    let textInputPlaceholder: String
    let textInputKeyboardType: UIKeyboardType
    let textInputAutocapitalization: TextInputAutocapitalization

    init(title: String, systemImage: String? = nil, role: ButtonRole = .cancel, tapHandler: (() -> Void)?) {
        self.title = title
        self.systemImage = systemImage
        self.tapHandler = tapHandler
        self.role = role
        
        self.textInputHandler = nil
        self.textInputIsValid = nil
        self.textInputPlaceholder = ""
        self.textInputSubmitString = ""
        self.textInputKeyboardType = .default
        self.textInputAutocapitalization = .sentences
    }

    init(
        title: String,
        systemImage: String? = nil,
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        submitString: String = "",
        autocapitalization: TextInputAutocapitalization = .sentences,
        textInputIsValid: ((String) -> Bool)? = nil,
        textInputHandler: ((String) -> Void)?
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tapHandler = nil
        self.role = .cancel

        self.textInputPlaceholder = placeholder
        self.textInputSubmitString = submitString
        self.textInputIsValid = textInputIsValid
        self.textInputHandler = textInputHandler
        self.textInputKeyboardType = keyboardType
        self.textInputAutocapitalization = autocapitalization
    }
    
    enum ActionType {
        case button, textField
    }
    
    var type: ActionType {
        self.textInputHandler == nil ? .button : .textField
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

public struct BottomMenuModifier: ViewModifier {
    
    @State var animatedIsPresented: Bool = false
    @FocusState var isFocused: Bool
    @State var inputText: String = ""

    @Binding var isPresented: Bool
    let actionGroups: [[BottomMenuAction]]
    @State var actionToReceiveTextInputFor: BottomMenuAction?

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

    var backgroundLayer: some View {
        Color(.quaternarySystemFill)
            .background (
                .ultraThinMaterial
            )
            .onTapGesture {
                dismiss()
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
    
    var buttonsLayer: some View {
        VStack(spacing: 10) {
            Spacer()
            if let actionToReceiveTextInputFor {
                inputSections(for: actionToReceiveTextInputFor)
                    .transition(.move(edge: .leading))
            } else {
                actionGroupSections
                    .transition(.move(edge: .trailing))
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
    
    func submitTextButton(for action: BottomMenuAction) -> some View {
        Button {
            if let textInputHandler = action.textInputHandler {
                textInputHandler(inputText)
            }
            dismiss()
        } label: {
            Text(action.textInputSubmitString)
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .disabled(shouldDisableSubmitButton)
    }
    
    var shouldDisableSubmitButton: Bool {
        guard let textInputIsValid = actionToReceiveTextInputFor?.textInputIsValid else {
            return false
        }
        return !textInputIsValid(inputText)
    }
    
    func inputSections(for action: BottomMenuAction) -> some View {
        VStack(spacing: 0) {
            TextField(
                text: $inputText,
                prompt: Text(verbatim: action.textInputPlaceholder),
                axis: .vertical
            ) { }
                .focused($isFocused)
                .padding()
                .keyboardType(action.textInputKeyboardType)
                .textInputAutocapitalization(action.textInputAutocapitalization)
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
    
    func actionGroup(for actions: [BottomMenuAction]) -> some View {
        VStack(spacing: 0) {
            ForEach(actions.indices, id: \.self) { index in
                if index != 0 {
                    Divider()
                        .padding(.leading, 75)
                }
                actionButton(for: actions[index])
            }
        }
    }
    
    func actionButton(for action: BottomMenuAction) -> some View {
        Button {
            /// If this action has a tap handler, handle it and dismiss
            if let tapHandler = action.tapHandler {
                tapHandler()
                dismiss()
            } else if let _ = action.textInputHandler {
                /// If this has a text input handler—change the UI to be able to recieve text input
                withAnimation {
                    actionToReceiveTextInputFor = action
                }
                isFocused = true
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
    
    func dismiss() {
        Haptics.feedback(style: .medium)
        isFocused = false
        /// Reset `actionToReceiveTextInputFor` to nil only if the action groups has other actions besides the one expecting input
        if actionGroups.singleTextInputAction != nil {
            actionToReceiveTextInputFor = nil
        }
        inputText = ""
        isPresented = false
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
    @State var showingMenu: Bool = false
    public init() { }
    
    public var body: some View {
//        Color.blue
//            .edgesIgnoringSafeArea(.all)
//            .sheet(isPresented: .constant(true)) {
                NavigationView {
                    ZStack {
                        Button("Menu") {
                            showingMenu = true
                        }
                    }
                    .navigationTitle("Form")
                }
                .bottomMenu(isPresented: $showingMenu, actionGroups: removeAllImagesActionGroups)
                .interactiveDismissDisabled(showingMenu)
//            }
    }

    var menuActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(
                    title: "Add a Link",
                    systemImage: "link",
                    placeholder: "https://fastfood.com/nutrition",
                    submitString: "Add Link",
                    textInputHandler: { string in
                    print("Got back: \(string)")
                })
            ]
        ]
    }

    var removeAllImagesActionGroups: [[BottomMenuAction]] {
        [[
            BottomMenuAction(
                title: "Remove All Images",
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
                    placeholder: "https://fastfood.com/nutrition",
                    submitString: "Add Link",
                    textInputHandler: { string in
                    print("Got back: \(string)")
                })
            ]
        ]
    }
}

struct BottomMenu_Previews: PreviewProvider {
    static var previews: some View {
        BottomMenuPreview()
    }
}
