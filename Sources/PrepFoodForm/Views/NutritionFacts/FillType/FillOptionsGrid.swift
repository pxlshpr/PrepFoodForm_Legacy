import SwiftUI
import SwiftHaptics
import SwiftUISugar

//MARK: Grid
struct FillOptionsGrid: View {
    
    @EnvironmentObject var viewModel: FoodFormViewModel
    @State var showingImagePicker: Bool = false
    
    @Binding var fieldValue: FieldValue
    
//    @Binding var fillOptions: [FillOption]
//    init(fieldValue: Binding<FieldValue>, fillOptions: Binding<[FillOption]>) {
//        _fieldValue = fieldValue
//        _fillOptions = fillOptions
//    }

    var body: some View {
        //        gridLayout
        flowLayout
            .sheet(isPresented: $showingImagePicker) {
                Text("Image picker")
            }
    }
    
    var gridLayout: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 100))],
            alignment: .center,
            spacing: 16
        ) {
            ForEach(viewModel.fillOptions(for: fieldValue), id: \.self) {
                fillOptionButton(for: $0)
            }
        }
    }
    
    var flowLayout: some View {
        FlowLayout(
            mode: .scrollable,
            items: viewModel.fillOptions(for: fieldValue),
            itemSpacing: 4
        ) { fillOption in
            fillOptionButton(for: fillOption)
        }
    }
    
    func fillOptionButton(for fillOption: FillOption) -> some View {
        FillOptionButton(fillOption: fillOption) {
            switch fillOption.type {
            case .chooseText:
                Haptics.feedback(style: .soft)
            case .fillType(let fillType):
                Haptics.feedback(style: .rigid)
                //TODO: DOn't show animation if we're not changing grid contents—or at least don't let image flicker
                withAnimation {
                    fieldValue.fillType = fillType
                    switch fillType {
                    case .imageSelection(let text, _, _, _):
                        //TODO: Attach a value to the nonAlt selections too—we need to get a Value from the recognizedText and store it in the FillOption to set it here
                        break
                    case .imageAutofill(let valueText, _, _):
                        fieldValue.double = valueText.value.amount
                        //TODO; Change unit too
                        fieldValue.nutritionUnit = valueText.value.unit
                        break
                    default:
                        break
                    }
                }
            }
        }
        .buttonStyle(.borderless)
    }
}

public struct FillOptionsGridPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var string: String
    @State var fillOptions: [FillOption] = []
    @State var height: CGFloat = 200
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
        _string = State(initialValue: viewModel.energy.energyValue.string)
    }
    
    public var body: some View {
        NavigationView {
            grid
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .foregroundColor(Color(.systemGroupedBackground))
                )
                .padding()
                .toolbar {
                    navigationTrailingToolbar
                }
                .onAppear {
                    fillOptions = viewModel.fillOptions(for: viewModel.energy)
                }
        }
    }
    
    var form: some View {
        Form {
            grid
        }
    }
    
    var grid: some View {
//        FillOptionsGrid(fieldValue: $viewModel.energy, fillOptions: $fillOptions)
        FillOptionsGrid(fieldValue: $viewModel.energy)
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
            FillOption(string: "Test\(Int.random(in: 0...1000))", systemImage: "face.smiling", isSelected: false, type: .fillType(.userInput))
        )
    }
}

struct FillOptionsGrid_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionsGridPreview()
    }
}
