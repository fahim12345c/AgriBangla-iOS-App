import Foundation
import CommonCrypto

// MARK: - Cloudinary Credentials
let cloudName = "dwopgvkw5"
let apiKey = "158997785998229"
let apiSecret = "UnwGtQWiM987PgNZ_qFqELRVrXU"

func sha1(_ string: String) -> String {
    let data = Data(string.utf8)
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes { bytes in
        _ = CC_SHA1(bytes.baseAddress, CC_LONG(data.count), &digest)
    }
    return digest.map { String(format: "%02x", $0) }.joined()
}

func uploadImage() async throws -> (secureURL: String, publicID: String, width: Int, height: Int, format: String, bytes: Int) {
    let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let timestamp = Int(Date().timeIntervalSince1970)

    let paramsToSign = ["timestamp": "\(timestamp)"]
    let signatureBase = paramsToSign.sorted { $0.key < $1.key }
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&") + apiSecret
    let signature = sha1(signatureBase)

    let imageURL = "https://res.cloudinary.com/demo/image/upload/sample.jpg"

    let formBody: [String: String] = [
        "file": imageURL,
        "api_key": apiKey,
        "timestamp": "\(timestamp)",
        "signature": signature
    ]

    var components = URLComponents()
    components.queryItems = formBody.map { URLQueryItem(name: $0.key, value: $0.value) }
    request.httpBody = components.query?.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "Cloudinary", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
    }

    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw NSError(domain: "Cloudinary", code: -2,
                     userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
    }

    if let error = json["error"] as? [String: Any],
       let message = error["message"] as? String {
        throw NSError(domain: "Cloudinary", code: httpResponse.statusCode,
                     userInfo: [NSLocalizedDescriptionKey: message])
    }

    guard let secureURL = json["secure_url"] as? String,
          let publicID = json["public_id"] as? String,
          let width = json["width"] as? Int,
          let height = json["height"] as? Int,
          let format = json["format"] as? String,
          let bytes = json["bytes"] as? Int else {
        throw NSError(domain: "Cloudinary", code: -3,
                     userInfo: [NSLocalizedDescriptionKey: "Missing fields in upload response"])
    }

    return (secureURL, publicID, width, height, format, bytes)
}

@main
struct CloudinaryTest {
    static func main() async {
        print("🚀 Cloudinary Integration Test\n")

        do {
            // 1. Upload a sample image and get its metadata from the response
            print("📤 Uploading image...")
            let (secureURL, publicID, width, height, format, bytes) = try await uploadImage()
            print("   ✅ Uploaded!")
            print("   Secure URL: \(secureURL)")
            print("   Public ID: \(publicID)\n")

            // 2. Print image metadata (returned by upload response)
            print("📋 Image Details:")
            print("   Width: \(width)px")
            print("   Height: \(height)px")
            print("   Format: \(format)")
            print("   Size: \(bytes) bytes (\(bytes / 1024) KB)\n")

            // 3. Generate transformed URL
            // f_auto -> Cloudinary picks the best format (WebP, AVIF, etc.) based on browser support
            // q_auto -> Cloudinary selects optimal quality level for smallest file size without visible loss
            let transformedURL = "https://res.cloudinary.com/\(cloudName)/image/upload/f_auto,q_auto/\(publicID)"
            print("🔄 Transformed URL (f_auto + q_auto):")
            print("   \(transformedURL)\n")
            print("✅ Done! Click link below to see optimized version of the image.")
            print("   Check the size and the format.")

        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}
