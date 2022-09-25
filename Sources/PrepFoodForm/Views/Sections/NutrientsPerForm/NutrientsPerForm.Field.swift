import SwiftUI

extension FoodForm.NutrientsPerForm {
    struct Field: View {

        @EnvironmentObject var viewModel: FoodFormViewModel
        
        @State var showingAmountForm = false
        @State var showingServingForm = false
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
            showingAmountForm = true
        } label: {
            label(viewModel.amountDescription, placeholder: "Required")
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $showingAmountForm) {
            NavigationView {
                FoodForm.NutrientsPerForm.AmountForm()
                    .environmentObject(viewModel)
            }
        }
    }
    
    var servingButton: some View {
        Button {
            showingServingForm = true
        } label: {
            label(viewModel.servingDescription, placeholder: "serving size")
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $showingServingForm) {
            NavigationView {
                FoodForm.NutrientsPerForm.ServingForm()
                    .environmentObject(viewModel)
            }
        }
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
        viewModel.prefill()
    }
}
struct NutrientsPerFormField_Previews: PreviewProvider {
    static var previews: some View {
        NutrientsPerFormFieldPreview()
    }
}

