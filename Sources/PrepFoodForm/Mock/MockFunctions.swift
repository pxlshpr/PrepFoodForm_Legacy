import SwiftUI
import NutritionLabelClassifier

func sampleImage(_ number: Int) -> UIImage? {
    guard let path = Bundle.module.path(forResource: "label\(number)", ofType: "jpg") else {
        return nil
    }
    return UIImage(contentsOfFile: path)
}

func sampleOutput(_ number: Int) -> Output? {
    guard let path = Bundle.module.path(forResource: "label\(number)", ofType: "json") else {
        return nil
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let output = try JSONDecoder().decode(Output.self, from: data)
        return output
    } catch {
        print(error)
        return nil
    }
}
