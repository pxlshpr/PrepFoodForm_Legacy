import SwiftUI
import FoodLabelScanner

func sampleImage(_ number: Int) -> UIImage? {
    guard let path = Bundle.module.path(forResource: "label\(number)", ofType: "jpg") else {
        return nil
    }
    return UIImage(contentsOfFile: path)
}

func sampleScanResult(_ number: Int) -> ScanResult? {
    guard let path = Bundle.module.path(forResource: "label\(number)", ofType: "json") else {
        return nil
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let scanResult = try JSONDecoder().decode(ScanResult.self, from: data)
        return scanResult
    } catch {
        print(error)
        return nil
    }
}
