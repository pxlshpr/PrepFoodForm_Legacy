import SwiftUI
import FoodLabelScanner
import MFPScraper

func sampleImage(_ number: Int) -> UIImage? {
    sampleImage(imageFilename: "label\(number)")
}

func sampleImage(imageFilename: String) -> UIImage? {
    guard let path = Bundle.module.path(forResource: imageFilename, ofType: "jpg") else {
        return nil
    }
    return UIImage(contentsOfFile: path)
}

func sampleScanResult(_ number: Int) -> ScanResult? {
    sampleScanResult(jsonFilename: "scanResult\(number)")
}

func sampleScanResult(jsonFilename: String) -> ScanResult? {
    guard let path = Bundle.module.path(forResource: jsonFilename, ofType: "json") else {
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
    sampleMFPProcessedFood(jsonFilename: "mfpProcessedFood\(number)")
}

func sampleMFPProcessedFood(jsonFilename: String) -> MFPProcessedFood? {
    guard let path = Bundle.module.path(forResource: jsonFilename, ofType: "json") else {
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
