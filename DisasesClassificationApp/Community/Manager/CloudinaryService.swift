import Foundation
import UIKit

final class CloudinaryService {
    static let shared = CloudinaryService()
    private let cloudName = "dwopgvkw5"
    private let uploadPreset = "AgriBDImageUpload"

    private init() {}

    func uploadImage(_ image: UIImage) async throws -> String {
        guard let compressedData = compressImage(image) else {
            throw CloudinaryError.compressionFailed
        }

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

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

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudinaryError.uploadFailed
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CloudinaryError.uploadFailed
        }
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            throw NSError(domain: "Cloudinary", code: httpResponse.statusCode,
                         userInfo: [NSLocalizedDescriptionKey: message])
        }
        guard let secureURL = json["secure_url"] as? String else {
            throw CloudinaryError.uploadFailed
        }
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
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Image compression failed"
        case .uploadFailed: return "Image upload failed"
        }
    }
}
