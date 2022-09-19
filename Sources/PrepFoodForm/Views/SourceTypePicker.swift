import SwiftUI

struct SourceTypePicker: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            list
            .listStyle(.insetGrouped)
            .navigationTitle("Pick a Source")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var list: some View {
        List {
            ForEach(SourceType.nonManualSources, id: \.self) { sourceType in
                Section(footer: Text(sourceType.footerString)) {
                    Button {
                        withAnimation {
                            FoodFormViewModel.shared.sourceType = sourceType
                        }
                        dismiss()
                    } label: {
                        Label(sourceType.actionString, systemImage: sourceType.systemImage)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}
