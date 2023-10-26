//
//  Created by Nien Lam on 10/5/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import SwiftUI
import RealityKit
import OSLog

enum UploadIOError: Error {
    case invalidURL
    case invalidRequestBody
    case invalidResponseData
    case noFileURLInResponse
    case failedToUploadImage
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidRequestBody:
            return "Invalid request body."
        case .invalidResponseData:
            return "Invalid response data."
        case .noFileURLInResponse:
            return "No file URL found in the response."
        case .failedToUploadImage:
            return "Failed to upload the image."
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidRequestBody
    case invalidResponseData
    case processingFailed
    case invalidImageData
}

struct OriginView: View {
    @State private var isUploading: Bool = false
    @State private var refinedImage: UIImage?
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                VStack(spacing:20){
                    Image(uiImage: refinedImage ?? UIImage(named: "origin")!)
                        .resizable()
                        .frame(width: 500, height: 500)
                    
                    Button("Generate your dream product") {
                        processImage()
                    }
                    .disabled(isUploading) // disable button while processing
                }
            }
        }
    }
    
    func uploadImageToUploadIO(imageData: Data, completion: @escaping (Result<String, UploadIOError>) -> Void) {
        guard let url = URL(string: "https://api.upload.io/v2/accounts/W142hnL/uploads/binary") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer public_kW15bgn7ncGAdEUfV7Gr1iHv6Vi9", forHTTPHeaderField: "Authorization")
        request.addValue("image/png", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(.failedToUploadImage))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }
                
                if let data = data {
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                }
                
                // Update the JSON handling
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let fileUrl = json["fileUrl"] as? String else {
                    completion(.failure(.failedToUploadImage))
                    return
                }
                
                completion(.success(fileUrl))
            }
        }
        task.resume()
    }
    
    func sendDrawingToReplicateAPI(imageUrl: String, completion: @escaping (Result<String, Error>) -> Void) {
        let replicateApiKey = "19b22a9cc72c8a00c18c6b0b594832c20312aed9"
        
        guard let url = URL(string: "https://api.replicate.com/v1/predictions") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(replicateApiKey)", forHTTPHeaderField: "Authorization")
        
        let input = [
            "image": imageUrl,
            "prompt": "a Dieter Rams Style product design",
            "num_samples": "1",
            "image_resolution": "512",
            //low_threshold: 100,
            //high_threshold: 100,
            "ddim_steps": 20,
            "scale": 9,
            "eta": 0,
            "a_prompt":
              "best quality, extremely detailed",
            "n_prompt":
              "longbody, lowres, bad anatomy, bad hands, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality",
            "detect_resolution": 512,
            "bg_threshold": 0,
        ] as [String : Any]
        
        let body =
        [
            "version": "cc8066f617b6c99fdb134bc1195c5291cf2610875da4985a39de50ee1f46d81c",
            "input": input
        ] as [String: Any]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion(.failure(APIError.invalidRequestBody))
            return
        }
        
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Invalid response data: \(String(data: data ?? Data(), encoding: .utf8) ?? "No data")")
                completion(.failure(APIError.invalidResponseData))
                return
            }
            
            print("JSON response: \(json)")
            
            guard let urls = json["urls"] as? [String: Any], let getUrl = urls["get"] as? String else {
                print("Failed to get URL: \(json)") // Add this line to print the JSON when failing to get the URL
                completion(.failure(APIError.processingFailed))
                return
            }
            
            print("Get URL: \(getUrl)")
            self.pollReplicateAPI(url: getUrl, completion: completion) // Add this line to start polling
        }
        
        task.resume()
    }
    
    func pollReplicateAPI(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Token 19b22a9cc72c8a00c18c6b0b594832c20312aed9", forHTTPHeaderField: "Authorization") // Add this line to set the API token in the header
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(APIError.invalidResponseData))
                return
            }
            
            print("Polling JSON response: \(json)")
            
            if let status = json["status"] as? String, status == "succeeded" {
                guard let output = json["output"] as? [String], output.count >= 2 else {
                    completion(.failure(APIError.processingFailed))
                    return
                }

                let imageUrl = output[1] // This corresponds to the second URL in the output array
                completion(.success(imageUrl))
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.pollReplicateAPI(url: url, completion: completion)
                }
            }
        }
        
        task.resume()
    }
    
    func downloadImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(APIError.invalidImageData))
                return
            }
            
            completion(.success(image))
        }.resume()
    }

    
    func processImage() {
        isUploading = true
        
        guard let image = UIImage(named: "origin"), let imageData = image.pngData() else { return }
        
        uploadImageToUploadIO(imageData: imageData) { result in
            switch result {
            case .success(let imageUrl):
                // You will need to implement the sendDrawingToReplicateAPI similarly to how it's done in the original code.
                sendDrawingToReplicateAPI(imageUrl: imageUrl) { result in
                    switch result {
                    case .success(let refinedImageUrl):
                        downloadImage(from: refinedImageUrl) { result in
                            switch result {
                            case .success(let image):
                                self.refinedImage = image
                            case .failure(let error):
                                print("Error downloading image: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("Failed to process the image: \(error.localizedDescription)")
                    }
                    isUploading = false
                }
                
            case .failure(let error):
                print("Failed to upload the image: \(error.localizedDescription)")
                isUploading = false
            }
        }
    }
    
    // The implementation for `uploadImageToUploadIO` and other needed functions should be added here.
}

#Preview {
    OriginView()
}
