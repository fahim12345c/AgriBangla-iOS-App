import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date

    init(role: MessageRole, content: String) {
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

enum MessageRole {
    case user
    case assistant
}

struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
    let systemInstruction: GeminiSystemInstruction?
    let generationConfig: GenerationConfig?
 
    enum CodingKeys: String, CodingKey {
        case contents
        case systemInstruction = "system_instruction"
        case generationConfig  = "generationConfig"
    }
}
 
struct GeminiSystemInstruction: Encodable {
    let parts: [GeminiPart]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
    let role: String?

    init(parts: [GeminiPart], role: String? = nil) {
        self.parts = parts
        self.role = role
    }
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]?
    let error: GeminiError?
}
struct GeminiResponseContent: Codable {
    let parts: [GeminiPart]?
}

enum ChatError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case noResponse
    case httpError(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Invalid URL"
        case .networkError(let e):   return e.localizedDescription
        case .noResponse:            return "No response from Gemini"
        case .httpError(let c, let m): return "HTTP \(c): \(m)"
        }
    }
}

struct GeminiCandidate: Decodable {
    let content: GeminiContent?
    let finishReason: String?
}

struct GenerationConfig: Encodable {
    let temperature: Double
    let maxOutputTokens: Int
}
// MARK: - Response Models
struct GeminiError: Decodable {
    let code: Int
    let message: String
    let status: String
}
