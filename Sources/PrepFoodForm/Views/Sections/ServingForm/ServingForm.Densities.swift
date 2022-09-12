import SwiftUI

extension FoodForm.ServingForm {
    struct DensitiesForm: View {
        
    }
}

extension FoodForm.ServingForm.DensitiesForm {
    var body: some View {
        Form {
            densitySection
            volumesSection
        }
    }
    
    var densitySection: some View {
        var header: some View {
            Text("Primary Density")
        }
        
        var footer: some View {
            Text("Setting a primary density will let you log this food with its volume as well.")
        }
        
        return Section(header: header, footer: footer) {
            NavigationLink {
                Text("Density Form")
            } label: {
                Text("Optional")
                    .foregroundColor(Color(.quaternaryLabel))
            }
        }
    }


    var volumesSection: some View {
        
        var header: some View {
            Text("Alternate Densities")
        }
        
        var footer: some View {
            Text("These will let you log volumes of this food in other densities – like ‘cups, shredded’ or ‘tbsp, sliced’.")
        }
        
        return Section(header: header, footer: footer) {
            Button {
                
            } label: {
                Text("Add an alternate density")
            }
//            NavigationLink {
//                FoodForm.NutrientsPerForm.SizesList()
//            } label: {
//                Text("Volumes")
//            }
        }
    }

}
