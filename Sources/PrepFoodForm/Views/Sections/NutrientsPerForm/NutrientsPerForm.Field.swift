import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct Field: View {

        @EnvironmentObject var viewModel: FoodFormViewModel
        
//        @State var showingAmountForm = false
//        @State var showingServingForm = false
    }
}

extension FoodForm.NutrientsPerForm.Field {
    
    var body: some View {
        HStack {
            Spacer()
            amountButton
            if viewModel.shouldShowServingInField {
                Spacer()
                Text("of")
                    .font(.title3)
                    .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                servingButton
                Spacer()
            }
        }
    }
    
    var amountButton: some View {
        Button {
            viewModel.showingNutrientsPerAmountForm = true
        } label: {
            label(viewModel.amountDescription, placeholder: "Required")
        }
        .buttonStyle(.borderless)
    }
    
    var servingButton: some View {
        Button {
            viewModel.showingNutrientsPerServingForm = true
        } label: {
            label(viewModel.servingDescription, placeholder: "serving size")
        }
        .buttonStyle(.borderless)
    }
    
    func label(_ string: String, placeholder: String) -> some View {
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
}

public struct NutrientsPerFormFieldPreview: View {
    
    @StateObject var viewModel = FoodFormViewModel.shared
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            Form {
                FoodForm.NutrientsPerForm.Field()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            populateData()
        }
    }
    
    func populateData() {
        viewModel.previewPrefill()
    }
}
struct NutrientsPerFormField_Previews: PreviewProvider {
    static var previews: some View {
        NutrientsPerFormFieldPreview()
    }
}

