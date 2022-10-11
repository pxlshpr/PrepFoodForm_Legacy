import SwiftUI
import SwiftHaptics
import SwiftUISugar

//MARK: Grid
struct FillOptionsGrid: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingImagePicker: Bool = false
    
    @ObservedObject var fieldViewModel: FieldViewModel
    @Binding var shouldAnimate: Bool
    
    var didTapFillOption: (FillOption) -> ()

    var body: some View {
        flowLayout
            .sheet(isPresented: $showingImagePicker) {
                Text("Image picker")
            }
    }
    
    var flowLayout: some View {
        FlowLayout(
            mode: .scrollable,
            items: viewModel.fillOptions(for: fieldViewModel.fieldValue),
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

//MARK: - Preview

public struct FillOptionsGridPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var string: String
    @State var fillOptions: [FillOption] = []
    @State var height: CGFloat = 200
    @State var shouldAnimate: Bool = true
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
        _string = State(initialValue: viewModel.energyViewModel.fieldValue.energyValue.string)
    }
    
    public var body: some View {
        NavigationView {
            NavigationLink {
                grid
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .foregroundColor(Color(.systemGroupedBackground))
                    )
                    .padding()
            } label: {
                Text("Link")
            }
            .navigationTitle("Grid")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            fillOptions = viewModel.fillOptions(for: viewModel.energyViewModel.fieldValue)
        }
    }
    
    var form: some View {
        Form {
            grid
        }
    }
    
    var grid: some View {
//        FillOptionsGrid(fieldValue: $viewModel.energy, fillOptions: $fillOptions)
        FillOptionsGrid(
            fieldViewModel: viewModel.energyViewModel,
            shouldAnimate: .constant(false)
        ) { fillOption in
            
        }
            .environmentObject(viewModel)
    }
    
    var navigationTrailingToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Add") {
                withAnimation {
                    addRandomFillOption()
                }
            }
            Button("Remove") {
                withAnimation {
                    fillOptions.removeLast(2)
                }
            }
        }
    }
    
    func addRandomFillOption() {
        fillOptions.append(
            FillOption(string: "Test\(Int.random(in: 0...1000))", systemImage: "face.smiling", isSelected: false, type: .fill(.userInput))
        )
    }
}

struct FillOptionsGrid_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionsGridPreview()
    }
}
