import Foundation

final class GeminiService {
    static let shared = GeminiService()
    private init() {}
 
    // ✅ Read from Config.xcconfig → Info.plist (secure, not hardcoded)
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !key.isEmpty else {
            print("❌ GEMINI_API_KEY not found in Info.plist — ensure Config.xcconfig is set up")
            return ""
        }
        return key
    }
 
    // ✅ Use Flash-Lite FIRST — less demand, same free tier, faster response
    // Falls back to Flash if Lite is overloaded
    private let modelFallbackChain = [
        "gemini-2.5-flash-lite",    // primary: least busy, most quota
        "gemini-2.5-flash",         // fallback: confirmed working on v1beta
        "gemini-2.5-flash-preview"  // last resort
    ]
 
    private let baseEndpoint = "https://generativelanguage.googleapis.com/v1beta/models"
 
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
 
    /// Throws `ChatError.quotaExhausted` when ALL models return 429 — caller should try DeepSeek.
    /// Throws `ChatError.httpError(503, _)` when ALL models are overloaded.
    func sendMessage(_ userText: String) async throws -> String {
        var lastError: Error = ChatError.noResponse
        var allModels429 = true  // track if every failure was quota-related
 
        for model in modelFallbackChain {
            do {
                let result = try await sendWithRetry(userText, model: model)
                return result
            } catch ChatError.httpError(429, _) {
                // 429 = quota — try next model
                lastError = ChatError.httpError(429, "কোটা শেষ, পরের মডেল চেষ্টা করছি...")
                continue
            } catch ChatError.httpError(503, _) {
                // 503 = overloaded — try next model, but not a quota issue
                allModels429 = false
                lastError = ChatError.httpError(503, "সার্ভার ব্যস্ত, পরের মডেল চেষ্টা করছি...")
                continue
            } catch {
                // Any other error (404, 400, network) — throw immediately
                throw error
            }
        }
 
        // If every model returned 429, signal quota exhausted so caller can try DeepSeek
        if allModels429 {
            throw ChatError.quotaExhausted
        }
 
        // All models failed for other reasons (503 etc.)
        throw ChatError.httpError(503, "সার্ভার এখন অনেক ব্যস্ত। কিছুক্ষণ পরে আবার চেষ্টা করুন। 🙏")
    }
 
    // MARK: - Private: retry with exponential backoff on 503
 
    private func sendWithRetry(_ userText: String, model: String, attempt: Int = 1) async throws -> String {
        do {
            return try await performRequest(userText, model: model)
        } catch ChatError.httpError(503, _) where attempt < 3 {
            // Wait 2s × attempt, then retry same model
            try await Task.sleep(nanoseconds: UInt64(attempt) * 2_000_000_000)
            return try await sendWithRetry(userText, model: model, attempt: attempt + 1)
        }
        // After 2 retries on same model, rethrow so caller tries next model
        return try await performRequest(userText, model: model)
    }
 
    // MARK: - Private: single request
 
    private func performRequest(_ userText: String, model: String) async throws -> String {
        let urlString = "\(baseEndpoint)/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw ChatError.invalidURL }
 
        let body = GeminiRequest(
            contents: [GeminiContent(parts: [GeminiPart(text: userText)], role: "user")],
            systemInstruction: GeminiSystemInstruction(parts: [GeminiPart(text: systemPrompt)]),
            generationConfig: GenerationConfig(temperature: 0.7, maxOutputTokens: 1024)
        )
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
            if let decoded = try? JSONDecoder().decode(GeminiResponse.self, from: data),
               let apiError = decoded.error {
                throw ChatError.httpError(apiError.code, apiError.message)
            }
            throw ChatError.httpError(http.statusCode, "Unknown server error")
        }
 
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard
            let firstPart = decoded.candidates?.first?.content?.parts.first
        else { throw ChatError.noResponse }
 
        let trimmed = firstPart.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ChatError.noResponse }
        return trimmed
    }
}
