import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct BottomMenuAction: Hashable, Equatable {
    let title: String
    let systemImage: String
    let action: () -> ()
    
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
            actionGroupSections
            cancelButton
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
            action.action()
            isPresented = false
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
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
//                        .padding()
                )
                .padding(.horizontal)
        }
    }
    
    func dismiss() {
        Haptics.feedback(style: .medium)
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
                BottomMenuAction(title: "Choose Photos", systemImage: "photo.on.rectangle", action: {
                    
                }),
                BottomMenuAction(title: "Take Photos", systemImage: "camera", action: {
                    
                })
            ],
            [
                BottomMenuAction(title: "Add a Link", systemImage: "link", action: {
                    
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
