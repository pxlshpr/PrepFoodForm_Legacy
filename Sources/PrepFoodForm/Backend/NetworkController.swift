import Foundation

class NetworkController {
    
    static var shared = NetworkController()
    
    func postRequest(forImageViewModel imageViewModel: ImageViewModel) -> URLRequest? {
        guard let imageData = imageViewModel.imageData else { return nil }
        return postRequest(forImageData: imageData, imageId: imageViewModel.id)
    }
    
    func postRequest(forImageData imageData: Data, imageId: UUID) -> URLRequest {
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: URL(string: "http://127.0.0.1:8080/foods/image")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()

        let formFields = ["id": imageId.uuidString]

        for (key, value) in formFields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }

        httpBody.append(convertFileData(fieldName: "data",
                                        fileName: "\(imageId.uuidString).jpg",
                                        mimeType: "image/jpg",
                                        fileData: imageData,
                                        using: boundary))

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        return request
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()

        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
          data.appendString("\r\n")

        return data as Data
    }
}
