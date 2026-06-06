import Foundation

// MARK: - DeepSeekService
// Fallback when Gemini exhausts all models on 429 (quota exceeded)
// Uses OpenAI-compatible endpoint

final class DeepSeekService {
    static let shared = DeepSeekService()
    private init() {}

    // ✅ Read from Config.xcconfig → Info.plist (same pattern as Gemini)
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String,
              !key.isEmpty else {
            print("❌ DEEPSEEK_API_KEY not found in Info.plist — ensure Config.xcconfig is set up")
            return ""
        }
        return key
    }

    private let baseURL = "https://api.deepseek.com/chat/completions"

    // Primary model first, pro as fallback
    private let modelFallbackChain = [
        "deepseek-v4-flash",
        "deepseek-v4-pro"
    ]

    private let systemPrompt = """
    You are a friendly agricultural assistant for Bangladeshi farmers.
    Rules:
    1. Always respond in simple, easy Bangla (বাংলা) language
    2. Use very simple words so that a semi-literate farmer can understand easily
    3. Use emojis (🌾 🌱 🌧️ ☀️ 🐛 etc.) to make it visual and engaging
    4. Break information into short bullet points or numbered steps
    5. Avoid technical or English terminology — if unavoidable, explain it simply in Bangla
    6. Keep responses concise and practical — give actionable advice
    7. If the user asks in English, still respond in Bangla
    """

    // MARK: - Public

    func sendMessage(_ userText: String) async throws -> String {
        var lastError: Error = ChatError.noResponse

        for model in modelFallbackChain {
            do {
                return try await performRequest(userText, model: model)
            } catch ChatError.httpError(429, _) {
                lastError = ChatError.httpError(429, "DeepSeek কোটা শেষ")
                continue
            } catch ChatError.httpError(503, _) {
                lastError = ChatError.httpError(503, "DeepSeek সার্ভার ব্যস্ত")
                continue
            } catch {
                throw error
            }
        }

        throw lastError
    }

    // MARK: - Private: single request

    private func performRequest(_ userText: String, model: String) async throws -> String {
        guard let url = URL(string: baseURL) else { throw ChatError.invalidURL }

        let body = DeepSeekRequest(
            model: model,
            messages: [
                DeepSeekMessage(role: "system", content: systemPrompt),
                DeepSeekMessage(role: "user", content: userText)
            ],
            temperature: 0.7,
            maxTokens: 1024,
            stream: false
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        request.httpBody = try JSONEncoder().encode(body)

        let data: Data
        let urlResponse: URLResponse
        do {
            (data, urlResponse) = try await URLSession.shared.data(for: request)
        } catch {
            throw ChatError.networkError(error)
        }

        if let http = urlResponse as? HTTPURLResponse, http.statusCode != 200 {
            if let decoded = try? JSONDecoder().decode(DeepSeekErrorResponse.self, from: data) {
                throw ChatError.httpError(http.statusCode, decoded.error.message)
            }
            throw ChatError.httpError(http.statusCode, "DeepSeek unknown error")
        }

        let decoded = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
        guard let text = decoded.choices.first?.message.content,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { throw ChatError.noResponse }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - DeepSeek Request Models (OpenAI-compatible format)

struct DeepSeekRequest: Encodable {
    let model: String
    let messages: [DeepSeekMessage]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, stream
        case maxTokens = "max_tokens"
    }
}

struct DeepSeekMessage: Codable {
    let role: String
    let content: String
}

// MARK: - DeepSeek Response Models

struct DeepSeekResponse: Decodable {
    let choices: [DeepSeekChoice]
}

struct DeepSeekChoice: Decodable {
    let message: DeepSeekMessage
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct DeepSeekErrorResponse: Decodable {
    let error: DeepSeekAPIError
}

struct DeepSeekAPIError: Decodable {
    let message: String
    let type: String?
}
