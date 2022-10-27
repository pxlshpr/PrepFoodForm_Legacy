import SwiftUI
import SwiftHaptics

struct TextPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var textPickerViewModel: TextPickerViewModel
    @State var pickedColumn: Int = 1
    
    init(imageViewModels: [ImageViewModel], mode: TextPickerMode) {
        let viewModel = TextPickerViewModel(
            imageViewModels: imageViewModels,
            mode: mode
        )
        _textPickerViewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            pagerLayer
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
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            textPickerViewModel.setInitialState()
        }
    }
    
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
