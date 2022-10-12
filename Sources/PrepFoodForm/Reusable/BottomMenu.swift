import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct BottomMenuAction: Hashable, Equatable {
    let title: String
    let systemImage: String
    let tapHandler: (() -> ())?
    
    let textInputHandler: ((String) -> ())?
    let textInputPlaceholder: String

    init(title: String, systemImage: String, tapHandler: (() -> Void)?) {
        self.title = title
        self.systemImage = systemImage
        self.tapHandler = tapHandler
        
        self.textInputHandler = nil
        self.textInputPlaceholder = ""
    }

    init(title: String, systemImage: String, placeholder: String = "", textInputHandler: ((String) -> Void)?) {
        self.title = title
        self.systemImage = systemImage
        self.tapHandler = nil
        
        self.textInputPlaceholder = placeholder
        self.textInputHandler = textInputHandler
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(systemImage)
    }
    
    public static func ==(lhs: BottomMenuAction, rhs: BottomMenuAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

public struct BottomMenuModifier: ViewModifier {
    
    @State var animatedIsPresented: Bool = false
    @State var actionToReceiveTextInputFor: BottomMenuAction? = nil
    @FocusState var isFocused: Bool
    
    @State var inputText: String = ""

    @Binding var isPresented: Bool
    let actionGroups: [[BottomMenuAction]]
    
    public func body(content: Content) -> some View {
        content
            .overlay(menuOverlay)
            .onChange(of: isPresented) { newValue in
                withAnimation(.interactiveSpring()) {
                    Haptics.feedback(style: .rigid)
                    animatedIsPresented = newValue
                }
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
                    .transition(.move(edge: .bottom))
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
            Text(action.title)
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity)
                .padding()
        }
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
            }
            
            /// If this has a text input handler—change the UI to be able to recieve text input
            if let textInputHandler = action.textInputHandler {
                withAnimation {
                    actionToReceiveTextInputFor = action
                }
                isFocused = true
            }
        } label: {
            HStack {
                Image(systemName: action.systemImage)
                    .imageScale(.large)
                    .frame(width: 50)
//                    .padding(.leading, 6)
//                    .padding(.trailing, 8)
                    .fontWeight(.medium)
                Text(action.title)
                    .font(.title3)
                    .fontWeight(.regular)
                Spacer()
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
        actionToReceiveTextInputFor = nil
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
                .bottomMenu(isPresented: $showingMenu, actionGroups: menuActionGroups)
                .interactiveDismissDisabled(showingMenu)
//            }
    }
    
    var menuActionGroups: [[BottomMenuAction]] {
        [
            [
                BottomMenuAction(title: "Choose Photos", systemImage: "photo.on.rectangle", tapHandler: {
                    
                }),
                BottomMenuAction(title: "Take Photos", systemImage: "camera", tapHandler: {
                    
                })
            ],
            [
                BottomMenuAction(
                    title: "Add a Link",
                    systemImage: "link",
                    placeholder: "https://fastfood.com/nutrition",
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
