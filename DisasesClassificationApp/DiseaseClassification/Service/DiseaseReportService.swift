import Foundation

final class DiseaseReportService {
    static let shared = DiseaseReportService()
    private init() {}

    private var geminiApiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String, !key.isEmpty else {
            return ""
        }
        return key
    }

    private var deepSeekApiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String, !key.isEmpty else {
            return ""
        }
        return key
    }

    private let geminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models"
    private let geminiModels = ["gemini-2.5-flash-lite", "gemini-2.5-flash", "gemini-2.5-flash-preview"]
    private let deepSeekURL = "https://api.deepseek.com/chat/completions"
    private let deepSeekModels = ["deepseek-chat", "deepseek-v4-flash", "deepseek-v4-pro"]

    private let systemPrompt = """
    You are a friendly agricultural assistant for Bangladeshi farmers. Generate a complete disease report in Bangla language.

    Rules:
    1. ALWAYS respond in simple, easy Bangla (বাংলা) language only
    2. Use very simple words so a semi-literate farmer can understand easily
    3. Use emojis (🌾🌱🧑‍🌾💊🌿☀️💧🐛 etc.) to make it visual and engaging
    4. The report MUST have these sections with Bangla headers:
       🌿 রোগের নাম
       📝 রোগ সম্পর্কে (সংক্ষিপ্ত বর্ণনা)
       ⚠️ কারণ
       🔍 লক্ষণ
       ✅ করণীয় (কৃষকের জন্য পরামর্শ)
       💊 সুপারিশকৃত ঔষধ
       🛡️ প্রতিরোধ
    5. Give specific medicine/pesticide/fungicide brand names available in Bangladesh
    6. Keep advice practical, actionable, and budget-friendly
    7. If the result is "Healthy", give tips to keep the plant healthy naturally
    """

    func generateReport(diseaseName: String, confidence: Float) async throws -> String {
        let prompt = makePrompt(diseaseName: diseaseName, confidence: confidence)
        let hasGemini = !geminiApiKey.isEmpty
        let hasDeepSeek = !deepSeekApiKey.isEmpty

        var geminiError: Error?

        if hasGemini {
            do {
                return try await callGemini(prompt: prompt)
            } catch {
                geminiError = error
                print("⚠️ Gemini failed: \(error.localizedDescription) — trying DeepSeek")
            }
        }

        if hasDeepSeek {
            do {
                return try await callDeepSeek(prompt: prompt)
            } catch {
                print("⚠️ DeepSeek also failed: \(error.localizedDescription)")
                if let ge = geminiError { throw ge }
                throw error
            }
        }

        if let ge = geminiError { throw ge }

        throw DiseaseReportError.noAPIKey
    }

    private func makePrompt(diseaseName: String, confidence: Float) -> String {
        let pct = Int(confidence * 100)
        let parts = diseaseName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "/", with: " & ")
        let plant = diseaseName.components(separatedBy: "_").first ?? "Plant"
        let isHealthy = diseaseName.lowercased().contains("healthy")

        if isHealthy {
            return """
            My \(plant) plant is healthy (\(pct)% confidence). Give me tips in Bangla to keep it healthy.

            Generate a complete Bangla report with:
            🌿 রোগের নাম — \(parts)
            📝 রোগ সম্পর্কে
            ⚠️ কারণ
            🔍 লক্ষণ
            ✅ করণীয়
            💊 সুপারিশকৃত জৈব প্রতিকার
            🛡️ প্রতিরোধ
            """
        }

        return """
        My \(plant) plant has been diagnosed with: \(parts) (\(pct)% confidence).

        Generate a complete Bangla disease report with these sections:
        🌿 রোগের নাম — \(parts)
        📝 রোগ সম্পর্কে
        ⚠️ কারণ
        🔍 লক্ষণ
        ✅ করণীয়
        💊 সুপারিশকৃত ঔষধ
        🛡️ প্রতিরোধ

        Use simple Bangla. Add emojis. Give medicine brand names available in Bangladesh.
        """
    }

    // MARK: - Gemini

    private func callGemini(prompt: String) async throws -> String {
        var lastError: Error = ChatError.noResponse
        for model in geminiModels {
            do {
                return try await geminiRequest(prompt: prompt, model: model)
            } catch {
                lastError = error
                continue
            }
        }
        throw lastError
    }

    private func geminiRequest(prompt: String, model: String) async throws -> String {
        let urlString = "\(geminiEndpoint)/\(model):generateContent?key=\(geminiApiKey)"
        guard let url = URL(string: urlString) else { throw ChatError.invalidURL }

        let body: [String: Any] = [
            "contents": [["role": "user", "parts": [["text": prompt]]]],
            "system_instruction": ["parts": [["text": systemPrompt]]],
            "generationConfig": ["temperature": 0.6, "maxOutputTokens": 2048]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ChatError.networkError(NSError(domain: "", code: -1))
        }

        guard http.statusCode == 200 else {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            throw ChatError.httpError(http.statusCode, "Gemini: \(bodyStr.prefix(200))")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw ChatError.noResponse
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - DeepSeek

    private func callDeepSeek(prompt: String) async throws -> String {
        var lastError: Error = ChatError.noResponse
        for model in deepSeekModels {
            do {
                return try await deepSeekRequest(prompt: prompt, model: model)
            } catch {
                lastError = error
                continue
            }
        }
        throw lastError
    }

    private func deepSeekRequest(prompt: String, model: String) async throws -> String {
        guard let url = URL(string: deepSeekURL) else { throw ChatError.invalidURL }

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.6,
            "max_tokens": 2048,
            "stream": false
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(deepSeekApiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 45
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ChatError.networkError(NSError(domain: "", code: -1))
        }

        guard http.statusCode == 200 else {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            throw ChatError.httpError(http.statusCode, "DeepSeek (\(model)): \(bodyStr.prefix(200))")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ChatError.noResponse
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum DiseaseReportError: LocalizedError {
    case noAPIKey

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No AI service configured. Add GEMINI_API_KEY or DEEPSEEK_API_KEY to Config.xcconfig and do a clean build."
        }
    }
}
