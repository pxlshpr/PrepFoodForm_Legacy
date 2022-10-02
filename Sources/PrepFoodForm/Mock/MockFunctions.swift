import SwiftUI
import FoodLabelScanner
import MFPScraper

func sampleImage(_ number: Int) -> UIImage? {
    guard let path = Bundle.module.path(forResource: "label\(number)", ofType: "jpg") else {
        return nil
    }
    return UIImage(contentsOfFile: path)
}

func sampleScanResult(_ number: Int) -> ScanResult? {
    guard let path = Bundle.module.path(forResource: "scanResult\(number)", ofType: "json") else {
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

func sampleMFPProcessedFood(_ number: Int) -> MFPProcessedFood? {
    guard let path = Bundle.module.path(forResource: "mfpProcessedFood\(number)", ofType: "json") else {
        return nil
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let mfpProcessedFood = try JSONDecoder().decode(MFPProcessedFood.self, from: data)
        return mfpProcessedFood
    } catch {
        print(error)
        return nil
    }
}
