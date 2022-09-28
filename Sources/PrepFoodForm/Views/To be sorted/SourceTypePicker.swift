import SwiftUI
import CameraImagePicker

struct SourceTypePicker: View {
    
    enum Route {
        case camera
        case search
        case linkForm
    }
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var showingCamera = false
    @State var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            list
            .listStyle(.insetGrouped)
            .navigationTitle("Sources")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                navigationDestination(for: route)
            }
            .sheet(isPresented: $showingCamera) {
                CameraImagePicker(maxSelectionCount: 5, delegate: viewModel)
                    .onDisappear {
                        dismiss()
                    }
            }
        }
    }
    
    @ViewBuilder
    func navigationDestination(for route: Route) -> some View {
        switch route {
        case .camera:
            CameraImagePicker(maxSelectionCount: 5, delegate: viewModel)
        case .search:
            Text("Search")
        case .linkForm:
            Text("Link Form")
        }
    }
    
    var list: some View {
        List {
            ForEach(SourceType.nonManualSources, id: \.self) { sourceType in
                Section(footer: Text(sourceType.footerString)) {
                    NavigationLinkButton {
                        switch sourceType {
                        case .images:
                            showingCamera = true
                        default:
                            return
                        }
                    } label: {
                        Label(sourceType.actionString, systemImage: sourceType.systemImage)
                    }
                    .buttonStyle(.borderless)

//                    Button {
//                        withAnimation {
//                            FoodFormViewModel.shared.sourceType = sourceType
//                        }
//                        dismiss()
//                    } label: {
//                        Label(sourceType.actionString, systemImage: sourceType.systemImage)
//                    }
//                    .buttonStyle(.borderless)
                }
            }
        }
    }
}
