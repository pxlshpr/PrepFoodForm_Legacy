import SwiftUI
import SwiftHaptics
import SwiftUISugar

//MARK: Grid
struct FillOptionsGrid: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingImagePicker: Bool = false
    
    @ObservedObject var fieldViewModel: Field
    @Binding var shouldAnimate: Bool
    
    var didTapFillOption: (FillOption) -> ()

    var body: some View {
        flowLayout
            .sheet(isPresented: $showingImagePicker) {
                Text("Image picker")
            }
    }
    
    var dummyFillOptions: [FillOption] {
        [
            FillOption(string: "Test1", systemImage: "face.smiling", isSelected: true, type: .fill(.userInput)),
            FillOption(string: "Test2", systemImage: "face.smiling", isSelected: false, type: .fill(.userInput))
        ]
    }
    
    var flowLayout: some View {
        FlowLayout(
            mode: .scrollable,
//            items: dummyFillOptions,
            items: viewModel.fillOptions(for: fieldViewModel.value),
            itemSpacing: 4,
            shouldAnimateHeight: $shouldAnimate
        ) { fillOption in
            fillOptionButton(for: fillOption)
        }
    }
    
    func fillOptionButton(for fillOption: FillOption) -> some View {
        FillOptionButton(fillOption: fillOption) {
            didTapFillOption(fillOption)
        }
        .buttonStyle(.borderless)
    }    
}
