import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension FoodForm.AmountPerForm.DensityForm {

    var fieldSection: some View {
        FormStyledSection {
            HStack {
                Spacer()
                if weightFirst {
                    weightStack
                } else {
                    volumeStack
                }
                Spacer()
                Text("↔")
                    .font(.title2)
                    .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                if weightFirst {
                    volumeStack
                } else {
                    weightStack
                }
                Spacer()
            }
        }
    }
    
    //MARK: - Weight
    var weightStack: some View {
        HStack {
            weightTextField
                .padding(.vertical, 5)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            weightUnitButton
                .background(showColors ? .red : .clear)
                .layoutPriority(2)
        }
        .background(showColors ? .brown : .clear)
    }
    
    var weightTextField: some View {
        let binding = Binding<String>(
            get: { field.value.weight.string },
            set: {
                if !doNotRegisterUserInput, focusedField == .weight, $0 != field.value.weight.string {
                    withAnimation {
                        field.registerUserInput()
                    }
                }
                field.value.weight.string = $0
            }
        )
        
        return TextField("weight", text: binding)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .font(.title2)
            .focused($focusedField, equals: .weight)
    }
    

    var weightUnitButton: some View {
        Button {
            showingWeightUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(field.value.weight.unitDescription)
//                    Image(systemName: "chevron.up.chevron.down")
//                        .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
    
    //MARK: - Volume
     
    var volumeStack: some View {
        HStack {
            volumeTextField
                .padding(.vertical, 5)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            volumeUnitButton
                .background(showColors ? .blue : .clear)
        }
        .background(showColors ? .pink : .clear)
    }
    
    var volumeTextField: some View {
        let binding = Binding<String>(
            get: { fields.density.value.volume.string },
            set: {
                if !doNotRegisterUserInput, focusedField == .volume, $0 != fields.density.value.volume.string {
                    withAnimation {
                        fields.density.registerUserInput()
                    }
                }
//                field.value.volume.string = $0
                fields.density.value.volume.string = $0
            }
        )
        
        return TextField("volume", text: binding)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .font(.title2)
            .focused($focusedField, equals: .volume)
    }
    
    var volumeUnitButton: some View {
        Button {
            showingVolumeUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(field.value.volume.unitDescription)
//                    Image(systemName: "chevron.up.chevron.down")
//                        .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
}
