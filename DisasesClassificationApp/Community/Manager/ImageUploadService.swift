import Foundation
import UIKit
import FirebaseStorage

final class ImageUploadService {
    static let shared = ImageUploadService()
    private let storage = Storage.storage().reference()
    private let maxDimension: CGFloat = 1024
    private let compressionQuality: CGFloat = 0.5

    private init() {}

    func uploadImage(_ image: UIImage) async throws -> String {
        guard let compressedData = compressImage(image) else {
            throw ImageUploadError.compressionFailed
        }

        let filename = "community_images/\(UUID().uuidString).jpg"
        let ref = storage.child(filename)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(compressedData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    private func compressImage(_ image: UIImage) -> Data? {
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

enum ImageUploadError: LocalizedError {
    case compressionFailed
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Image compression failed"
        case .uploadFailed: return "Image upload failed"
        }
    }
}
