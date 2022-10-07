//import SwiftUI
//import SwiftHaptics
//
//class SizeFormViewModel_Legacy: ObservableObject {
//
//    //TODO: Remove this
//    @Published var path: [Route] = []
//
//    //TODO: Use the FieldValueViewModel instead of these (having a copy of it for the form and keeping the original for when user's are editing or if we're cancelling the creation)
//    @Published var name: String
//    
//    @Published var quantityString: String
//    
//    @Published var amountString: String
//    
//    @Published var amountUnit: FormUnit
//
//    @Published var showingVolumePrefix: Bool {
//        didSet {
//            updateFormState()
//        }
//    }
//    @Published var volumePrefixUnit: FormUnit
//    
//    //TODO: Why are we storing this?
//    @Published var quantity: Double = 1
//    
//    //TODO: Keep this here and use it as a SizeFormViewModel if need be
//    @Published var includeServing: Bool
//    @Published var allowAddSize: Bool
//    @Published var formState: FormState
//
//    let existingSize: Size?
//    
//    init(includeServing: Bool = true, allowAddSize: Bool = true, existingSize: Size? = nil) {
//        self.includeServing = includeServing
//        self.allowAddSize = allowAddSize
//        
//        self.existingSize = existingSize
//        self.formState = existingSize == nil ? .empty : .noChange
//        self.name = existingSize?.name ?? ""
//        self.quantityString = existingSize?.quantityString ?? "1"
//        self.amountString = existingSize?.amountString ?? ""
//        self.amountUnit = existingSize?.unit ?? .weight(.g)
//        self.quantity = existingSize?.quantity ?? 1
//        
//        if let volumePrefixUnit = existingSize?.volumePrefixUnit {
//            showingVolumePrefix = true
//            self.volumePrefixUnit = volumePrefixUnit
//        } else {
//            showingVolumePrefix = false
//            self.volumePrefixUnit = .volume(.cup)
//        }
//    }
//    
//    var size: Size? {
//        guard let amount else {
//            return nil
//        }
//        let shouldSaveVolumePrefix = amountUnit.unitType == .weight && showingVolumePrefix
//        return Size(
//            quantity: quantity,
//            quantityString: quantity.cleanAmount,
//            volumePrefixUnit: shouldSaveVolumePrefix ? volumePrefixUnit : nil,
//            name: name,
//            amount: amount,
//            amountString: amount.cleanAmount,
//            unit: amountUnit
//        )
//    }
//    
//    func updateFormState() {
//        let newFormState = getFormState()
//        guard self.formState != newFormState else {
//            return
//        }
//        
//        let animation = Animation.interpolatingSpring(
//            mass: 0.5,
//            stiffness: 220,
//            damping: 10,
//            initialVelocity: 2
//        )
//
//        withAnimation(animation) {
////        withAnimation(.easeIn(duration: 4)) {
//            self.formState = getFormState()
//            print("Updated form state from \(self.formState) to \(newFormState)")
//
//            switch formState {
//            case .okToSave:
//                Haptics.successFeedback()
//            case .invalid:
//                Haptics.errorFeedback()
//            case .duplicate:
//                Haptics.warningFeedback()
//            default:
//                break
//            }
//        }
//    }
//    
//    func getFormState() -> FormState {
//        
//        let volumePrefixUnit = showingVolumePrefix ? self.volumePrefixUnit : nil
//        if FoodFormViewModel.shared.containsSize(withName: nameFieldString, andVolumePrefixUnit: volumePrefixUnit, ignoring: existingSize) {
//            return .duplicate
//        }
//
//        guard !amountString.isEmpty, let _ = amount else {
//            return .invalid(message: "Amount cannot be empty")
//        }
//        guard !name.isEmpty else {
//            return .invalid(message: "Name cannot be empty")
//        }
//        guard quantity > 0 else {
//            return .invalid(message: "Quantity has to be greater than 0")
//        }
//        
//        if let size {
//            if let existingSize {
//                if size == existingSize {
//                    return .noChange
//                }
//            }
//        }
//
//        return .okToSave
//    }
//    
//    var amountIsValid: Bool {
//        guard let amount = amount, amount > 0 else {
//            return false
//        }
//        return true
//    }
//    
//    var amount: Double? {
//        Double(amountString) ?? 0
//    }
//    
//    var nameFieldString: String {
//        guard !name.isEmpty else {
//            return ""
//        }
//        return name
//    }
//    
//    var amountFieldString: String {
//        guard let amount = amount, amountIsValid else {
//            return ""
//        }
//        
//        return "\(amount.cleanAmount) \(amountUnit.shortDescription)"
//    }
//}
