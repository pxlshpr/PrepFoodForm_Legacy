import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct Field: View {

        @EnvironmentObject var viewModel: FoodForm.ViewModel
        
    }
}

extension FoodForm.NutrientsPerForm.Field {
    var body: some View {
        HStack {
            Spacer()
            button(viewModel.amountDescription, placeholder: "Required") {
                viewModel.path.append(.amountForm)
            }
            if viewModel.shouldShowServingInField {
                Spacer()
                Text("of")
                    .font(.title3)
                    .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                button(viewModel.servingDescription, placeholder: "serving size") {
                    viewModel.path.append(.servingForm)
                }
                Spacer()
            }
        }
    }
    
    func button(_ string: String, placeholder: String = "", action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Group {
                if string.isEmpty {
                    HStack(spacing: 5) {
                        Text(placeholder)
                            .foregroundColor(Color(.quaternaryLabel))
                    }
                } else {
                    Text(string)
                }
            }
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}

public struct NutrientsPerFormFieldPreview: View {
    
    @StateObject var viewModel = FoodForm.ViewModel(prefilledWithMockData: true)
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            Form {
                FoodForm.NutrientsPerForm.Field()
                    .environmentObject(viewModel)
            }
        }
    }
    
    func populateData() {
    }
}
struct NutrientsPerFormField_Previews: PreviewProvider {
    static var previews: some View {
        NutrientsPerFormFieldPreview()
    }
}

