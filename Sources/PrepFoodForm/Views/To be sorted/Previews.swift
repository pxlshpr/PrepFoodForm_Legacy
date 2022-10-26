import SwiftUI
import SwiftUISugar

public struct FillOptionSectionsPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    
    @State var string: String
    @State var shouldAnimate: Bool = true
    
    public init() {
        let viewModel = FoodFormViewModel.mock
        _viewModel = StateObject(wrappedValue: viewModel)
        _string = State(initialValue: viewModel.energyViewModel.fieldValue.energyValue.string)
    }
    
    var fieldSection: some View {
        Section("Enter or auto-fill a value") {
            HStack {
                TextField("Required", text: $string)
            }
        }
    }
    
    var optionsSections: some View {
        FillOptionsSections(fieldViewModel: viewModel.energyViewModel,
                           shouldAnimate: $shouldAnimate,
                           didTapImage: {
            
        }, didTapFillOption: { fillOption in
            
        })
        .environmentObject(viewModel)
    }
    
    public var scrollView: some View {
        FormStyledScrollView {
            fieldSection
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            optionsSections
        }
    }
    public var body: some View {
        NavigationView {
//            form
            scrollView
        }
        .onChange(of: viewModel.energyViewModel.fieldValue.energyValue.double) { newValue in
            string = newValue?.cleanAmount ?? ""
        }
        .onChange(of: string) { newValue in
            withAnimation {
                viewModel.energyViewModel.fieldValue.energyValue.fill = .userInput
            }
        }
    }
}

struct FillOptionSections_Previews: PreviewProvider {
    static var previews: some View {
        FillOptionSectionsPreview()
    }
}

struct FoodFormPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel()
    
    public init() {
        let viewModel = FoodFormViewModel.mock(for: .pumpkinSeeds)
        FoodFormViewModel.shared = viewModel
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        FoodForm_Legacy { foodFormData in
            
        }
        .environmentObject(viewModel)
    }
}

struct FoodForm_Previews: PreviewProvider {
    static var previews: some View {
        FoodFormPreview()
    }
}

public struct FillOptionsGridPreview: View {
    
    @StateObject var viewModel: FoodFormViewModel
    @State var string: String
    @State var fillOptions: [FillOption] = []
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
