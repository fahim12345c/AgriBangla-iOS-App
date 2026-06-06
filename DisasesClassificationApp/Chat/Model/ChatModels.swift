import Foundation

// MARK: - Chat Message

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    let provider: AIProvider  // ← tracks which AI answered this message

    init(role: MessageRole, content: String, provider: AIProvider = .gemini) {
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.provider = provider
    }
}

enum MessageRole {
    case user
    case assistant
}

/// Which AI service generated this message — useful for UI badges or debug info
enum AIProvider {
    case gemini
    case deepSeek
    case none  // for user messages or error messages
}

// MARK: - Gemini Request Models

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

struct GenerationConfig: Encodable {
    let temperature: Double
    let maxOutputTokens: Int
}

// MARK: - Gemini Response Models

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]?
    let error: GeminiError?
}

struct GeminiResponseContent: Codable {
    let parts: [GeminiPart]?
}

struct GeminiCandidate: Decodable {
    let content: GeminiContent?
    let finishReason: String?
}

struct GeminiError: Decodable {
    let code: Int
    let message: String
    let status: String
}

// MARK: - Chat Errors

enum ChatError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case noResponse
    case httpError(Int, String)
    case quotaExhausted  // ← NEW: all Gemini models returned 429 → trigger DeepSeek fallback

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let e):
            return e.localizedDescription
        case .noResponse:
            return "No response from AI"
        case .httpError(let c, let m):
            return "HTTP \(c): \(m)"
        case .quotaExhausted:
            return "Gemini quota exhausted — switching to DeepSeek"
        }
    }
}
