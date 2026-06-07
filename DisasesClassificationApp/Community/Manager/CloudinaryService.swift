import Foundation
import UIKit

final class CloudinaryService {
    static let shared = CloudinaryService()
    private let cloudName = "dwopgvkw5"
    private let uploadPreset = "AgriBDImageUpload"

    private init() {}

    func uploadImage(_ image: UIImage) async throws -> String {
        print("[Cloudinary] Starting upload to cloud: \(cloudName), preset: \(uploadPreset)")

        guard let compressedData = compressImage(image) else {
            print("[Cloudinary] Compression failed")
            throw CloudinaryError.compressionFailed
        }
        print("[Cloudinary] Image compressed: \(compressedData.count) bytes")

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(compressedData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("[Cloudinary] Sending POST request to: \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[Cloudinary] No HTTP response")
            throw CloudinaryError.uploadFailed("No HTTP response from Cloudinary")
        }
        print("[Cloudinary] HTTP response status: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let responseBody = String(data: data, encoding: .utf8) ?? "no body"
            print("[Cloudinary] Error response body: \(responseBody)")
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                print("[Cloudinary] Cloudinary error message: \(message)")
                throw CloudinaryError.uploadFailed(message)
            }
            throw CloudinaryError.uploadFailed(
                "Cloudinary returned HTTP \(httpResponse.statusCode). " +
                "Check that upload preset '\(uploadPreset)' exists and is unsigned " +
                "(Cloudinary Console → Settings → Upload). Response: \(responseBody)"
            )
        }

        let responseBody = String(data: data, encoding: .utf8) ?? ""
        print("[Cloudinary] Success response: \(responseBody.prefix(200))")

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("[Cloudinary] Invalid JSON in response")
            throw CloudinaryError.uploadFailed("Invalid JSON response from Cloudinary")
        }

        guard let secureURL = json["secure_url"] as? String else {
            print("[Cloudinary] Missing secure_url in response")
            throw CloudinaryError.uploadFailed("No image URL in Cloudinary response")
        }

        print("[Cloudinary] Upload success, URL: \(secureURL)")
        return secureURL
    }

    private func compressImage(_ image: UIImage) -> Data? {
        let maxDimension: CGFloat = 1024
        let compressionQuality: CGFloat = 0.5
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized?.jpegData(compressionQuality: compressionQuality)
    }
}

enum CloudinaryError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to process image. Try a smaller or different photo."
        case .uploadFailed(let detail):
            return detail
        }
    }
}
