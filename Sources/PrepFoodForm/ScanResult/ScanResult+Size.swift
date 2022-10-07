//import FoodLabelScanner
//
//extension ScanResult {
//    
//    var equivalentSizes: [Size] {
//        if let equivalentSizeUnitNameText = serving.equivalentSize?.unitNameText {
//            let size2 = Size(
//                name: equivalentSizeUnitNameText.string,
//                amount: 1.0/servingAmount/equivalentSize.amount,
//                unit: .serving)
//            size = Size(
//                name: unitNameText.string,
//                amount: equivalentSize.amount,
//                unit: .size(size2, nil))
//            sizesToAdd = [size, size2]
//        } else {
//            let unit = equivalentSize.unit?.formUnit ?? .weight(.g)
//            size = Size(
//                name: unitNameText.string,
//                amount: equivalentSize.amount,
//                unit: unit)
//            sizesToAdd = [size]
//        }
//    }
//}
